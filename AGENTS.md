# Agent instructions for this repo

This is a **mise dotfiles source repo**. Files here are deployed to the home
directory by `mise bootstrap dotfiles`. Source paths mirror their targets
exactly — `.config/nvim/init.lua` becomes `~/.config/nvim/init.lua`. There are
no filename prefixes or suffixes to decode, except `.tera` on templates.

Deployment mode decides whether editing the live file reaches this repo. Check
`[dotfiles]` in `.config/mise/config.toml` before assuming.

| Mode | Live edit reaches repo? |
|---|---|
| `symlink` / `symlink-each` | yes — the live path *is* this file |
| `template` (`.tera`) | **no** — edit the `.tera` source here |
| `copy` | **no** — run `mise bootstrap dotfiles add --changed` |

## Rule: MISE_ENV is always set

Its value is a list of layers — capabilities `desktop`, `dev`, `backup`, then
a person (`bryan`, `irene`) — or a remote class (`server`, `vyos`). README.md
has the per-machine table. Nothing is designed to work with `MISE_ENV` unset —
unset silently behaves like a stripped-down `server`, loading only the base
tools and skipping every desktop dotfile.

The list is pinned per machine in `~/.config/mise/miserc.toml`, which is not
managed by this repo:

```toml
env = ["desktop", "dev", "backup", "bryan"]
```

Do not set it from a shell rc instead. `~/.zshenv` and `~/.config/zsh/*` are
symlinks into this repo, so an `export` there commits a machine-specific value.

When testing what a machine deploys, set its list explicitly:

```sh
MISE_ENV=desktop,dev mise bootstrap dotfiles status
```

Check every machine you might have affected, not just this one.

**A template must never branch on `get_env(name="MISE_ENV")`.** mise resolves
the layers from `miserc.toml`, but Tera reads the process environment, which an
apply from a LaunchAgent, cron job or agent shell does not have — so the
template silently renders as if unclassed. `starship.toml.tera` lost its
`$gcloud` segment that way, and `status` disagreed with `apply` until it was
found. Gate on the fact (`{% if vars.x is defined %}`), per the placement rule
below; `$gcloud` needed no gate at all, since starship renders it empty where
gcloud is unconfigured.

## Rule: a layer owns its tools, dotfiles and agents

A capability's `[tools]`, `[dotfiles]` and LaunchAgents go together in its
`config.<layer>.toml`, which loads only where miserc lists that layer. Before
layers, `[dotfiles]` filtered entries with `variants = [{ profile = "bryan" },
...]` lists kept in step by hand with each class file's tool list — and a
config reaching a machine its tool did not was the bug that shipped twice.

Do not bring `variants` back as a membership filter. They select *one*
alternative, so an entry whose variants match two active layers is dropped:

```
mise WARN  [dotfiles]."~/.config/ghostty": ambiguous dotfile variants, ignoring entry
```

That is exactly what `env = ["desktop", "dev"]` does to an entry listing both.

A new layer file is itself a dotfile. `~/.config/mise` is `symlink-each`, so
mise does not see `config.<layer>.toml` until an apply links it. Create the
layer, apply, and only then move tools out of the file that declared them —
in the other order they drop off PATH mid-session, because the file that now
declares them is not loaded yet.

Prove a restructure identical rather than eyeballing it: for each machine's
layer list, diff `mise bootstrap dotfiles status`, `mise ls --current` and
`mise bootstrap macos launchd-agents status` before and after.

## Rule: a `[dotfiles]` entry needs an operation, or it is silently dropped

An entry carrying only `variants` is ignored with a warning that is easy to
scroll past:

```
mise WARN  [dotfiles]: "~/.config".ghostty: no recognized operation
           (block, source, or line), ignoring entry
```

An empty table (`"~/.zshenv" = {}`) is fine — mirroring resolves the source. A
table with `variants` and nothing else is **not**. Give it an explicit
`mode = "symlink"`.

After editing the table, confirm the entry count actually changed:

