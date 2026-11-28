return {
  'chrisgrieser/nvim-spider',
  opts = {
    skipInsignificantPunctuation = false,
    consistentOperatorPending = false,
    subwordMovement = true,
    customPatterns = {},
  },
  keys = {
    -- |
    -- V the word here is what spider creates)
    { 'w', mode = { 'n', 'o', 'x' }, desc = 'Next word' },
    { 'e', mode = { 'n', 'o', 'x' }, desc = 'Next end of word' },
    { 'b', mode = { 'n', 'o', 'x' }, desc = 'Prev word' },
  },
  config = function(_, opts)
    local spider = require 'spider'
    spider.setup(opts)

    vim.keymap.set({ 'n', 'o', 'x' }, 'w', function()
      spider.motion 'w'
    end, { remap = true, desc = 'Next word' })

    vim.keymap.set({ 'n', 'o', 'x' }, 'e', function()
      spider.motion 'e'
    end, { remap = true, desc = 'Next end of word' })

    vim.keymap.set({ 'n', 'o', 'x' }, 'b', function()
      spider.motion 'b'
    end, { remap = true, desc = 'Prev word' })
  end,
}
