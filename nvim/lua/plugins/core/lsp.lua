--- This is a main config of servers extracted for readability purposes.
---
--- All servers are separated into:
---  - internal (managed by Mason, first tuple element)
---  - external (managed by me, second tuple element)
---
--- *Some server require external config, so we pass that through context
--- parameter
---@return table<string,vim.lsp.Config>, table<string,vim.lsp.Config>
local function get_servers(context)
  return {
    ols = {},
    bashls = {},
    pyright = {},
    cssls = {},
    html = {
      filetypes = {
        'html',
        'twig',
        'hbs',
      },
    },
    -- elixirls = {
    --   cmd = { 'elixir-ls' },
    -- },
    clangd = {},
    emmet_language_server = {},
    gopls = {},
    -- jdtls = {
    --   -- TODO: I may want to use JDTLS_JVM_ARGS env var instead
    --   cmd = vim.list_extend(
    --     vim.lsp.config['jdtls'].cmd, ---@diagnostic disable-line: param-type-mismatch
    --     {
    --       '--jvm-arg=-javaagent:'
    --         .. vim.fn.expand '$MASON/share/jdtls/lombok.jar',
    --     }
    --   ),
    -- },
    lua_ls = {
      settings = {
        Lua = {
          hint = { enable = true },
          workspace = {
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
          diagnostics = {
            disable = {
              'missing-fields',
              'unused-function', -- unused name will still be reported
            },
          },
        },
      },
    },
    rust_analyzer = {},
    svelte = {},
    tailwindcss = {},
    biome = {},
    oxlint = {},
    tsgo = {},
    -- ts_ls = {},
    -- vtsls = {},
    -- kotlin_language_server = {},
    jsonls = {
      settings = {
        json = {
          schemas = context.schemas.json.schemas(),
          validate = {
            enable = true,
          },
        },
      },
    },
    yamlls = {
      settings = {
        yaml = {
          schemas = context.schemas.yaml.schemas(),
          schemaStore = {
            enable = false,
            url = '',
          },
        },
      },
    },
  }, {
    nushell = {},
    c3_lsp = {},
    zls = {},
  }
end

return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    lazy = false,
    opts = {
      ensure_installed = {
        'ast-grep',
        'cspell',
        'eslint_d',
        'markdownlint',
        'oxfmt',
        'prettierd',
        'shfmt',
        'stylua',
        'tree-sitter-cli',
      },
    },
  },
  {
    'williamboman/mason.nvim',
    event = 'VeryLazy',
    ---@type MasonSettings
    opts = {
      log_level = vim.log.levels.INFO,
      max_concurrent_installers = 4,
      registries = {
        'github:mason-org/mason-registry',
      },
      providers = {
        'mason.providers.registry-api',
        'mason.providers.client',
      },
      ui = {
        check_outdated_packages_on_open = true,
        border = 'rounded',
        width = 1.0,
        height = 1.0,
        icons = {
          package_installed = '',
          package_pending = '⌛',
          package_uninstalled = '',
        },
      },
    },
  },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'b0o/schemastore.nvim' },
  { 'danarth/sonarlint.nvim' },
  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    config = function()
      local mason_lspconfig = require 'mason-lspconfig'
      local helpers = require 'helpers.lsp'

      do -- diagnostics setup
        vim.diagnostic.config {
          float = { border = 'rounded', source = 'if_many' },
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = '󰅚 ',
              [vim.diagnostic.severity.WARN] = '󰀪 ',
              [vim.diagnostic.severity.INFO] = '󰋽 ',
              [vim.diagnostic.severity.HINT] = '󰌶 ',
            },
          },
          virtual_text = {
            current_line = true,
          },
        }
      end

      -- color highlighting
      vim.lsp.document_color.enable(true, nil, { style = 'virtual' })

      do -- keymaps
        vim.keymap.set('n', '<leader>cd', vim.diagnostic.setqflist, {
          desc = 'Open diagnostics list',
        })

        vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {
          desc = 'Open floating diagnostic message',
        })

        vim.keymap.set('n', '<leader>cR', '<cmd>LspRestart<cr>', {
          desc = 'Restart Lsp Server',
        })
      end

      do -- servers setup
        -- Load server configs:
        --   internal_servers - installed and managed by Mason
        --   external_servers - by User
        local internal_servers, external_servers = get_servers {
          schemas = require 'schemastore',
        }

        -- Ensure internal servers are installed
        ---@type MasonLspconfigSettings
        mason_lspconfig.setup {
          ensure_installed = vim.tbl_keys(internal_servers),
          automatic_enable = false,
        }

        ---@type table<string,vim.lsp.Config>
        local all_servers =
          vim.tbl_extend('error', internal_servers, external_servers)

        -- nvim-cmp capabilities
        local capabilities = require('cmp_nvim_lsp').default_capabilities(
          vim.lsp.protocol.make_client_capabilities()
        )

        -- Configure all the servers
        for name, config in pairs(all_servers) do
          vim.lsp.enable(name)
          vim.lsp.config(
            name,
            vim.tbl_deep_extend('force', vim.lsp.config[name], config, {
              on_attach = helpers.on_attach,
              capabilities = capabilities,
            })
          )
        end
      end

      -- Mason buffer word wrap
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'mason',
        group = vim.api.nvim_create_augroup('MasonWordWrap', {
          clear = true,
        }),
        callback = function()
          vim.o.wrap = true
          vim.o.linebreak = true
        end,
      })
    end,
  },
}
