return {
  -- Automatically add closing pairs
  'windwp/nvim-autopairs',
  event = { 'InsertEnter', 'CmdlineEnter' },
  config = function()
    local autopairs = require 'nvim-autopairs'
    local basic = require 'nvim-autopairs.rules.basic'

    autopairs.setup {
      disable_filetype = { 'TelescopePrompt', 'fff_input' },
      map_cr = true,
      map_bs = true,
    }

    basic.setup {
      break_undo = true,
      enable_moveright = true,
      ignored_next_char = '',
      enable_bracket_in_quote = true,
      enable_check_bracket_line = true,
    }
    -- If you want to automatically add `(` after selecting a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
