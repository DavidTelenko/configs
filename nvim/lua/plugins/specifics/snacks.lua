return {
  lazy = false,
  'folke/snacks.nvim',
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    gitbrowse = {
      enabled = true,
      notify = false,
      open = function(url)
        vim.fn.setreg('+', url)
      end,
    },
    quickfile = { enabled = true },
    indent = {
      enabled = true,
      animate = { enabled = false },
    },
    input = { enabled = true },
    image = { enabled = true },
  },
  keys = {
    {
      '<leader>go',
      function()
        Snacks.gitbrowse.open()
      end,
      mode = 'n',
      desc = 'Open repository',
    },
  },
}
