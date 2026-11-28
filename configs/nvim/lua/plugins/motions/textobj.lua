return {
  'chrisgrieser/nvim-various-textobjs',
  keys = { 'c', 'd', 'v', 'y' },
  opts = {
    keymaps = {
      useDefaults = true,
      disabledDefaults = {
        'L',
        'C',
        'r',
        'iS',
        'aS',
        'ik',
        'ak',
        'iv',
        'av',
        'gw',
        'gW',
      },
    },
  },
  config = function(_, opts)
    local objs = require 'various-textobjs'
    objs.setup(opts)

    -- TODO: this still sometimes can invoke 'default' inside/around sentence
    -- behavior which is useless for me

    vim.keymap.set({ 'o', 'x' }, 'is', function()
      objs.subword 'inner'
    end, { remap = true, desc = 'inner subword' })

    vim.keymap.set({ 'o', 'x' }, 'as', function()
      objs.subword 'outer'
    end, { remap = true, desc = 'outer subword' })

    vim.keymap.set({ 'o', 'x' }, 'ij', ':<c-u>norm viq<cr>')
    vim.keymap.set({ 'o', 'x' }, 'aj', ':<c-u>norm vaq<cr>')
  end,
}
