return {
  'akinsho/toggleterm.nvim',
  keys = {
    {
      '<leader>tt',
      '<cmd>ToggleTerm<cr>',
      desc = 'Open terminal',
    },
    {
      '<leader>tn',
      '<cmd>TermNew<cr>',
      desc = 'New terminal',
    },
    {
      '<leader>ta',
      '<cmd>ToggleTermToggleAll<cr>',
      desc = 'Open all terminals',
    },
  },
  opts = {
    shell = vim.fn.executable 'nu' == 0 and vim.o.shell or 'nu',
  },
}
