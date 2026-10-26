local M = {}

function M.setup()
  -- Defaults come from nvim-lspconfig's lsp/<name>.lua; overrides live in
  -- after/lsp/<name>.lua. Lint and type rules belong in each project's
  -- pyproject.toml so the editor and CI agree.
  vim.lsp.enable({ 'ty', 'ruff' })

  require('conform').setup({
    default_format_opts = {
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      lua = { 'stylua' },
    },
  })
end

return M
