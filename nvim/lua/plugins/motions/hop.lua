return {
  'smoka7/hop.nvim',
  keys = {
    { 's', '<NOP>', mode = { 'n' }, desc = 'Hop' },
    { 's/', mode = { 'n', 'v' }, desc = 'Hop to pattern' },
    { 'sd', mode = { 'n', 'v' }, desc = 'Hop to word' },
    { 'sl', mode = { 'n', 'v' }, desc = 'Hop to line' },
    { 'st', mode = { 'n', 'v' }, desc = 'Hop to treesitter nodes' },
    { 'sf', mode = { 'n', 'v' }, desc = 'Hop to character' },
  },
  config = function()
    local hop = require 'hop'
    local hop_ts = require 'hop-treesitter'

    local function set(name, link)
      vim.api.nvim_set_hl(0, name, {
        link = link,
        default = true,
      })
    end

    -- Gruvbox theme
    set('HopNextKey', 'GruvboxRedBold')
    set('HopNextKey1', 'GruvboxOrangeBold')
    set('HopNextKey2', 'GruvboxYellowBold')
    set('HopCursor', 'Cursor')
    set('HopPreview', 'IncSearch')
    set('HopUnmatched', 'Comment')

    hop.setup {
      create_hl_autocmd = false,
      hl_mode = 'replace',
    }

    -- This is the most powerful feature, and I'm contemplating to leave just
    -- this one and remap it to just 's'
    vim.keymap.set({ 'n', 'v' }, 'sd', function()
      -- cspell:disable-next-line
      hop.hint_camel_case { keys = 'qazwsxedcrfvtgbyhnujmikolp' }
    end, { remap = true, desc = 'Hop to word' })

    vim.keymap.set({ 'n', 'v' }, 'sf', function()
      hop.hint_char1 {
        current_line_only = false,
        jump_on_sole_occurrence = false,
      }
    end, { remap = true })

    vim.keymap.set({ 'n', 'v' }, 'sl', function()
      hop.hint_lines {}
    end, { remap = true, desc = 'Hop to line' })

    vim.keymap.set({ 'n', 'v' }, 'st', function()
      hop_ts.hint_nodes {}
    end, { remap = true, desc = 'Hop to treesitter nodes' })

    vim.keymap.set({ 'n', 'v' }, 's/', function()
      hop.hint_patterns {}
    end, { remap = true, desc = 'Hop to pattern' })
  end,
}
