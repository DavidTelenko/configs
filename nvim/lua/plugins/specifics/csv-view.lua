return {
  'hat0uma/csvview.nvim',
  enabled = false,
  keys = { { '<leader>cv', desc = 'Toggle csv view' } },
  ---@module "csvview"
  ---@type CsvView.Options
  opts = {
    parser = { comments = { '#', '//' }, delimiter = ',' },
    view = { display_mode = 'border' },
    keymaps = {
      -- Text objects for selecting fields
      textobject_field_inner = { 'iF', mode = { 'o', 'x' } },
      textobject_field_outer = { 'aF', mode = { 'o', 'x' } },
      -- Excel-like navigation:
      -- Use <Tab> and <S-Tab> to move horizontally between fields.
      -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
      -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
      jump_next_field_end = { '<Tab>', mode = { 'n', 'v' } },
      jump_prev_field_end = { '<S-Tab>', mode = { 'n', 'v' } },
      jump_next_row = { '<Enter>', mode = { 'n', 'v' } },
      jump_prev_row = { '<S-Enter>', mode = { 'n', 'v' } },
    },
  },
  config = function(_, opts)
    local csv_view = require 'csvview'
    csv_view.setup(opts)

    vim.keymap.set('n', '<leader>cv', function()
      csv_view.toggle()
    end, { desc = 'Toggle csv view' })
  end,
}
