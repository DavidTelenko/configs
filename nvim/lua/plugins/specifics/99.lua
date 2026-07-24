return {
  'ThePrimeagen/99',
  keys = {
    { '<leader>9v', desc = 'Visual', mode = { 'v' } },
    { '<leader>9x', desc = 'Search', mode = { 'n' } },
    { '<leader>9s', desc = 'Stop', mode = { 'n' } },
    { '<leader>9m', desc = 'Model', mode = { 'n' } },
  },
  config = function()
    local _99 = require '99'

    _99.setup {
      provider = _99.Providers.OpenCodeProvider,
      model = 'github-copilot/claude-sonnet-4.5',
      logger = {
        level = _99.DEBUG,
        path = './tmp/99/debug.log',
        print_on_error = true,
      },
      tmp_dir = './tmp/99',

      --- Completions: #rules and @files in the prompt buffer
      completion = {
        -- custom_rules = {
        --   'scratch/custom_rules/',
        -- },

        --- Configure @file completion (all fields optional, sensible defaults)
        files = {
          enabled = true,
          max_file_size = 102400, -- bytes, skip files larger than this
          max_files = 5000, -- cap on total discovered files
          exclude = { '.env', '.env.*', 'node_modules', '.git' },
        },
        source = 'cmp', -- "native" (default), "cmp", or "blink"
      },

      md_files = {
        'AGENTS.md',
      },
    }

    vim.keymap.set('v', '<leader>9v', function()
      _99.visual {}
    end, { desc = 'Visual' })

    vim.keymap.set('n', '<leader>9x', function()
      _99.stop_all_requests()
    end, { desc = 'Stop' })

    vim.keymap.set('n', '<leader>9s', function()
      _99.search {}
    end, { desc = 'Search' })

    vim.keymap.set('n', '<leader>9m', function()
      require('99.extensions.telescope').select_model()
    end, { desc = 'Model' })
  end,
}
