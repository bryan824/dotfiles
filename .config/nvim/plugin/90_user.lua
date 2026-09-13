-- Personal layer. MiniMax's plugin/10..40 files are sourced before this file.

local user_mini = require('user.mini')

-- `mini.starter` is configured by MiniMax during the immediate startup phase,
-- so replace that configuration immediately as well.
user_mini.setup_starter()

-- MiniMax queues these modules with Config.later(). Queue the personal setup
-- after all upstream callbacks so these settings are authoritative.
Config.later(user_mini.setup_later)
Config.later(function()
  require('user.plugins').setup()
end)

vim.api.nvim_create_user_command('MiniMaxUpdate', function()
  vim.pack.update({ 'MiniMax' })
end, {
  desc = 'Update MiniMax upstream',
})

-- Personal mapping extracted from plugin/20_keymaps.lua.
vim.keymap.set('n', '<Leader>gb', '<Cmd>vertical Git blame -- %<CR>', {
  desc = 'Blame buffer',
})

-- Keep MiniFiles useful with the layered layout.
Config.new_autocmd('User', 'MiniFilesExplorerOpen', function()
  MiniFiles.set_bookmark('m', Config.minimax_config, { desc = 'MiniMax upstream' })
end, 'Add MiniMax bookmark')

-- Replace MiniMax's edit-config mappings, whose original targets assume the
-- upstream files live directly inside stdpath('config').
local config_root = vim.fn.stdpath('config')
local edit = function(path)
  return function()
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
end
local view = function(path)
  return function()
    vim.cmd.view(vim.fn.fnameescape(path))
  end
end
local map_edit = function(suffix, action, desc)
  vim.keymap.set('n', '<Leader>e' .. suffix, action, { desc = desc })
end

map_edit('i', edit(config_root .. '/init.lua'), 'Local init')
map_edit('k', edit(config_root .. '/plugin/90_user.lua'), 'Local keymaps')
map_edit('m', edit(config_root .. '/lua/user/mini.lua'), 'Local MINI config')
map_edit('o', view(Config.minimax_config .. '/plugin/10_options.lua'), 'Upstream options')
map_edit('p', edit(config_root .. '/lua/user/plugins.lua'), 'Local plugins')
