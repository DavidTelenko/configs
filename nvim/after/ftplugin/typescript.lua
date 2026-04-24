local surround_utils = require 'nvim-surround.config'

require('nvim-surround').buffer_setup {
  surrounds = {
    p = {
      add = function()
        local name = surround_utils.get_input 'Enter the step name: '
        if name then
          return {
            { "await test.step('" .. name .. "', async () => {" },
            { '});' },
          }
        end
      end,
    },
  },
}
