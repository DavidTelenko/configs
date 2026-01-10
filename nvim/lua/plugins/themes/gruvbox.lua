return {
  'ellisonleao/gruvbox.nvim',
  enabled = true,
  lazy = false,
  opts = {
    terminal_colors = true, -- add neovim terminal colors
    undercurl = true,
    underline = true,
    bold = true,
    italic = {
      strings = false,
      emphasis = false,
      comments = false,
      operators = false,
      folds = false,
    },
    strikethrough = true,
    invert_selection = false,
    invert_signs = false,
    invert_tabline = false,
    invert_intend_guides = false,
    inverse = true, -- invert background for search, diffs, statuslines and errors
    contrast = '', -- can be "hard", "soft" or empty string
    palette_overrides = {},
    overrides = {},
    dim_inactive = false,
    transparent_mode = true,
  },
  config = function(_, opts)
    require('gruvbox').setup(opts)
    vim.cmd.colorscheme 'gruvbox'

    local hl = vim.api.nvim_set_hl

    hl(0, 'Delimiter', { link = 'GruvboxOrange' })
    hl(0, 'ErrorMsg', { link = 'WarningMsg' })
    hl(0, 'Error', { link = 'WarningMsg' })

    -- This can be removed after https://github.com/ellisonleao/gruvbox.nvim/pull/416 is merged
    for name in pairs(require('cmp.types').lsp.CompletionItemKind) do
      if type(name) == 'string' then
        local hl_group = ('CmpItemKind%s'):format(name)
        vim.api.nvim_set_hl(0, hl_group .. 'Icon', {
          link = hl_group,
        })
      end
    end
  end,
}
