# Verification

This is a dotfiles source repo, not a generated Python or Rust project.
There is no root test task or root GitHub Actions workflow. The workflows under
`.config/copier/` belong to generated projects. See [README.md](../README.md)
for deployment commands and [AGENTS.md](../AGENTS.md) for deployment hazards.

## Checks

| Command | Evidence and limit |
|---|---|
| `git diff --check` | Checks whitespace in tracked changes. Does not inspect untracked contents or validate configuration behavior. |
| `MISE_ENV=desktop,dev mise bootstrap dotfiles status --verbose` | Lists all selected entries, their source config and local deployment state. Set each affected machine's layers explicitly. This inspects the local host, not that machine. |
| `MISE_ENV=desktop,dev mise bootstrap dotfiles diff <target>` | Previews the rendered deployment without applying it. Read the rendered output after changing a `.tera` file. Templates may execute functions during checks; keep them free of side effects. |
| `mise bootstrap dotfiles add --dry-run --path <layer-config> --mode <mode> <target>` | Previews capture and registration of a live file. Does not prove the application follows a deployed symlink. |
| `for f in .config/mise/tasks/preset/*; do bash -n "$f" || exit 1; done` | Checks Bash syntax in each preset wrapper. Does not run Copier or its generated tasks. |
| `zsh -n .config/mise/tasks/shell/completions` | Checks the completion task's syntax. Does not regenerate completions or test individual tools. |

The global ignore source, `.config/git/ignore`, intentionally contains two
literal carriage returns after `Icon`. Git removes one when reading the pattern;
the other matches Finder's special filename. A root-commit whitespace check
flags this line. Preserve it; its surrounding comment explains why.

After changing layer membership, check every machine profile. Use `--verbose`
when comparing entry counts; the default output omits entries already applied.

```sh
for e in desktop,dev,backup,bryan desktop,dev desktop,backup,irene server vyos; do
  printf '\n--- %s ---\n' "$e"
  MISE_ENV=$e mise bootstrap dotfiles status --verbose
done
```

For a layer restructure, also compare `mise ls --current` and
`mise bootstrap macos launchd-agents status` before and after for each profile,
as required by `AGENTS.md`. A local preview does not verify remote deployment.

For Copier or shared hk changes, use a separately authorized generated project.
Run its `mise run check`; run `hk validate` when changing the shared hk config.
Do not scaffold into this repo to test the presets.

## Project memory

Confirm both adoption documents exist, that `context/` is effectively ignored,
and that no working records are tracked:

```sh
test -f docs/memory.md && test -f docs/verification.md
git check-ignore -v context/probe
git ls-files -- context/
```

The last command must produce no output to establish that no records are
currently tracked. An ignore rule does not untrack files or erase Git history.
At adoption, `/context/` is ignored by the global Git ignore file, not this
repo's `.gitignore`. Recheck on another machine before writing working records.
