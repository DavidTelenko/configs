return {
  'MagicDuck/grug-far.nvim',
  opts = {},
  cmd = { 'GrugFar' },
  keys = {
    { '<leader>rg', ':GrugFar ripgrep<cr>', desc = 'Ripgrep' },
    { '<leader>ra', ':GrugFar astgrep<cr>', desc = 'Astgrep' },
  },
}
