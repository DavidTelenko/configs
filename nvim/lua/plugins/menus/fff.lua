return {
  'dmtrKovalenko/fff.nvim',
  keys = {
    { '<leader>s', desc = 'Search', mode = { 'n', 'v', 'x' } },
  },
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  opts = {
    prompt = '> ',
    prompt_vim_mode = true,
    layout = {
      height = 1.0,
      width = 1.0,
      prompt_position = 'bottom',
      preview_position = 'right',
      preview_size = 0.4,
      flex = { size = 100 },
    },
    debug = {
      enabled = false,
      show_scores = true,
    },
    wrap_around = true,
  },
  config = function(_, opts)
    local fff = require 'fff'
    fff.setup(opts)

    vim.keymap.set('n', '<leader>sf', function()
      fff.find_files { title = 'Files' }
    end, { desc = 'Files' })

    vim.keymap.set('n', '<leader>sg', function()
      fff.live_grep { title = 'Grep' }
    end, { desc = 'Grep' })

    -- vim.keymap.set('n', '<leader>sz', function()
    --   fff.live_grep { grep = { modes = { 'fuzzy', 'plain' } } }
    -- end, { desc = 'By fuzzy grep' })

    vim.keymap.set('n', 'gf', fff.open_file_under_cursor)

    vim.keymap.set({ 'v', 'x' }, '<leader>s', function()
      require('fff').live_grep {
        query = require('helpers.general').visual_selection(),
        title = 'Current selection',
      }
    end, { desc = 'Current selection' })
  end,
}