```sh
for e in desktop,dev,backup,bryan desktop,dev desktop,backup,irene server vyos; do
  printf '%-26s %s\n' "$e" "$(MISE_ENV=$e mise bootstrap dotfiles status 2>/dev/null | grep -cE '^~/')"
done
```

A silent drop and a deliberate exclusion look identical in `status`. The count
is the only thing that catches it.

## Rule: mise's own config cannot be templated

`.config/mise/config.toml` is parsed as TOML *before* Tera runs. Conditionals
in it are a parse error, not a no-op:

```
{% if env.MISE_ENV == "desk" %}
| ^ invalid key-value pair, expected key
```

Per-layer differences go in `.config/mise/config.<layer>.toml`, which mise
layers over the base. That is the only mechanism — there is no single-file
conditional for `[tools]`.

## Rule: deployed files are symlinks, and some tests reject symlinks

Most files here arrive at their target as a symlink, not a regular file. Any
check that distinguishes the two changes meaning after deployment.

The one that already bit: zsh's `.` glob qualifier means *regular file*, and a
symlink is not one. `.zshrc` used to load its fragments with

```zsh
for file ($ZDOTDIR/[0-9]*.zsh(N.)) source $file      # matched 1 of 9
```

That works only while the fragments are regular files. They are symlinks, so
the glob matched nothing, every fragment silently stopped loading, and the
shell lost zim, mise activation, aliases and its prompt — with no error at all.
The fix is `-`, which resolves the symlink before testing:

```zsh
for file ($ZDOTDIR/[0-9]*.zsh(N-.)) source $file     # matches 9 of 9
```

Shell `-f`/`-d` tests and Lua `vim.uv.fs_stat` already follow symlinks and are
fine. Watch for `fs_lstat`, `find -type f` without `-L`, and zsh qualifiers
`.`, `/`, `@`.

When a config stops working after deployment but throws no error, suspect this
before anything else.

## Rule: never apply over an existing directory symlink

Applying `symlink-each` to a path that is already a whole-directory symlink
makes mise follow the link and link each file onto its own path. Files become
symlinks to themselves and their contents are destroyed. This happened to
`.config/herdr/config.toml`; only the git commit made it recoverable.

Remove the old link first, then apply:

```sh
rm ~/.config/<dir>          # the stale symlink, not its contents
mise bootstrap dotfiles apply -f
```

Deleting that symlink also removes anything a running daemon keeps inside it,
including live sockets. herdr's server survives but becomes unreachable until
restarted.

## Rule: verify rendered templates, not just the template text

Tera trim markers (`{%-`, `-%}`) silently concatenate lines, same hazard as Go
templates. In line-oriented files use `{%- if … %}` (trim before, keep after).

After editing any `.tera`, render it and read the result rather than trusting
the source:

```sh
mise bootstrap dotfiles diff    # shows rendered output, applies nothing
```

Templates may execute while mise is merely *checking* state, so keep them free
of side effects.

## Rule: uv owns Python; mise only installs uv and activates the venv

direnv is gone. `.config/direnv/direnvrc` carried a `layout_uv` that created
and exported a `.venv` on `cd`; `python.uv_venv_auto = "source"` in
`config.toml` does the same thing with no second tool and no shell hook. Do not
reintroduce direnv for Python.

Auto-activation keys off **`uv.lock`**, not `mise.toml` and not the presence of
`.venv`. A directory holding only a venv activates nothing. That is why the
presets run `uv init` + `uv add` rather than stopping at a config file.

Never pin the interpreter in two places. The cookbook's project config lists
`python = "3.12"` alongside `uv`, and that was wrong here the first time it
ran: mise reported 3.13 while the venv uv built was 3.14. uv resolves the
interpreter from `requires-python` in `pyproject.toml`, so the generated
`mise.toml` declares `uv` and stays out of it. A repo that must pin gets a
`.python-version`, which uv reads natively — `uv python pin` is what writes it,
and note `uv init --bare` does *not*.

