return {
  'DavidTelenko/texel.nvim',
  keys = {
    { '<leader>ab', desc = 'Ask with buffer', mode = { 'n' } },
    { '<leader>as', desc = 'Open scratch markdown tab', mode = { 'n' } },
    { '<leader>a', desc = 'Ask with selection', mode = { 'v' } },
  },
  --- @module "texel"
  --- @type texel.Config
  opts = {
    tgpt = {
      provider = 'pollinations',
      -- key = vim.env.GEMINI_API_KEY,
    },
  },
  config = function(_, opts)
    local texel = require 'texel'

    texel.setup(opts)

    vim.keymap.set('v', '<leader>a', function()
      texel.chat.ask.selection()
    end, { desc = 'Ask with selection' })

    vim.keymap.set('n', '<leader>ab', function()
      texel.chat.ask.buffer()
    end, { desc = 'Ask with buffer' })

    vim.keymap.set('n', '<leader>as', function()
      vim.cmd 'tabnew'
      vim.cmd 'setl filetype=markdown'
      vim.cmd 'setl buftype=nofile'
      vim.cmd 'setl bufhidden=hide'
      vim.cmd 'setl noswapfile'
    end, { desc = 'Open scratch markdown tab buffer' })
  end,
}
