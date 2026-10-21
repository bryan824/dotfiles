# Standalone MiniMax layer

This directory is a complete `~/.config/nvim`. It requires **Neovim 0.12**,
**Git**, and network access for the first installation. No dotfile manager is
required.

## Install standalone

```sh
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null || true
cp -a nvim ~/.config/nvim
nvim
```

On first launch, Neovim's built-in `vim.pack` installs MiniMax and the plugins
recorded in `nvim-pack-lock.json`.

## Optional mise use

In this dotfiles repo the folder lives at `.config/nvim` and mise links it into
place. `nvim-pack-lock.json` is deployed in copy mode, because `vim.pack`
rewrites it — pull updated revisions back with:

```sh
mise bootstrap dotfiles add --changed
```

There is no template, hook, or dotfile-manager runtime dependency here.
Removing mise later does not affect Neovim.

## Update

Update only the MiniMax base with Neovim's native package command:

```vim
:packupdate MiniMax
```

Review the update buffer, use `:write` to accept it, then restart Neovim.
Use `:packupdate` without a name to review updates for MiniMax and all plugins.

The first launch adds a `MiniMax` entry to `nvim-pack-lock.json`. Commit the
resulting lockfile so new machines install the same revision.

## Ownership

MiniMax owns its checkout under Neovim's package directory. This folder owns
only the downstream layer:

- `lua/user/mini.lua`: `mini.starter`, `mini.git`, `mini.keymap`, and
  `mini.pick` customizations extracted from the old `plugin/30_mini.lua`.
- `lua/user/plugins.lua`: Lua formatting through StyLua, extracted from the old
  `plugin/40_plugins.lua`.
- `plugin/90_user.lua`: the custom `<Leader>gb` mapping, local wiring, and edit
  mappings adapted to the layered layout.
- `.stylua.toml`: the existing personal StyLua settings.
- `snippets/global.json`: retained locally because MiniMax explicitly loads it
  from `stdpath('config')`.
- `nvim-pack-lock.json`: reproducible revisions managed by `vim.pack`.

Files that matched MiniMax upstream are intentionally not copied: options,
upstream mappings, the remaining MINI setup, Markdown ftplugin, Lua LSP example,
and Lua snippet example are loaded directly from the managed MiniMax checkout.

## Useful edit mappings

- `<Leader>ei`: local wrapper `init.lua`
- `<Leader>ek`: local mappings and wiring
- `<Leader>em`: local MINI customizations
- `<Leader>eo`: view upstream options
- `<Leader>ep`: local non-MINI plugin customizations

Inside `mini.files`, bookmark `'m` opens the managed MiniMax config.
