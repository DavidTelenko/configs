return {
  'chrisgrieser/nvim-rulebook',
  keys = {
    { '<leader>ci', desc = 'Ignore rule' },
    { '<leader>cl', desc = 'Lookup rule' },
    { '<leader>cE', desc = 'Prettify error' },
  },
  config = function()
    local rulebook = require 'rulebook'

    rulebook.setup {
      ignoreComments = {
        eslint_d = {
          comment = '// eslint-disable-next-line %s',
          location = 'prevLine',
          docs = 'https://eslint.org/docs/latest/use/configure/rules#using-configuration-comments-1',
          multiRuleIgnore = true,
        },
      },
    }

    vim.keymap.set('n', '<leader>ci', function()
      rulebook.ignoreRule()
    end, { desc = 'Ignore rule' })

    vim.keymap.set('n', '<leader>cl', function()
      rulebook.lookupRule()
    end, { desc = 'Lookup rule' })

    vim.keymap.set('n', '<leader>cE', function()
      rulebook.prettifyError()
    end, { desc = 'Prettify error' })
  end,
}
