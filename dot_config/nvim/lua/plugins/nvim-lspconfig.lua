return {
  -- Change configuration for trouble.nvim
  {
    -- Plugin: trouble.nvim
    -- URL: https://github.com/folke/trouble.nvim
    -- Description: A pretty list for showing diagnostics, references, telescope results, quickfix and location lists.
    "folke/trouble.nvim",
    -- Options to be merged with the parent specification
    opts = { use_diagnostic_signs = true }, -- Use diagnostic signs for trouble.nvim
  },

  -- Add symbols-outline.nvim plugin
  {
    -- Plugin: symbols-outline.nvim
    -- URL: https://github.com/simrat39/symbols-outline.nvim
    -- Description: A tree like view for symbols in Neovim using the Language Server Protocol.
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline", -- Command to open the symbols outline
    keys = { { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" } }, -- Keybinding to open the symbols outline
    config = true, -- Use default configuration
  },

  -- Remove inlay hints from default configuration
  {
    -- Plugin: nvim-lspconfig
    -- URL: https://github.com/neovim/nvim-lspconfig
    -- Description: Quickstart configurations for the Neovim LSP client.
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    events = "VeryLazy", -- Load this plugin on the 'VeryLazy' event
    opts = {
      inlay_hints = { enabled = true }, -- Disable inlay hints
      servers = {

        pyright = {
          mason = false,
          autostart = false,
        },
        -- Configuration basedpyright for the LSP [Python3]
        -- basedpyright = {
        --   settings = {
        --     basedpyright = {
        --       analysis = {
        --         autoSearchPaths = true,
        --         diagnosticMode = "openFilesOnly",
        --         useLibraryCodeForTypes = true,
        --         typeCheckingMode = "standard",
        --       },
        --     },
        --   },
        -- },

        -- Configuration ruff (linting y formatting) [Python3]
        ruff = {
          cmd_env = { RUFF_TRACE = "messages" },
          init_options = {
            settings = {
              logLevel = "error",
            },
          },
          keys = {
            {
              "<leader>co",
              LazyVim.lsp.action["source.organizeImports"],
              desc = "Organize Imports",
            },
          },
        },

        -- Add rust-analyzer configuration [Rust]
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              diagnostics = {
                enable = true,
              },
            },
          },
        },

        -- Configuration for the dockerls [Docker]
        dockerls = {
          settings = {
            docker = {
              languageserver = {
                formatter = {
                  ignoreMultilineInstructions = true,
                },
              },
            },
          },
        },

        -- Configuration for the yamlls [Yaml]
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                -- Schema for GitHub Actions
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",

                -- Schema for Kubernetes
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.1-standalone-strict/all.json"] = "/*.k8s.yaml",

                -- [*] Schema for file YAML
                -- ["../path/relative/to/file.yml"] = "/.github/workflows/*",
                -- ["/path/from/root/of/project"] = "/.github/workflows/*",
              },

              redhat = {
                telemetry = {
                  enabled = false,
                },
              },
            },
          },

          single_file_support = true,
        },

        -- Configuration for the docker_compose_language_service [Docker Compose]
        docker_compose_language_service = {},

        -- Configuration for the taplo [Toml]
        taplo = {},

        -- Configuration for the bashls [Shell]
        bashls = {},

        -- Configuration for tailwindcss [Tailwindcss]
        tailwindcss = {},

        -- Configuration for the clangd [C]
        clangd = {
          cmd = { "clangd", "--background-index", "--compile-commands-dir=build" },
        },

        -- Configuration for the intelephense [Php]
        intelephense = {
          init_options = {
            storagePath = vim.fn.stdpath("cache") .. "/intelephense",
            globalStoragePath = vim.fn.stdpath("data") .. "/intelephense",
            licenceKey = nil,
            clearCache = false,
          },

          settings = {
            intelephense = {
              filetypes = { "php", "blade", "php_only" },
              files = {
                associations = { "*.php", "*.blade.php" },
                maxSize = 5000000,
              },
            },
          },
        },
      },
    },
  },
}
