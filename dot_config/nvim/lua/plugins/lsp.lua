return {
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
        -- pyright = {
        --   mason = false,
        --   autostart = false,
        -- },
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
      },
    },
  },
}
