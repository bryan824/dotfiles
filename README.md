# Dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/dotfiles.html).

One repo configures shell, editor, terminal, Git and developer tools on every
machine, composed from layers, and push-bootstraps servers and a VyOS router
over SSH.

## Machine layers

Everything is selected by `MISE_ENV`, which is **always** set — there is no
"unset means default" case. Its value is a list of layers, pinned per machine
in `~/.config/mise/miserc.toml`:

| Machine | `env` |
|---|---|
| Bryan's personal mac | `["desktop", "dev", "backup", "bryan"]` |
| Bryan's work mac | `["desktop", "dev"]` |
| Irene's personal mac | `["desktop", "backup", "irene"]` |
| VPS / VM | `["server"]` |
| VyOS router | `["vyos"]` |

Each layer is one `.config/mise/config.<layer>.toml` holding a capability's
tools, dotfiles and LaunchAgents together, so a tool can never reach a machine
its config misses:

| Layer | Adds |
|---|---|
| base — `config.toml`, always | zsh, git, starship, nvim, bat, ripgrep, uv, core CLI |
| `desktop` | terminal (kitty), television, bun, node |
| `dev` | kubectl, k9s, helm, kustomize, duckdb, hk, tokei |
| `backup` | kopia, rclone, their exclude lists, the nightly LaunchAgent |
| `bryan` | talosctl, cilium, supabase, gnupg, agent tooling, Syncthing service |
| `irene` | antigravity-cli, Syncthing service; no scheduled self-update |
| `server` | no extra tools; dotfile history disabled |
| `vyos` | vector and its config; router-only bootstrap |

A new capability is a new layer file plus one word in the miserc of each
machine that wants it — no per-entry `variants` lists.

## Bootstrap a new machine

On a version-controlled workstation:

```sh
git clone https://github.com/bryan824/dotfiles.git ~/.dotfiles
```

Irene instead receives a **files-only** `~/.dotfiles` directory: copy the
files without `.git`, rather than cloning or pulling. See the one-way mirror
setup below. The `irene` layer disables mise history as well.

**Write both machine-local files before applying anything.** Neither is
committed; each machine sets its own.

```sh
mkdir -p ~/.config/mise

# 1. Machine layers, from the table above. Without this, only the base layer
#    loads: no desktop tools, no desktop dotfiles. On a mac the shell says so.
cat > ~/.config/mise/miserc.toml <<'EOF'
env = ["desktop", "dev", "backup", "bryan"]
EOF

# 2. Git identity, and any other per-machine path. Without the first two,
#    ~/.config/git/config renders with no [user] section and commits lose
#    their author.
cat > ~/.config/mise/config.local.toml <<'EOF'
[vars]
git_name  = "Your Name"
git_email = "you@example.com"
# Optional, rendered into ~/.config/zsh/80_host.zsh when set:
# talosconfig = "~/src/homelab/terraform/output/talos-config.yaml"
EOF
```

Everything in `[vars]` is opt-in: a template that references a var you have not
set renders that section empty rather than failing, so a fresh machine works
without setting any of the optional ones.

Then link mise's own config into place once, to break the chicken-and-egg
(mise must load the config that manages its config), and bootstrap:

```sh
ln -sf ~/.dotfiles/.config/mise/config.toml ~/.config/mise/config.toml
mise bootstrap dotfiles diff     # always preview first
mise bootstrap dotfiles apply -f
```

`-f` is needed on a machine that already has real files at those paths.

### Moving an existing machine to layers

A machine set up before layers has a single-class miserc (`env = ["work"]`).
After receiving updated files, it loads only the base layer until that line
is rewritten per the table above, and a mac warns at every shell start until
then. Rewrite it,
then apply so the new layer files get linked into `~/.config/mise`:

```sh
$EDITOR ~/.config/mise/miserc.toml
mise bootstrap dotfiles apply
```

## Bootstrap the fleet

Servers are pushed to, never pulled from. Nothing persistent lands on the box —
`--github-relay-read-only` borrows GitHub access for the invocation only.

```sh
mise bootstrap remote --tag vps \
  --remote-env server \
  --only dotfiles,tools \
  --github-relay-read-only \
  --install-mise
```

Hosts live in `[bootstrap.remote.hosts]`, which belongs in
`~/.config/mise/config.local.toml` — hostnames, users and key paths are machine
and network detail, not something to publish:

```toml
[bootstrap.remote.hosts.vps1]
host = "vps1.example.com"
user = "ubuntu"
identity_file = "~/.ssh/id_ed25519"
tags = ["vps"]
mise_env = ["server"]
```

