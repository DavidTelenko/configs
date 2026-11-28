return {
  {
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewClose',
      'DiffviewFileHistory',
      'DiffviewFocusFiles',
      'DiffviewLog',
      'DiffviewOpen',
      'DiffviewRefresh',
      'DiffviewToggleFiles',
    },
    keys = {
      { '<leader>gd', desc = 'Toggle Diffview' },
      { '<leader>gDo', desc = 'Open' },
      { '<leader>gDc', desc = 'Close' },
      { '<leader>gDh', desc = 'File history' },
    },
    --- @type DiffviewConfig
    opts = {
      view = {
        merge_tool = {
          layout = 'diff3_mixed',
        },
      },
      file_panel = {
        win_config = {
          width = 30,
        },
      },
    },
    config = function(_, opts)
      local dv = require 'diffview'

      dv.setup(opts)

      vim.keymap.set('n', '<leader>gDo', dv.open, {
        desc = 'Open',
      })

      vim.keymap.set('n', '<leader>gDc', dv.close, {
        desc = 'Close',
      })

      vim.keymap.set('n', '<leader>gDh', dv.file_history, {
        desc = 'File History',
      })

      vim.keymap.set('n', '<leader>gd', function(args)
        local view = require('diffview.lib').get_current_view()
        if view then
          dv.close()
        else
          dv.open(args)
        end
      end, { desc = 'Toggle diffview' })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      signs_staged = {
        add = { text = '' },
        change = { text = '' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '' },
        untracked = { text = '' },
      },
      on_attach = function(buffer)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, {
          buffer = buffer,
          desc = 'Preview git hunk',
        })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns

        for _, conf in ipairs {
          { mapping = ']', invoke = gs.next_hunk, desc = 'Next' },
          { mapping = '[', invoke = gs.prev_hunk, desc = 'Previous' },
        } do
          vim.keymap.set({ 'n', 'v' }, conf.mapping .. 'c', function()
            if vim.wo.diff then
              return conf.mapping .. 'c'
            else
              vim.schedule(conf.invoke)
              return '<Ignore>'
            end
          end, {
            expr = true,
            buffer = buffer,
            desc = conf.desc .. ' git hunk',
          })
        end

        vim.keymap.set('n', '<leader>gs', gs.stage_hunk, {
          desc = 'Stage hunk',
        })

        vim.keymap.set('n', '<leader>gr', gs.reset_hunk, {
          desc = 'Reset hunk',
        })

        vim.keymap.set('n', '<leader>gq', function()
          gs.setqflist 'all'
        end, { desc = 'Hunk quickfix list' })

        vim.keymap.set('v', '<leader>gs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage hunk' })

        vim.keymap.set('v', '<leader>gr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset hunk' })

        vim.keymap.set('n', '<leader>gb', gs.toggle_current_line_blame, {
          desc = 'Toggle git Blame',
        })

        vim.keymap.set('n', '<leader>gB', gs.blame, {
          desc = 'Toggle Blame window',
        })
      end,
    },
  },
  {
    'tpope/vim-fugitive',
    cmd = 'Git',
    -- TODO: add git push --force-with-lease keybinding
    keys = {
      {
        '<leader>gg',
        function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)
            if
              string.find(buf_name, 'fugitive://')
              or string.find(buf_name, 'fugitive:\\\\')
            then
              vim.api.nvim_win_close(win, false)
              return
            end
          end

          local success = pcall(vim.api.nvim_exec2, 'Git', {})
          if not success then
            vim.notify('Not in a git repository', vim.diagnostic.severity.WARN)
          end
        end,
        desc = 'Git menu (fugitive)',
      },
    },
  },
  -- it's a bit sluggish right now, it's really nice plugin, but fugitive
  -- written in vim script for some reason is more optimized ?!
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    enabled = false,
    keys = {
      { '<leader>gg', '<cmd>Neogit<cr>', desc = 'Git menu (Neogit)' },
    },
    opts = {
      -- Hides the hints at the top of the status buffer
      disable_hint = false,
      -- Disables changing the buffer highlights based on where the cursor is.
      disable_context_highlighting = false,
      -- Disables signs for sections/items/hunks
      disable_signs = false,
      -- Offer to force push when branches diverge
      prompt_force_push = true,
      -- Changes what mode the Commit Editor starts in. `true` will leave nvim
      -- in normal mode, `false` will change nvim to insert mode, and `"auto"`
      -- will change nvim to insert mode IF the commit message is empty,
      -- otherwise leaving it in normal mode.
      disable_insert_on_commit = 'auto',
      -- When enabled, will watch the `.git/` directory for changes and refresh
      -- the status buffer in response to filesystem events.
      filewatcher = {
        interval = 1000,
        enabled = true,
      },
      -- "ascii"   is the graph the git CLI generates
      -- "unicode" is the graph like https://github.com/rbong/vim-flog
      -- "kitty"   is the graph like https://github.com/isakbm/gitgraph.nvim - use https://github.com/rbong/flog-symbols if you don't use Kitty
      graph_style = 'unicode',
      -- Show relative date by default. When set, use `strftime` to display dates
      commit_date_format = nil,
      log_date_format = nil,
      -- Used to generate URL's for branch popup action "pull request".
      git_services = {
        ['github.com'] = 'https://github.com/${owner}/${repository}/compare/${branch_name}?expand=1',
        ['bitbucket.org'] = 'https://bitbucket.org/${owner}/${repository}/pull-requests/new?source=${branch_name}&t=1',
        ['gitlab.com'] = 'https://gitlab.com/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}',
        ['azure.com'] = 'https://dev.azure.com/${owner}/_git/${repository}/pullrequestcreate?sourceRef=${branch_name}&targetRef=${target}',
      },
      -- Allows a different telescope sorter. Defaults to 'fuzzy_with_index_bias'. The example below will use the native fzf
      -- sorter instead. By default, this function returns `nil`.
      telescope_sorter = function()
        return require('telescope').extensions.fzf.native_fzf_sorter()
      end,
      -- Persist the values of switches/options within and across sessions
      remember_settings = true,
      -- Scope persisted settings on a per-project basis
      use_per_project_settings = true,
      -- Table of settings to never persist. Uses format "Filetype--cli-value"
      ignored_settings = {
        'NeogitPushPopup--force-with-lease',
        'NeogitPushPopup--force',
        'NeogitPullPopup--rebase',
        'NeogitCommitPopup--allow-empty',
        'NeogitRevertPopup--no-edit',
      },
      -- Configure highlight group features
      highlight = {
        italic = false,
        bold = true,
        underline = true,
      },
      -- Set to false if you want to be responsible for creating _ALL_ keymappings
      use_default_keymaps = true,
      -- Neogit refreshes its internal state after specific events, which can be
      -- expensive depending on the repository size.
      -- Disabling `auto_refresh` will make it so you have to manually refresh the status after you open it.
      auto_refresh = true,
      -- Value used for `--sort` option for `git branch` command
      -- By default, branches will be sorted by commit date descending
      -- Flag description:
      -- https://git-scm.com/docs/git-branch#Documentation/git-branch.txt---sortltkeygt
      -- Sorting keys: https://git-scm.com/docs/git-for-each-ref#_options
      sort_branches = '-committerdate',
      -- Default for new branch name prompts
      initial_branch_name = '',
      -- Change the default way of opening neogit
      kind = 'split_above',
      -- Disable line numbers
      disable_line_numbers = true,
      -- Disable relative line numbers
      disable_relative_line_numbers = true,
      -- The time after which an output console is shown for slow running commands
      console_timeout = 2000,
      -- Automatically show console if a command takes more than console_timeout milliseconds
      auto_show_console = true,
      -- Automatically close the console if the process exits with a 0 (success) status
      auto_close_console = true,
      notification_icon = '󰊢',
      status = {
        show_head_commit_hash = true,
        recent_commit_count = 10,
        HEAD_padding = 10,
        HEAD_folded = false,
        mode_padding = 3,
        mode_text = {
          M = 'M',
          N = 'N',
          A = 'A',
          D = 'D',
          C = 'C',
          U = 'U',
          R = 'R',
          DD = 'DD',
          AU = 'AU',
          UD = 'UD',
          UA = 'UA',
          DU = 'DU',
          AA = 'AA',
          UU = 'UU',
          ['?'] = '?',
        },
      },
      commit_editor = {
        kind = 'split_above',
        show_staged_diff = true,
        -- Accepted values:
        -- "split" to show the staged diff below the commit editor
        -- "vsplit" to show it to the right
        -- "split_above" Like :top split
        -- "vsplit_left" like :vsplit, but open to the left
        -- "auto" "vsplit" if window would have 80 cols, otherwise "split"
        staged_diff_split_kind = 'split',
        spell_check = true,
      },
      commit_select_view = {
        kind = 'tab',
      },
      commit_view = {
        kind = 'vsplit',
        verify_commit = vim.fn.executable 'gpg' == 1, -- Can be set to true or false, otherwise we try to find the binary
      },
      log_view = {
        kind = 'tab',
      },
      rebase_editor = {
        kind = 'auto',
      },
      reflog_view = {
        kind = 'tab',
      },
      merge_editor = {
        kind = 'auto',
      },
      description_editor = {
        kind = 'auto',
      },
      tag_editor = {
        kind = 'auto',
      },
      preview_buffer = {
        kind = 'floating_console',
      },
      popup = {
        kind = 'split',
      },
      stash = {
        kind = 'tab',
      },
      refs_view = {
        kind = 'tab',
      },
      signs = {
        -- { CLOSED, OPENED }
        hunk = { '', '' },
        item = { '', '' },
        section = { '', '' },
      },
      integrations = {
        fzf_lua = nil,
        mini_pick = nil,
      },
    },
  },
}
