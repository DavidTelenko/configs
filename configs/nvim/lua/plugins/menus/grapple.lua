return {
  'cbochs/grapple.nvim',
  opts = {
    scope = 'git_branch',
    win_opts = {
      width = 0.95,
      height = 0.8,
      border = 'rounded',
    },
  },
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = 'Grapple',
  keys = {
    {
      '<leader>ha',
      '<cmd>Grapple toggle<cr>',
      desc = 'Toggle graple tag',
    },
    {
      '<leader><leader>',
      '<cmd>Grapple toggle_tags<cr>',
      desc = 'Open Grapple menu',
    },
    {
      ']h',
      '<cmd>Grapple cycle_tags next<cr>',
      desc = 'Next Grapple tag',
    },
    {
      '[h',
      '<cmd>Grapple cycle_tags prev<cr>',
      desc = 'Previous Grapple tag',
    },
  },
}
