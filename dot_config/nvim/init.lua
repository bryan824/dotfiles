-- A thin, standalone layer over MiniMax.
--
-- MiniMax itself is managed by Neovim 0.12's built-in `vim.pack`. This keeps
-- chezmoi optional: copying this directory to `~/.config/nvim` is enough.

local minimax_root

vim.pack.add({
  {
    src = 'https://github.com/nvim-mini/MiniMax',
    name = 'MiniMax',
    version = 'main',
  },
}, {
  confirm = false,
  -- MiniMax is a config repository, not a normal plugin. Capture its managed
  -- path without sourcing anything from the repository root.
  load = function(data)
    minimax_root = data.path
  end,
})

if minimax_root == nil then
  error('vim.pack did not return the MiniMax installation path')
end

local minimax_config = minimax_root .. '/configs/nvim-0.12'
local minimax_init = minimax_config .. '/init.lua'

if vim.uv.fs_stat(minimax_init) == nil then
  error('MiniMax nvim-0.12 config was not found at: ' .. minimax_init)
end

-- MiniMax plugin files are sourced before this config's plugin/90_user.lua.
-- Its `after/` tree must be a separate, final runtimepath entry so the
-- upstream ftplugin/LSP/snippet overrides retain normal Neovim semantics.
vim.opt.runtimepath:prepend(minimax_config)
vim.opt.runtimepath:append(minimax_config .. '/after')

dofile(minimax_init)

-- Paths used by the local layer.
Config.minimax_root = minimax_root
Config.minimax_config = minimax_config
