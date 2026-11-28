-- Plugin for beautiful buffer experience with quicklist (similar to oil)
return {
  'stevearc/quicker.nvim',
  event = 'FileType qf',
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {
    opts = {
      number = true,
      relativenumber = false,
    },
    highlight = {
      treesitter = true,
      lsp = false,
      load_buffers = false,
    },
    max_filename_width = function()
      return math.floor(math.min(40, vim.o.columns / 4))
    end,
    keys = {
      {
        '>',
        function()
          if #vim.fn.getqflist() > 100 then
            return
          end
          require('quicker').expand {
            before = 2,
            after = 2,
            add_to_existing = true,
          }
        end,
        desc = 'Expand quickfix context',
      },
      {
        '<',
        function()
          require('quicker').collapse()
        end,
        desc = 'Collapse quickfix context',
      },
    },
  },
}
