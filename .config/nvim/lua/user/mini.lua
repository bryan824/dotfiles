local M = {}

function M.setup_starter()
  local starter = require('mini.starter')

  starter.setup({
    evaluate_single = true,
    items = {
      starter.sections.builtin_actions(),
      starter.sections.recent_files(10, false),
      starter.sections.recent_files(10, true),
      starter.sections.sessions(5, true),
    },
    content_hooks = {
      starter.gen_hook.adding_bullet(),
      starter.gen_hook.indexing('all', { 'Builtin actions' }),
      starter.gen_hook.padding(3, 2),
    },
  })
end

local setup_git = function()
  local align_blame = function(au_data)
    if au_data.data.git_subcommand ~= 'blame' then return end

    local win_src = au_data.data.win_source
    vim.wo.wrap = false
    vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
    vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })
    vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
  end

  Config.new_autocmd(
    'User',
    'MiniGitCommandSplit',
    align_blame,
    'Align Git blame output'
  )
end

local setup_keymap = function()
  local keymap = require('mini.keymap')
  local map_multistep = keymap.map_multistep
  local map_combo = keymap.map_combo

  map_multistep('i', '<Tab>', { 'pmenu_next' })
  map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
  map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
  map_multistep('i', '<BS>', { 'minipairs_bs' })

  local escape_modes = { 'i', 'c', 'x', 's' }
  map_combo(escape_modes, 'jk', '<BS><BS><Esc>')
  map_combo(escape_modes, 'kj', '<BS><BS><Esc>')
  map_combo('t', 'jk', '<BS><BS><C-\\><C-n>')
  map_combo('t', 'kj', '<BS><BS><C-\\><C-n>')

  local notify_many_keys = function(key)
    local lhs = string.rep(key, 5)
    local action = function()
      vim.notify('Too many ' .. key)
    end
    map_combo({ 'n', 'x' }, lhs, action)
  end

  notify_many_keys('h')
  notify_many_keys('j')
  notify_many_keys('k')
  notify_many_keys('l')

  map_combo({ 'n', 'x' }, 'll', 'g$')
  map_combo({ 'n', 'x' }, 'hh', 'g^')
  map_combo({ 'n', 'x' }, 'jj', '}')
  map_combo({ 'n', 'x' }, 'kk', '{')
  map_combo({ 'n', 'i', 'x', 'c' }, '<Esc><Esc>', function()
    vim.cmd('nohlsearch')
  end)
end

local setup_pick = function()
  local pick_window_config = function()
    local height = math.floor(0.618 * vim.o.lines)
    local width = math.floor(0.618 * vim.o.columns)

    return {
      anchor = 'NW',
      height = height,
      width = width,
      row = math.floor(0.5 * (vim.o.lines - height)),
      col = math.floor(0.5 * (vim.o.columns - width)),
    }
  end

  require('mini.pick').setup({
    window = { config = pick_window_config },
  })
end

function M.setup_later()
  setup_git()
  setup_keymap()
  setup_pick()
end

return M
