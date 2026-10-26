-- Editor-only overrides for Ruff. Rules go in [tool.ruff] of the project.
return {
  -- ty provides type-aware hover, so Ruff's hover only duplicates it.
  on_attach = function(client) client.server_capabilities.hoverProvider = false end,
  init_options = {
    -- Ruff's editor settings, e.g. lineLength or organizeImports.
    settings = {},
  },
}