**Do not add `"python"` to `idiomatic_version_file_enable_tools`.** It looks
like it only teaches mise to respect that pin, but a version file mise honours
is a version file mise *installs for*, which is the second place all over
again. It never appeared in any `[tools]`, so the damage was invisible: seven
`.python-version` files under `~/src` had quietly pulled down 133M of mise
interpreters that no config requested and `mise ls python` reported as
`"active": false`. `~/src/projects/cll` resolved to mise's 3.13.15 while its
venv ran uv's 3.13.2 — the exact split this rule exists to prevent.

The tell is the shims. Installing python populates `~/.local/share/mise/shims`
with `python`, `python3`, `pip`, `pip3`…, and with no version set globally each
one fails:

```
$ python --version
mise ERROR No version is set for shim: python
```

That broke `uv python list`, which probes interpreters on PATH. It stayed
hidden because `python3` finds `/usr/bin/python3` to fall back to and silently
answers 3.9.6, while bare `python` has nothing and hard-errors. After removing
the setting and the orphans, `python` is correctly not found: there is no
global interpreter here by design, and `uv run` is how you get one.

Tooling splits by what imports project code:

| | where | why |
|---|---|---|
| pytest, ty | project dev group | imports your code, conftest, plugins |
| ruff | **both** | static binary; global copy serves the editor LSP and scratch dirs, project pin keeps `mise run lint` honest in CI |
| uv, watchexec | global + project `[tools]` | global for daily use, declared per project so a fresh clone can run the tasks |

`uv format` downloads its *own* Ruff and ignores both copies. Use `ruff format`
or `uv run ruff format`, not `uv format`, unless you pin `--version`.

## Rule: `copier.yml` belongs at the repo root, or updates are impossible

This repo is a copier template as well as a dotfiles source. The layout is
forced, not aesthetic:

```
copier.yml                  # questions + _subdirectory: ".config/copier/{{ kind }}"
.config/copier/python/      # *.jinja files for that stack
.config/copier/rust/
```

copier reads a template's version from the git repo its `copier.yml` sits in.
Point it at a *subdirectory* and generation still works, but the answers file
records no `_commit`, and every later update dies with "Cannot update because
cannot obtain old template references". A root `copier.yml` with a templated
`_subdirectory` is what keeps every stack in this one repo and still updatable.
There are no version tags here, so copier falls back to HEAD and says so on
every run — harmless.

Things that cost a debugging round each:

- Only files ending `.jinja` are rendered. A plain `mise.toml` copies through
  with `{{ project_name }}` intact.
- The answers file only exists if the template ships
  `{{ _copier_conf.answers_file }}.jinja`. No answers file, no update.
- `_tasks` run on **update** as well as copy — copier does not distinguish.
  Every one must be idempotent, hence `test -f pyproject.toml || uv init …`.
  Unguarded, `preset:update` dies with "Project is already initialized".
- Pass the destination as `"$PWD"`, never `.`, or `_copier_conf.dst_path.name`
  renders empty and `cargo init --name ''` fails.
- Generated GitHub workflows must avoid `${{ }}`, or wrap it in `{% raw %}`.
  Jinja eats it otherwise.
- `_src_path` in a generated project is this machine's absolute path. Rewrite
  it before publishing a project repo if `/Users/<name>` should not be public.

The wrapper tasks in `.config/mise/tasks/preset/` stay thin — arg parsing via
`#USAGE` specs, then `uvx copier`. `#MISE dir="{{cwd}}"` is load-bearing there:
without it a global task runs in `~/.config/mise` and scaffolds the dotfiles
repo. A new task file needs `chmod +x`, a `mise bootstrap dotfiles apply`, and
a one-time `mise trust <path>`.

Keep the generated task names identical across stacks — `sync fmt lint test fix
check build watch`. Uniformity across ecosystems is the entire reason they wrap
commands that are already short; a task that only aliases `uv sync` in one repo
is not worth its line. For the same reason they belong in the generated project
config, never as global tasks: a global `sync` is live in every directory,
including the ones that are not projects.

Anything a task shells out to goes in the generated `[tools]`, or it works only
on the machine that wrote it. `cargo-nextest` was installed but declared in no
config, so `mise run test` died on `No version is set for shim`. `cargo nextest
run` also exits non-zero on an empty suite — `--no-tests=pass`, or a fresh
project fails its own gate.

