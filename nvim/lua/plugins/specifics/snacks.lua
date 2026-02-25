return {
  lazy = false,
  'folke/snacks.nvim',
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    gitbrowse = { enabled = true },
    quickfile = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
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
