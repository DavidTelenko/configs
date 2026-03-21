return {
  'nvim-neotest/neotest',
  enabled = false,
  cmd = {
    'Neotest',
    'NeotestPlaywrightProject',
    'NeotestPlaywrightRefresh',
    'NeotestPlaywrightPreset',
  },
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    -- Adapters
    'thenbe/neotest-playwright',
  },
  keys = {
    { '<leader>Tr', '<cmd>Neotest run <cr>', desc = 'Run nearest test' },
    { '<leader>Tl', '<cmd>Neotest run last<cr>', desc = 'Run Last test' },
    { '<leader>Tf', '<cmd>Neotest run file<cr>', desc = 'Run test File' },
    {
      '<leader>Tt',
      '<cmd>Neotest run output-panel<cr>',
      desc = 'Toggle ouput panel',
    },
  },
  opts = function()
    local playwright_config = function()
      return require('helpers.general').root_relative(
        require('helpers.root_markers')['playwright']
      )
    end
    return {
      adapters = {
        require('neotest-playwright').adapter {
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = false,
            get_playwright_config = playwright_config,
            get_cwd = function()
              return require('plenary.path'):new(playwright_config()):parent()
            end,
          },
        },
      },
      output_panel = { open_on_run = true },
      diagnostic = { enabled = true },
    }
  end,
}