Hooks are hk, not prek and not pre-commit. `hk.pkl` is Pkl, and the two
`package://` URLs in it pin the hk version — bumping hk means editing both,
then `mise run preset:update` per project. `hk install` writes the git shim.

The generated `mise.toml` pins `hk` to that same *major*. It used to float on
`latest` while the Pkl stayed on 1.58.1, so the day mise installed hk 2 every
generated config failed `hk validate` with "union property 'command' has no
selected default" — a pre-commit hook that errors on every commit. A bump
touches four places together: `common.pkl`, both templates' `hk.pkl.jinja`,
and the major in both `mise.toml.jinja`.

The reason it is not prek: hk's steps carry read/write effects, so it schedules
them in parallel with file locks, and the same definitions run as `hk check`
and `hk fix` from the terminal or CI rather than only as a hook. It also has
`hk test` for step-defined tests, `hk validate`, profiles, `--format json`, and
`hk mcp`. Pre-commit ecosystem compatibility, prek's advantage, is not wanted
here.

`hk builtins` lists the available steps. They call bare binaries — `ruff`,
`cargo` — resolved from PATH, and git runs hooks directly rather than through
mise, so never assume an activated `.venv` inside `hk.pkl`.

The step lists live in `.config/hk/common.pkl`, which generated projects import
over https from `raw.githubusercontent.com/bryan824/dotfiles/main/...` rather
than copying. Editing that file and pushing changes hooks in every project at
once, which is the entire reason it exists — do not "fix" it by inlining the
steps back into a template. Consequences to respect:

- It is live and unversioned (`main`). A broken push breaks hooks everywhere,
  so run `hk validate` in a generated project before pushing a change to it.
  A project that must not move pins a commit SHA in its own import URL.
- This file is **not** deployed by `[dotfiles]`. It is consumed over https by
  other repos, so it needs no entry — and adding one would put an unrelated
  `~/.config/hk` on every machine.
- raw.githubusercontent serves it with `max-age=300`, so a push takes up to
  five minutes to reach hooks.
- The hk version pinned in `common.pkl` must match the one a project's `hk.pkl`
  amends. Two versions means two `Config.Step` types and Pkl rejects the
  mapping outright.
- Local-path imports (`file:///Users/...`) work but are machine-specific and
  break for any other checkout. https is what makes it portable.

The division of labour: hk handles per-file incremental work on staged files;
`mise run check` stays the whole-project gate that CI runs, tests included.
Do not make CI run both.

## Rule: completions are generated per machine, never committed

Most CLIs here ship no `_<tool>` file anywhere zsh looks, so tab completion for
them fails silently. `mise run shell:completions` fills `$ZDOTDIR/completions`
from the tools that print a completion script and the ones whose release
archive ships one mise unpacks but never links. That directory sits inside
`~/.config/zsh`, a real directory under `symlink-each`, so nothing reaches this
repo.

Add a tool there, not to `40_tools.zsh`: an fpath file is autoloaded on the
first tab press, a sourced init runs in every shell. `40_tools.zsh` is only for
integrations that must be sourced.

`up.sh` reruns the task after upgrades and clears `$ZDOTDIR/zsh-evalcache` —
`_evalcache` keys on the command string rather than the binary, so it otherwise
serves a stale init forever. Clear it by that path, not `$ZSH_EVALCACHE_DIR`:
zim's evalcache module defaults that variable to `~/.zsh-evalcache`, so a
script sourcing `init.zsh` reads the wrong directory and silently clears
nothing.

## Rule: no PII, no secrets in this repo

Machine identity lives in `~/.config/mise/config.local.toml`, which is outside
this repo and never committed:

```toml
[vars]
git_name  = "…"
git_email = "…"
```

Reference it as `{{ vars.git_name }}` in a `.tera`. Never inline a name, email,
token or key as plaintext in a tracked file. Read it from the environment, as
`ipinfo` does with `$IPINFO_TOKEN` in `.config/zsh/60_aliases.zsh`, and supply
that variable age-encrypted per the rule below.

Sweep before pushing:

