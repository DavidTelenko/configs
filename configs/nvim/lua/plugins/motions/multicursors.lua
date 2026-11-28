return {
  'jake-stewart/multicursor.nvim',
  lazy = false,
  config = function()
    local mc = require 'multicursor-nvim'
    mc.setup()

    local map = vim.keymap.set

    -- Add or skip adding a new cursor by matching word/selection
    map({ 'n', 'x' }, ']s', function()
      mc.matchAddCursor(1)
    end, { desc = 'Next multicursor word under cursor' })
    map({ 'n', 'x' }, ']n', function()
      mc.matchSkipCursor(1)
    end, { desc = 'Next skip multicursor word under cursor' })
    map({ 'n', 'x' }, '[s', function()
      mc.matchAddCursor(-1)
    end, { desc = 'Previous multicursor word under cursor' })
    map({ 'n', 'x' }, '[n', function()
      mc.matchSkipCursor(-1)
    end, { desc = 'Previous multicursor word under cursor' })

    -- Toggle multicursor selection
    map({ 'n', 'x' }, '<A-c>', mc.toggleCursor, {
      desc = 'Toggle multicursor mode',
    })

    map({ 'n', 'x' }, 'gA', mc.matchAllAddCursors, {
      desc = 'Match all words under cursor',
    })
    map({ 'n', 'x' }, 'ga', mc.addCursorOperator, { desc = 'Add cursor' })
    map({ 'n', 'x' }, 'gV', mc.restoreCursors, { desc = 'Restore cursors' })
    map({ 'n', 'x' }, '<leader>m', mc.operator, { desc = 'Add cursor' })

    map('x', 'M', mc.matchCursors)
    map('x', 'S', mc.splitCursors)

    -- Mappings defined in a keymap layer only apply when there are
    -- multiple cursors. This lets you have overlapping mappings.
    mc.addKeymapLayer(function(layer_map)
      -- Select a different cursor as the main one.
      layer_map({ 'n', 'x' }, '<left>', mc.prevCursor)
      layer_map({ 'n', 'x' }, '<right>', mc.nextCursor)

      layer_map({ 'n', 'x' }, '<leader>x', mc.deleteCursor, {
        desc = 'Delete cursor',
      })
      layer_map('n', '<leader>a', mc.alignCursors, {
        desc = 'Align cursors',
      })
      layer_map('x', 'I', mc.insertVisual)
      layer_map('x', 'A', mc.appendVisual)
      layer_map({ 'n', 'x' }, 'g<c-a>', mc.sequenceIncrement)
      layer_map({ 'n', 'x' }, 'g<c-x>', mc.sequenceDecrement)
      layer_map({ 'n', 'x' }, '<up>', function()
        mc.lineAddCursor(-1)
      end)
      layer_map({ 'n', 'x' }, '<down>', function()
        mc.lineAddCursor(1)
      end)

      -- Enable and clear cursors using escape.
      layer_map('n', '<esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, 'MultiCursorCursor', { reverse = true })
    hl(0, 'MultiCursorVisual', { link = 'Visual' })
    hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
    hl(0, 'MultiCursorDisabledCursor', { reverse = true })
    hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}
