local surround_utils = require 'nvim-surround.config'

require('nvim-surround').buffer_setup {
  surrounds = {
    c = {
      add = function()
        local result =
          surround_utils.get_input 'Enter the markdown codeblock language: '
        if result then
          return { { '```' .. result }, { '```' } }
        end
      end,
    },
    L = {
      add = function()
        local input = surround_utils.get_input 'Link name: '
        if input then
          return {
            { '[' .. input .. '](' },
            { ')' },
          }
        end
      end,
      find = '%b[]%b()',
      delete = '^(%[)().-(%]%b())()$',
    },
  },
}
