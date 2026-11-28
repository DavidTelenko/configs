return {
  'nvim-telescope/telescope.nvim',
  keys = {
    { '<leader>s', desc = 'Search', mode = { 'n' } },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-telescope/telescope-live-grep-args.nvim',
    'jvgrootveld/telescope-zoxide',
  },
  config = function()
    local telescope = require 'telescope'
    local lga_actions = require 'telescope-live-grep-args.actions'
    local actions = require 'telescope.actions'

    telescope.setup {
      defaults = {
        mappings = {
          i = {
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          },
          n = {
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          },
        },
        wrap_results = true,
        layout_config = {
          horizontal = {
            prompt_position = 'bottom',
            width = { padding = 0 },
            height = { padding = 0 },
            preview_cutoff = 10,
            preview_width = 0.4,
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ['<C-k>'] = lga_actions.quote_prompt(),
              ['<C-i>'] = lga_actions.quote_prompt { postfix = '--iglob' },
              ['<C-space>'] = lga_actions.to_fuzzy_refine,
            },
          },
        },
        zoxide = {
          prompt_title = 'Zoxide',

          mappings = {
            default = {
              action = function(selection)
                vim.cmd.lcd(selection.path)
              end,
              after_action = function(selection)
                vim.notify('Window directory changed to ' .. selection.path)
              end,
            },
            ['<C-t>'] = {
              action = function(selection)
                vim.cmd.cd(selection.path)
              end,
              after_action = function(selection)
                vim.notify('Global directory changed to ' .. selection.path)
              end,
            },
          },
        },
      },
    }

    -- Enable telescope fzf native, if installed
    pcall(telescope.load_extension, 'fzf')
    pcall(telescope.load_extension, 'live_grep_args')
    pcall(telescope.load_extension, 'ui-select')
    pcall(telescope.load_extension, 'zoxide')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'

    vim.keymap.set('n', '<leader>?', builtin.oldfiles, {
      desc = 'Recently opened files',
    })

    vim.keymap.set('n', '<leader>sb', builtin.buffers, {
      desc = 'Existing buffers',
    })

    vim.keymap.set('n', '<leader>s/', function()
      builtin.current_buffer_fuzzy_find {
        previewer = false,
      }
    end, { desc = 'In current buffer' })

    vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
      desc = 'Help',
    })

    -- vim.keymap.set('n', '<leader>sf', builtin.find_files, {
    --   desc = 'Files',
    -- })

    -- vim.keymap.set('n', '<leader>sH', function()
    --   builtin.find_files { hidden = true, no_ignore = true }
    -- end, {
    --   desc = 'Hidden',
    -- })

    -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, {
    --   desc = 'Current word',
    -- })

    -- vim.keymap.set(
    --   'v',
    --   '<leader>s',
    --   builtin.grep_string,
    --   { desc = 'Search current selection' }
    -- )

    -- vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
    --   desc = 'By grep',
    -- })

    -- vim.keymap.set(
    --   'n',
    --   '<leader>sG',
    --   telescope.extensions.live_grep_args.live_grep_args,
    --   { desc = 'By Grep With Args' }
    -- )

    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
      desc = 'Diagnostics',
    })

    vim.keymap.set('n', '<leader>se', function()
      builtin.diagnostics { severity = vim.diagnostic.severity.ERROR }
    end, { desc = 'Errors' })

    vim.keymap.set('n', '<leader>sr', builtin.resume, {
      desc = 'Resume',
    })

    vim.keymap.set('n', '<leader>sq', builtin.quickfix, {
      desc = 'Quickfix',
    })

    vim.keymap.set('n', '<leader>sz', telescope.extensions.zoxide.list, {
      desc = 'Zoxide',
    })

    vim.keymap.set('n', '<leader>sm', builtin.man_pages, {
      desc = 'Man Pages',
    })

    vim.keymap.set('n', '<leader>s?', builtin.keymaps, {
      desc = 'Keymaps',
    })

    vim.keymap.set('n', '<leader>s:', builtin.command_history, {
      desc = 'Command history',
    })

    vim.keymap.set('n', '<leader>sc', builtin.git_bcommits, {
      desc = 'Git commits',
    })

    vim.keymap.set('n', '<leader>sB', builtin.git_branches, {
      desc = 'Git branches',
    })

    vim.keymap.set('n', '<leader>sa', builtin.git_stash, {
      desc = 'Git stash',
    })
  end,
}
