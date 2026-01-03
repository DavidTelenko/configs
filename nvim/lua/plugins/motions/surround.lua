return {
  'kylechui/nvim-surround',
  keys = {
    { 'S', '<NOP>', mode = { 'n', 'v' } },
    { 'ds' },
    { 'cs' },
    { 'ys' },
    { 's', mode = 'v' },
  },
  config = function()
    local surround = require 'nvim-surround'
    local surround_utils = require 'nvim-surround.config'

    surround.setup {
      keymaps = {
        visual = 's',
      },
      aliases = {
        ['j'] = { '"', "'", '`' },
      },
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
        g = {
          add = function()
            local result = surround_utils.get_input 'Enter the generic name: '
            if result then
              return { { result .. '<' }, { '>' } }
            end
          end,
          find = function()
            return surround_utils.get_selection { node = 'generic_type' }
          end,
          delete = '^(.-<)().-(>)()$',
          change = {
            target = '^(.-<)().-(>)()$',
            replacement = function()
              local result = surround_utils.get_input 'Enter the generic name: '
              if result then
                return { { result .. '<' }, { '>' } }
              end
            end,
          },
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
  end,
}
