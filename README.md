# Dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/dotfiles.html).

One repo configures shell, editor, terminal, Git and developer tools across
four machine classes, and push-bootstraps a VPS fleet over SSH.

## Machine classes

Everything is selected by `MISE_ENV`, which is **always** set — there is no
"unset means default" case.

| `MISE_ENV` | Machine |
|---|---|
| `bryan` | Bryan's personal mac |
| `work` | Bryan's work mac |
| `irene` | Irene's personal mac |
| `server` | VPS / VM |

What each class gets:

| | `bryan` | `work` | `irene` | `server` |
|---|:--:|:--:|:--:|:--:|
| zsh, git, starship, nvim, ripgrep, uv, core CLI | ✅ | ✅ | ✅ | ✅ |
| terminals (kitty, ghostty, wezterm) | ✅ | ✅ | ✅ | — |
| window managers (aerospace, nehir) | ✅ | ✅ | ✅ | — |
| television, herdr, Claude settings | ✅ | ✅ | ✅ | — |
| k9s, zellij, kubectl, helm, kustomize, duckdb | ✅ | ✅ | — | — |
| talosctl, cilium, supabase, kopia, agent tooling | ✅ | — | — | — |
| antigravity-cli, kopia, rclone | — | — | ✅ | — |

File-level selection lives in `[dotfiles]` `variants` in
`.config/mise/config.toml`. Tool-level selection lives in
`.config/mise/config.<class>.toml`.

## Bootstrap a new machine

```sh
git clone https://github.com/bryan824/dotfiles.git ~/.dotfiles
```

**Write both machine-local files before applying anything.** Neither is
committed; each machine sets its own.

```sh
mkdir -p ~/.config/mise

# 1. Machine class. Without this, only the 12 base tools load and every
#    desktop dotfile is skipped.
cat > ~/.config/mise/miserc.toml <<'EOF'
env = ["bryan"]        # bryan | work | irene | server
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

Python needs no activation step: `python.uv_venv_auto = "source"` in
`config.toml` activates a project's `.venv` on `cd`. That replaced direnv and
its `layout_uv`, which this repo used to carry.

## Layout

Source paths mirror their target exactly. `~/.config/nvim` comes from
`.config/nvim`. No filename prefixes or suffixes, except `.tera` on templates.

```
.config/mise/config.toml          # settings + [dotfiles] table + base tools
.config/mise/config.bryan.toml    # per-class tools
.config/mise/config.work.toml
.config/mise/config.irene.toml
.config/mise/config.server.toml
.config/mise/tasks/preset/        # wrappers: `mise run preset:python`
copier.yml                        # project template: questions + subdirectory
.config/copier/python/            # template files (.jinja), per stack
.config/copier/rust/
.config/hk/common.pkl             # shared hook steps, imported live by projects
.config/zsh/                      # numbered startup fragments + Zim
.config/nvim/
.config/kitty/  .config/ghostty/  .config/wezterm/
.config/git/  .config/television/  .config/k9s/  ...
```

### Templates (`.tera`)

Rendered, not linked. Editing the live file does **not** reach this repo.

| Target | Why |
|---|---|
| `.config/git/config` | `vars.git_name` / `vars.git_email` |
| `.config/starship.toml` | gcloud module on `bryan` + `work` |
| `.config/zsh/80_host.zsh` | `TALOSCONFIG` on `bryan` |
| `.claude/settings.json` | strict JSON, needs absolute `$HOME` |
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
- `ipinfo` reads `$IPINFO_TOKEN`, supplied age-encrypted from
  `config.bryan.toml`. Add a secret with
  `mise set -g --age-encrypt --prompt NAME`, then move the line into the class
  config that needs it — see AGENTS.md.
- One nvim config: `.config/nvim`, plugins via `vim.pack`, no Mason. `v`, `vi`
  and `vim` all point at it. The LazyVim second config (`NVIM_APPNAME=lazyvim`)
  and the leftover `~/.local/share/nvim/mason` are both gone, and the Mason bin
  directory is off `PATH`.
- Agent harness deployment stays separate: `bunx github:bryan824/kirin-pi apply`.
- Secrets never live in this repo. Machine identity goes in
  `~/.config/mise/config.local.toml`; anything else reads from the environment.
