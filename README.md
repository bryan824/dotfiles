# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

This repo configures shell, editor, terminal, Git, Nix, and developer tools
across multiple machines and users. Chezmoi templates select which files to
deploy and which tool versions to install based on **profile** (who uses the
machine) and **role** (the machine's purpose).

## Profiles & roles

On first apply, chezmoi prompts for two variables that control everything:

| Variable | Values | Purpose |
|----------|--------|---------|
| `profile` | e.g. `bryan` — anything else is treated as non‑technical | Who owns this machine |
| `role` | `personal` or `work` | What the machine is used for |

What each combination gets:

| Config | `profile=bryan` `role=personal` | `profile=bryan` `role=work` | `profile=*` (non‑technical) |
|--------|-------------------------------|----------------------------|--------------------------------|
| zsh, git, starship, ripgrep, mise (base tools) | ✅ | ✅ | ✅ |
| Terminal configs (kitty, ghostty, wezterm) | ✅ | ✅ | ✅ |
| neovim, direnv, television, bat, bottom | ✅ | ✅ | ✅ |
| pi agents & skills setup | ✅ | ✅ | ✅ |
| k9s, helm, kubectl, kustomize, duckdb, tokei | ✅ | ✅ | — |
| talosctl, cilium-cli, supabase, agent-browser | ✅ | — | — |
| Google Cloud SDK & starship gcloud module | — | ✅ | — |
| nix-darwin configuration | ✅ | — | — |
| zellij | ✅ | ✅ | — |

File-level exclusion is handled in `.chezmoiignore`; tool-level differences
are handled in `dot_config/mise/config.toml.tmpl`.

## Bootstrap

If the age key is already installed, bootstrap in one step:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply bryan824/dotfiles
```

If you still need to install the age key, run `init` first, then follow
[Encryption](#encryption), then run `chezmoi apply`.

During first apply, chezmoi asks for `profile`, `role`, `gitName`, and
`gitEmail`. These values are saved locally and never prompt again.

## Encryption

Some source files are checked in as age-encrypted `encrypted_*.age` files,
for example `encrypted_dot_kopiaignore.tmpl.age`. The recipient is configured
in `.chezmoi.toml.tmpl`; the matching private key must exist locally at
`~/.config/chezmoi/key.txt` and is never committed.

For first setup on a machine that needs encrypted files:

```sh
mkdir -p ~/.config/chezmoi
$EDITOR ~/.config/chezmoi/key.txt   # paste the age identity here
chezmoi init bryan824/dotfiles
chezmoi apply
```

If the key is already in place, `chezmoi init --apply bryan824/dotfiles` works
as a one-liner.

For normal interactive edits, use `chezmoi edit` on the target path. Chezmoi
will decrypt to a private temp dir, open your editor, then re-encrypt on save
and exit:

```sh
chezmoi edit ~/.kopiaignore
# or edit + apply in one step
chezmoi edit --apply ~/.kopiaignore
```

If you need a manual or scripted workflow, you can still decrypt and
re-encrypt explicitly:

```sh
chezmoi age decrypt encrypted_dot_kopiaignore.tmpl.age -o /tmp/kopiaignore
$EDITOR /tmp/kopiaignore
chezmoi age encrypt -o encrypted_dot_kopiaignore.tmpl.age /tmp/kopiaignore
rm /tmp/kopiaignore
```

Add a new encrypted file to the source state:

```sh
chezmoi add --encrypt ~/.config/my-secret-file
```

On `chezmoi apply`, chezmoi decrypts `.age` source files transparently to
their target paths.

## Daily use

```sh
chezmoi diff       # preview pending changes
chezmoi apply      # apply current source state
chezmoi update     # pull from GitHub and apply
chezmoi edit ~/.config/zsh/.zshrc   # edit a managed file
chezmoi add ~/.config/new.toml       # add a new file to management
```

## Local development

```sh
git clone https://github.com/bryan824/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
# edit files, then:
chezmoi diff
chezmoi apply
```

## Repository layout

```
.chezmoi.toml.tmpl         # prompts for profile, role, git identity
.chezmoiignore             # excludes files per profile (template)
|
dot_zshenv                 # ~/.zshenv — sets ZDOTDIR
dot_config/zsh/            # ~/.config/zsh/ — numbered zsh startup fragments + Zim
dot_config/git/config.tmpl # ~/.config/git/config — templated name/email
dot_config/mise/config.toml.tmpl  # ~/.config/mise/config.toml
dot_config/starship.toml.tmpl     # ~/.config/starship.toml
dot_config/kitty/          # terminal config
dot_config/ghostty/        # terminal config
dot_config/wezterm/        # terminal config
dot_config/nvim/           # neovim / LazyVim
dot_config/nixpkgs/        # nix-darwin (Bryan personal hosts only)
dot_config/k9s/            # Kubernetes TUI
dot_config/television/     # file finder
dot_config/direnv/         # direnv config
dot_config/ripgrep/        # ripgrep config
dot_config/aerospace/      # macOS window manager
run_after_90-agent-skills.sh  # post-apply script that installs remote agent skills
```

Chezmoi source names map to home directory targets:
- `dot_` prefix → `.` (e.g. `dot_zshenv` → `~/.zshenv`)
- Files under `dot_config/` → `~/.config/`
- `private_` prefix → `600` permissions (used for k9s secrets)
- `.tmpl` suffix → processed as Go template before deployment

## Notes

- Shell startup uses `ZDOTDIR=~/.config/zsh` from `.zshenv`.
- Zsh startup fragments are numbered by dependency: environment/PATH, options,
  mise activation, functions, aliases, then keybindings.
- Zsh plugins are managed by Zim; slow hooks are deferred for fast startup.
- Interactive zsh uses `mise activate zsh` before aliases/completions, so
  mise-managed tools are exposed by real install paths rather than shims.
- Templates are profile‑, role‑, and architecture‑aware.
- Agent skills are not vendored in this repo; `chezmoi apply` runs
  `run_after_90-agent-skills.sh`, which installs the remote GitHub skills with
  `npx skills` into the global agent skill directories.
- See [Encryption](#encryption) for age key setup, editing encrypted source
  files, and adding new encrypted files.
