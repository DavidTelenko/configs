return {
  'phelipetls/jsonpath.nvim',
  keys = {
    {
      '<leader>jy',
      function()
        vim.fn.setreg(
          '+',
          require('jsonpath').get():gsub('%["', '.'):gsub('[]["]', '')
        )
      end,
      desc = 'Copy JSON path',
      mode = 'n',
    },
  },
  opts = {},
}
