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

Four classes: `bryan`, `work`, `irene`, `server`. Nothing is designed to work
with `MISE_ENV` unset — unset silently behaves like a stripped-down `server`,
loading 12 tools instead of 37 and skipping every desktop dotfile.

The class is pinned per machine in `~/.config/mise/miserc.toml`, which is not
managed by this repo:

```toml
env = ["bryan"]
```

Do not set it from a shell rc instead. `~/.zshenv` and `~/.config/zsh/*` are
symlinks into this repo, so an `export` there commits a machine-specific value.

When testing what a class deploys, set it explicitly:

```sh
MISE_ENV=server mise bootstrap dotfiles status
```

Check every class you might have affected, not just this machine's.

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
for e in bryan work irene server; do
  printf '%-7s %s\n' "$e" "$(MISE_ENV=$e mise bootstrap dotfiles status 2>/dev/null | grep -cE '^~/')"
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

Per-class differences go in `.config/mise/config.<class>.toml`, which mise
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

## Rule: no PII, no secrets in this repo

Machine identity lives in `~/.config/mise/config.local.toml`, which is outside
this repo and never committed:

```toml
[vars]
git_name  = "…"
git_email = "…"
```

Reference it as `{{ vars.git_name }}` in a `.tera`. Never inline a name, email,
token or key into a tracked file — read it from the environment instead, as
`ipinfo` does with `$IPINFO_TOKEN` in `.config/zsh/60_aliases.zsh`.

Sweep before pushing:

```sh
grep -rInE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' --exclude-dir=.git .
grep -rInE '(secret|token|api[_-]?key|password)\s*[:=]' --exclude-dir=.git .
```

## Rule: servers are pushed to, never pulled from

`config.server.toml` sets `history.enabled = false` so a VPS never publishes
local drift back here. Do not enable history for the `server` class. Fleet
changes go out with `mise bootstrap remote`, always previewed with `--dry-run`.

## Rule: secrets do not live in this repo

Nothing tracked here is encrypted, and nothing tracked here should need to be.
Credentials belong in the environment or in `~/.config/mise/config.local.toml`,
which is outside this repo.

If encrypted state ever becomes necessary, note that mise's
`[history.encryption]` is not a per-file `.age` scheme — it encrypts the
history stream into a separate repository with its own origin. Decide that
deliberately rather than reaching for it.
