return {
  'stevearc/conform.nvim',
  event = {
    'BufWritePost',
    'DirChanged',
  },
  cmd = { 'ConformFormat', 'ConformInfo' },
  config = function()
    local h = require 'helpers.general'

    local function setup()
      local ox_or_prettier = h.first {
        h.require_config { 'oxfmt' },
        h.require_config { 'prettierd' },
        'oxfmt', -- fallback (if no configs found)
      }

      local js_ts_formatters = h.first {
        {
          h.first {
            h.require_config { 'oxlint' },
            h.require_config { 'eslint_d' },
          },
          h.first {
            h.require_config { 'oxfmt' },
            h.require_config { 'prettierd' },
          },
        },
        h.require_config 'biome',
        'oxfmt', -- fallback if no configs found
        -- important to add to ensure_installed in mason-tool-installer
      }

      ---@module "conform"
      ---@type conform.setupOpts
      local opts = {
        log_level = vim.log.levels.DEBUG,
        format_after_save = {
          timeout_ms = 100000,
          lsp_format = 'fallback',
          quiet = true, --- NOTE: maybe dangerous?
        },
        formatters_by_ft = {
          css = { 'oxfmt' },
          elixir = { 'mix' },
          graphql = ox_or_prettier,
          html = ox_or_prettier,
          svg = ox_or_prettier,
          javascript = js_ts_formatters,
          javascriptreact = js_ts_formatters,
          json = ox_or_prettier,
          jsonc = ox_or_prettier,
          kotlin = { 'ktlint' },
          lua = { 'stylua' },
          markdown = ox_or_prettier, -- 'injected' },
          mdx = ox_or_prettier, -- 'injected' },
          python = { 'black' },
          sh = { 'shfmt' },
          bash = { 'shfmt' },
          svelte = ox_or_prettier,
          typescript = js_ts_formatters,
          typescriptreact = js_ts_formatters,
          yaml = ox_or_prettier,
        },
      }
      require('conform').setup(opts)
    end

    vim.api.nvim_create_autocmd('DirChanged', {
      group = vim.api.nvim_create_augroup('ConformDirChanged', {
        clear = true,
      }),
      callback = setup,
    })

    vim.api.nvim_create_user_command('ConformFormat', function()
      require('conform').format()
    end, { desc = 'Format current buffer with Conform' })

    setup()
  end,
}
