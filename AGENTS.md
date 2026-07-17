# Agent instructions for this repo

This directory is a **chezmoi source repo**, not a live config directory. Files here
generate the actual dotfiles under the user's home directory (e.g. `~/.config/...`,
`~/.zshrc`). Chezmoi source uses prefixes/suffixes that get stripped on apply:

- `dot_foo` -> `.foo`
- `dot_config/bar/baz.toml.tmpl` -> `~/.config/bar/baz.toml` (rendered as a template)

## Rule: fix the source, not just the live file

If a task involves editing a config that chezmoi manages (mise, shell rc, app configs,
etc.), do not just edit the live file under `~/.config` or `$HOME` — that edit does not
persist and will be silently reverted on the next `chezmoi apply`.

1. Find the source counterpart in this repo (watch for `dot_` prefix / `.tmpl` suffix).
2. Edit the source file. If you tested a fix live first, mirror the change back into source.
3. Before calling the task done, run `chezmoi apply` so the generated destination state reflects your source changes.
4. Then run `chezmoi diff` (scope it to the touched path if the repo has unrelated pending drift) and confirm no drift remains for the files you touched.