`--tag vps` then selects every host carrying that tag. Preview any run with
`--dry-run`.

Servers set `history.enabled = false` so a box never publishes its local drift
back to this repo.

## Daily use

```sh
mise bootstrap dotfiles status    # what is managed, and its state
mise bootstrap dotfiles diff      # preview pending changes
mise bootstrap dotfiles apply     # apply
mise bootstrap dotfiles add --changed   # pull copy-mode edits back into the repo
```

Most files are symlinked, so editing the live path edits this repo directly —
no capture step. The exceptions are listed below.

### Add an existing file

Use `add` to bring a live file into this repo. Use `apply` when the source
already exists here and you want to deploy it to another machine.

For a single settings file that you edit, choose **`symlink`**. For example,
Zed settings belong to the `dev` layer so your personal and work Macs receive
them, but Irene's Mac and servers do not.

1. Check the file for secrets and machine-specific paths. Manage only the
   settings file, not an entire application directory that may contain private
   data or caches.
2. Choose the config file that controls which machines receive it:

   | Config under `.config/mise/` | Receives the file |
   |---|---|
   | `config.toml` | Every machine, including servers |
   | `config.desktop.toml` | All desktop Macs, including Irene's |
   | `config.dev.toml` | Your personal and work Macs |
   | `config.bryan.toml` | Your personal Macs only |
   | `config.irene.toml` | Irene's Macs only |

3. Preview the import. Always specify `--path` to select the layer and
   `--mode` to select how the file is deployed:

   ```sh
   mise bootstrap dotfiles add --dry-run \
     --path ~/.dotfiles/.config/mise/config.dev.toml \
     --mode symlink ~/.config/zed/settings.json
   ```

4. If the preview is correct, repeat without `--dry-run`:

   ```sh
   mise bootstrap dotfiles add \
     --path ~/.dotfiles/.config/mise/config.dev.toml \
     --mode symlink ~/.config/zed/settings.json
   ```

   This copies the live contents to `.config/zed/settings.json` in this repo,
   adds the layer's `[dotfiles]` entry, and replaces the live file with a link
   to that source. No separate `apply` is needed. Later edits through the link
   change this repo directly.

5. Check the result and review the Git diff before committing:

   ```sh
   mise bootstrap dotfiles status ~/.config/zed/settings.json
   git status --short
   git diff -- .config/mise/config.dev.toml
   ```

   The imported settings file is new and untracked until staged; inspect it
   directly because plain `git diff` does not show untracked contents.

#### Choose a mode

| Mode | Choose it when | How edits reach this repo |
|---|---|---|
| `symlink` | You manage one file, or intentionally link a whole directory. | Live edits change the source directly. A whole-directory link also puts new runtime files in the repo. |
| `symlink-each` | You manage files inside a directory but want new runtime files to stay local. | Existing linked files change the source directly. New source files need an `apply`. |
| `copy` | The app rewrites the file, or you want to review local edits before importing them. | Run `mise bootstrap dotfiles add <target>` to capture one file, or `add --changed` for all changed copy-mode files. |
| `template` | The deployed file needs machine-specific values. | Edit the `.tera` source here, preview with `diff`, then `apply`. Live edits do not update the template. |

This repo defaults to **`symlink-each`**, which requires a directory source.
For a single file, explicitly pass `--mode symlink` or `--mode copy`.
`--mode` selects the mode for a new target; it does not change an existing
managed target's mode.