```sh
grep -rInE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' --exclude-dir=.git .
grep -rInE '(secret|token|api[_-]?key|password)\s*[:=]' --exclude-dir=.git .
```

## Rule: servers are pushed to, never pulled from

`config.server.toml` sets `history.enabled = false` so a VPS never publishes
local drift back here. Do not enable history for the `server` class. Fleet
changes go out with `mise bootstrap remote`, always previewed with `--dry-run`.

## Rule: secrets are age-encrypted, never plaintext

No credential is ever committed in the clear. There are two places for one:

**Shared across machines** — age-encrypted inline in a layer config:

```sh
mise set -g --age-encrypt --prompt SOME_TOKEN
```

That writes `SOME_TOKEN = { age = "<base64>" }` into `~/.config/mise/config.toml`
and mise decrypts it into the shell at runtime. Use `--prompt` so the value
never enters shell history.

**Always pass `--age-recipient` explicitly.** Left to itself mise encrypts to
every identity it can find, which here silently added `~/.ssh/id_ed25519`
alongside the age key — a second key that opens every secret, easy to miss
because the ciphertext is opaque:

```sh
mise set -g --age-encrypt --prompt \
  --age-recipient "$(age-keygen -y ~/.config/mise/age.txt)" SOME_TOKEN
```

To audit what a stored value can be opened by, decode its recipient stanzas:

```sh
grep '^SOME_TOKEN' config.toml | sed -E 's/.*age = "([^"]*)".*/\1/' \
  | base64 -d | grep '^-> '
```

Expect one `-> X25519` line. A `-grease` line is age's random decoy, not a
recipient. Any `-> ssh-ed25519` line is a real second key.

**Machine-specific** — `~/.config/mise/config.local.toml`, which is outside
this repo entirely. See the placement rule below for what belongs there.

Two placement traps:

- `mise set -g` always writes to `config.toml`, which **every** machine loads.
  A machine without the key then fails outright, because `age.strict` defaults
  to true. For a secret only some machines need, generate it with `-g` and
  move the line into the layer or person file (`config.<layer>.toml`) by hand.

  Do **not** reach for `mise set -g -E <layer>`. It does not write the global
  overlay; it drops a `mise.<layer>.toml` *project* config in the current
  directory. Run from `~`, that file then loads for that layer on every
  command, silently shadowing the real config. Check for strays with
  `mise config ls`, which lists every file actually loaded.
- `[vars]` and `[env]` are not interchangeable. `[vars]` is readable only by
  `.tera` templates and is never exported; `[env]` is exported to the shell but
  invisible to templates.

mise's `[history.encryption]` is a different feature — it encrypts the history
stream into a separate repository with its own origin, not per-value inline.
Do not reach for it without deciding deliberately.

## Rule: per-machine values belong in `config.local.toml`, not a layer config

Four places a value can live, and the axis that decides:

| Value varies by | Goes in |
|---|---|
| nothing | `config.toml` |
| capability or person | `config.<layer>.toml` |
| **the individual machine** | `~/.config/mise/config.local.toml` (uncommitted) |
| being a secret shared across machines | age-encrypted in a layer config |

The trap is using a layer for a machine fact because only one machine lists
that layer today. `80_host.zsh.tera` did exactly that: it gated
a `TALOSCONFIG` path on `MISE_ENV == "bryan"`, so a second `bryan` machine
would export a path to a checkout it does not have — and the personal directory
layout sat in a public repo. It now reads `vars.talosconfig` and renders empty
where that is unset.

Write every such template with `{% if vars.x is defined %}`, never a bare
reference. Opt-in means a fresh machine renders an empty section instead of
failing, which is what makes the file safe to leave unset.

Things that belong there and are easy to misfile:

- git identity (`git_name`, `git_email`) — already there
- checkout paths that differ per machine (`talosconfig`)
- `[bootstrap.remote.hosts]` — hostnames, SSH users, key paths and tags for the
  fleet. The README documents `mise bootstrap remote --tag vps`, and that
  inventory is network detail that must not be committed.

`[vars]` is template-only. A value the *shell* needs is `[env]`, and one that
both need has to be written twice.
