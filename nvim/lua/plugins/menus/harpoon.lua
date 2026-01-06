return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  keys = {
    { '<leader><space>', desc = 'Open harpoon menu' },
    { '<leader>ha', desc = 'Add file' },
    { '<leader>hr', desc = 'Remove file' },
    { '<leader>hs', desc = 'Harpoon files' },
    { ']h', desc = 'Next harpoon file' },
    { '[h', desc = 'Previous harpoon file' },
    { '<leader>1', desc = 'Navigate to harpoon file [1]' },
    { '<leader>2', desc = 'Navigate to harpoon file [2]' },
    { '<leader>3', desc = 'Navigate to harpoon file [3]' },
    --- to lazy load more just press the menu (<leader><space>) bruh
  },
  config = function()
    local harpoon = require 'harpoon'

    harpoon:setup {
      settings = {
        save_on_toggle = true,
      },
    }

    local harpoon_extensions = require 'harpoon.extensions'
    harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

    local wk = require 'which-key'

    for i = 1, 9 do
      vim.keymap.set('n', '<leader>' .. i, function()
        harpoon:list():select(i)
      end, { desc = 'Navigate to harpoon file [' .. i .. ']' })
      wk.add { '<leader>' .. i, hidden = true }
    end

    wk.add { '<leader>1', desc = 'Navigate to harpoon file [1..9]' }

    vim.keymap.set('n', '<leader>ha', function()
      harpoon:list():add()
    end, { desc = 'Add file' })

    vim.keymap.set('n', ']h', function()
      harpoon:list():next { ui_nav_wrap = true }
    end, { desc = 'Next harpoon file' })

    vim.keymap.set('n', '[h', function()
      harpoon:list():prev { ui_nav_wrap = true }
    end, { desc = 'Previous harpoon file' })

    vim.keymap.set('n', '<leader>hr', function()
      harpoon:list():remove()
    end, { desc = 'Remove file' })

    vim.keymap.set('n', '<leader><space>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list(), {
        border = 'rounded',
        title_pos = 'center',
        height_in_lines = 20,
        ui_width_ratio = 0.9,
        title = ' Harpoon ',
      })
    end, { desc = 'Open harpoon menu' })

    -- basic telescope configuration
    local conf = require('telescope.config').values

    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = conf.file_previewer {},
          sorter = conf.generic_sorter {},
        })
        :find()
    end

    vim.keymap.set('n', '<leader>hs', function()
      toggle_telescope(harpoon:list())
    end, { desc = 'Harpoon files' })
  end,
}