Templates need a `.tera` source and an explicit `source` entry; see
[Templates](#templates-tera). Do not apply `symlink-each` over an existing
whole-directory symlink. Remove only the old directory link first, not its
contents; see the deployment warning in `AGENTS.md`.

### Zed settings (dev layer)

Only `~/.config/zed/settings.json` is managed, as a single-file symlink.
Other Zed files stay local. Settings edits through the link reach this repo;
review them before committing.

On another developer Mac, preserve any local settings you want to keep, then
preview and apply only this target. **`-f` replaces its existing settings with
the repo-backed link.**

```sh
mise bootstrap dotfiles apply -f --dry-run ~/.config/zed/settings.json
mise bootstrap dotfiles apply -f ~/.config/zed/settings.json
```

### Agent settings stay local

Pi and Claude settings are not managed by this repo. Their home-directory
files stay local, along with credentials, sessions and machine identifiers.
This avoids importing runtime state, such as Pi's `deviceId`, into shared
configuration. Configure each application on each machine.

`CLAUDE.md` only points Claude to this repo's `AGENTS.md`; it is not an
application settings file.

### Syncthing service (personal Macs)

The `bryan` and `irene` layers declare Syncthing and a login LaunchAgent.
Adding or receiving the configuration does not install tools or start agents;
install the declared tools, then preview and apply as the logged-in user:

```sh
mise install
mise bootstrap macos launchd-agents apply --dry-run
mise bootstrap macos launchd-agents apply
mise bootstrap macos launchd-agents status
```

The agent runs while logged in and awake, restarts after exits, and resolves
the current mise-managed binary at each start. Syncthing's own restart and
auto-upgrade mechanisms are disabled: launchd handles restarts and mise handles
upgrades. It does not open a browser; visit http://localhost:8384 manually.
Logs are in `~/Library/Logs/syncthing-launchagent.{out,err}`.

### Irene: one-way files-only mirror

The source workstation owns Git. Irene's `~/.dotfiles` has no `.git` and
receives file updates, currently by SCP. Do not run `git pull`, `git init` or
`mise bootstrap dotfiles add --changed` there; make source changes on the
version-controlled workstation instead.

For future Syncthing setup (not enabled by these dotfiles):

1. Pair the Macs and share the same folder ID, with `~/.dotfiles` as the path
   on each Mac.
2. Set the source folder to **Send Only** and Irene's folder to
   **Receive Only**, not the default Send & Receive.
3. Before the first sync, add `/.git` to the folder's ignore patterns on
   **both** Macs. This ignores the directory and its contents, not just Git
   working files. `.stignore` is device-local and is never synced, so configure
   both copies independently. Keep machine-local credentials and device IDs
   out of this repo.
4. After files arrive, preview and apply with mise on Irene's Mac. Syncthing
   transfers files; it does not render templates, create new deployment links,
   install tools or load LaunchAgents:

   ```sh
   mise bootstrap dotfiles diff
   mise bootstrap dotfiles apply
   mise install
   mise bootstrap macos launchd-agents apply --dry-run
   mise bootstrap macos launchd-agents apply
   ```

Do not overwrite source changes from Irene. If Receive Only reports local
changes, review them before using **Revert Local Changes**, which deletes or
replaces those edits.

## New projects

This repo is also a [copier](https://copier.readthedocs.io) template. `copier.yml`
at the root picks a subdirectory of `.config/copier/` per stack; the tasks in
`.config/mise/tasks/preset/` are thin wrappers that run it in the current
directory.

### Starting a Python project, start to finish

```sh
# 1. Empty directory, git first — `--hooks` installs into .git, so it must exist.
mkdir my-project && cd my-project && git init

# 2. Scaffold. Flags are optional; --ci and --hooks are worth it for anything
#    that outlives the afternoon.
mise run preset:python --ci --hooks

# 3. Write code and tests. src/ is yours to lay out; tests/test_smoke.py is a
#    placeholder so the gate passes before real tests exist — replace it.
$EDITOR tests/test_smoke.py

# 4. The gate: lint + types + tests, in parallel.
mise run check          # or `mise run c`
mise run fix            # ruff --fix then format, when it complains

# 5. Commit. With --hooks, hk formats and lints staged files first.
git add -p && git commit

# 6. Push. With --ci, GitHub Actions runs that same `mise run check`.
gh repo create my-project --private --source=. --push
```

What lands on disk:

```
mise.toml              tasks + tool pins (uv, watchexec, hk)
pyproject.toml         deps; pytest and ruff already in the dev group
uv.lock                committed
.venv/                 not committed; activates on cd
tests/test_smoke.py    placeholder test
hk.pkl                 --hooks
.github/workflows/     --ci
.copier-answers.yml    how this project was generated
```

Adding a dependency is `uv add <pkg>`; a dev one is `uv add --dev <pkg>`. No
activation step and no `pip` — `python.uv_venv_auto` activates `.venv` on `cd`.

Other stacks and options:

```sh
mise run preset:rust --ci --hooks     # same task names, cargo underneath
mise run preset:python --name widget  # name differs from the directory
mise run preset:rust --ask            # prompt for every question
```

Unlike a plain scaffold, the template stays attached. Later improvements here
reach projects generated months ago:

```sh
mise run preset:update            # from inside the project; needs a clean tree
```

That is a three-way merge — template changes land, local edits survive.
Generation is recorded in the project's `.copier-answers.yml`.

No second repo, and nothing installed: `uvx copier` runs it on demand.

Both write the same task names, so one command works in any repo:

| | python | rust |
|---|---|---|
| `sync` (`s`) | `uv sync --locked` | `cargo fetch --locked` |
| `fmt` | `ruff format` | `cargo fmt` |
| `lint` | `ruff check` | `cargo clippy -D warnings` |
| `types` | `uv check` (ty) | — compiler |
| `test` (`t`) | `pytest` | `cargo nextest` |
| `fix` | ruff `--fix` + format | clippy `--fix` + fmt |
| `check` (`c`) | lint + types + test | lint + test |
| `build` | `uv build` | `cargo build --release` |
| `run` (`r`) | — | `cargo run` |
| `watch` | `watchexec` → `check` | `watchexec` → `check` |

`check` declares the others as `depends`, so mise runs them in parallel.

`--ci` adds a GitHub Actions workflow running that same `mise run check`.
`--hooks` adds `hk.pkl` — [hk](https://hk.jdx.dev), jdx's hook runner. The same
steps run three ways: as the pre-commit hook, as `hk fix` (writes), and as
`hk check` (does not). Steps declare read/write effects, so independent ones
run in parallel and anything touching the same files takes turns.

The step list is **not** copied into the project. `hk.pkl` imports it live:

```pkl
import "https://raw.githubusercontent.com/bryan824/dotfiles/main/.config/hk/common.pkl" as Shared
local linters = Shared.python     // or Shared.rust
```

So adding a linter to `.config/hk/common.pkl` and pushing changes the hooks in
every generated repo, with no `mise run preset:update` anywhere. That is the
one thing the copier template cannot do — templates copy, imports stay live.

The trade is real: a broken push breaks hooks everywhere, and the URL tracks
`main`. Run `hk validate` in a project before pushing a change to that file,
and pin the URL to a commit SHA in any repo that must not move.

Hooks stay incremental — staged files only. `mise run check` remains the
whole-project gate, and it is the one CI runs.


## Layout

Source paths mirror their target exactly. `~/.config/nvim` comes from
`.config/nvim`. No filename prefixes or suffixes, except `.tera` on templates.

```
.config/mise/config.toml          # settings, base dotfiles + tools (every machine)
.config/mise/config.desktop.toml  # layers: tools + dotfiles + agents per capability
.config/mise/config.dev.toml
.config/mise/config.backup.toml
.config/mise/config.bryan.toml    # per-person additions
.config/mise/config.irene.toml
.config/mise/config.server.toml   # remote classes
.config/mise/config.vyos.toml
vyos/                             # router files, mirroring absolute paths
.config/mise/tasks/preset/        # wrappers: `mise run preset:python`
copier.yml                        # project template: questions + subdirectory
.config/copier/python/            # template files (.jinja), per stack
.config/copier/rust/
.config/hk/common.pkl             # shared hook steps, imported live by projects
.config/zsh/                      # numbered startup fragments + Zim
.config/nvim/
.config/kitty/
.config/ghostty/  .config/wezterm/  # backup only; not deployed
.config/git/  .config/television/  .config/k9s/  ...
```

### Templates (`.tera`)

Rendered, not linked. Editing the live file does **not** reach this repo.

| Target | Why |
|---|---|
| `.config/git/config` | `vars.git_name` / `vars.git_email` |
| `.config/zsh/80_host.zsh` | `TALOSCONFIG`, when `vars.talosconfig` is set |
| `.config/kitty/launch.conf` | kitty does not expand `~` in `launch` |
| `.config/k9s/config.yaml` | k9s does not expand `~` in `screenDumpDir` |

### Copy-mode files

Their own tool rewrites them at runtime, so they are copied rather than
symlinked — otherwise every plugin update or app exit dirties this repo. Use
`mise bootstrap dotfiles add --changed` to pull real changes back.

- `.config/nvim/nvim-pack-lock.json` — plugin revs, written by `vim.pack`
- `.config/kitty/current-theme.conf` — written by the `themes` kitten

## Notes

- Shell startup uses `ZDOTDIR=~/.config/zsh` from `.zshenv`.
- Intel Macs use fd `10.3.0`, the last release tested upstream on that
  platform; Apple Silicon and other operating systems keep `latest`.
- `ipinfo` reads `$IPINFO_TOKEN`, supplied age-encrypted from
  `config.bryan.toml`. Add a secret with
  `mise set -g --age-encrypt --prompt NAME`, then move the line into the layer
  or machine config that needs it — see AGENTS.md.
- One nvim config: `.config/nvim`, plugins via `vim.pack`. `v`, `vi` and `vim`
  all point at it.
- Agent harness deployment stays separate: `bunx github:bryan824/kirin-pi apply`.
- Secrets never live in this repo. Machine identity goes in
  `~/.config/mise/config.local.toml`; anything else reads from the environment.
