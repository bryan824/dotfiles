# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

This repository contains shell, editor, terminal, Git, Nix, and developer-tool configuration. Chezmoi templates prompt for machine-specific values such as Git identity and user profile, then render files into `$HOME`.

## What's included

- **chezmoi**: source templates and first-run prompts in `.chezmoi.toml.tmpl`
- **zsh**: XDG-based shell setup, Zim modules, deferred plugin loading, aliases, exports, keybindings, and functions
- **mise**: version-managed CLI tools such as `node`, `neovim`, `ripgrep`, `starship`, `kubectl`, and `pi`
- **Git**: templated user identity and global ignore rules
- **Terminals**: Ghostty, Kitty, WezTerm, and Zellij configuration
- **Editors**: Neovim/LazyVim configuration
- **macOS**: AeroSpace window manager and nix-darwin configuration
- **CLI tools**: Starship, ripgrep, direnv, television, k9s, rustfmt, and related configs

## Bootstrap

Install chezmoi, then apply these dotfiles:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply bryan824/dotfiles
```

During first apply, chezmoi asks for:

- `gitName`: full name for Git commits
- `gitEmail`: email address for Git commits
- `whoami`: profile selector, for example `bryan`

Those values feed templates such as Git config and mise tool selection.

## Daily use

Preview changes before applying:

```sh
chezmoi diff
```

Apply current source state:

```sh
chezmoi apply
```

Edit a managed file:

```sh
chezmoi edit ~/.config/zsh/.zshrc
chezmoi apply
```

Add a new managed file:

```sh
chezmoi add ~/.config/example/config.toml
```

Update from GitHub and apply:

```sh
chezmoi update
```

## Local development

Clone source directly when working on repository changes:

```sh
git clone https://github.com/bryan824/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
chezmoi diff
```

After changing files, run:

```sh
chezmoi diff
chezmoi apply
```

## Repository layout

Chezmoi source names map to home-directory targets:

- `dot_zshenv` -> `~/.zshenv`
- `dot_config/zsh/` -> `~/.config/zsh/`
- `dot_config/git/config.tmpl` -> `~/.config/git/config`
- `dot_config/mise/config.toml.tmpl` -> `~/.config/mise/config.toml`
- `dot_config/nixpkgs/` -> `~/.config/nixpkgs/`

See chezmoi's source-state docs for full filename mapping rules.

## Notes

- Shell startup uses `ZDOTDIR=~/.config/zsh` from `.zshenv`.
- Zsh plugins are managed by Zim and several plugin hooks are deferred for faster startup.
- `mise` shims are prepended to `PATH` so managed tools take priority.
- Some templates are host-, user-, or architecture-aware.
