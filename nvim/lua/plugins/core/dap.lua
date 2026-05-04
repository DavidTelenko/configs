return {
  { 'rcarriga/nvim-dap-ui' },
  { 'theHamsta/nvim-dap-virtual-text' },
  { 'jay-babu/mason-nvim-dap.nvim' },
  { 'nvim-neotest/nvim-nio' },
  {
    'mfussenegger/nvim-dap',
    enabled = false,
    keys = {
      { '<leader>du', desc = 'Open Ui' },
      { '<leader>dB', desc = 'Set Breakpoint' },
      { '<leader>db', desc = 'Toggle Breakpoint' },
      { '<leader>b', desc = 'Toggle Breakpoint' },
      { '<leader>dc', desc = 'Start/Continue' },
      { '<leader>dO', desc = 'Step Out' },
      { '<leader>do', desc = 'Step Over' },
      { '<leader>di', desc = 'Step Into' },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        automatic_setup = true,
        automatic_installation = true,

        handlers = {
          function(config)
            if vim.fn.has 'win32' == 1 then
              pcall(function()
                config.adapters.executable.detached = false
              end)
            end
            require('mason-nvim-dap').default_setup(config)
          end,

          cppdbg = function(config)
            if vim.fn.has 'win32' == 1 then
              config.adapters['command'] = vim.fn.stdpath 'data'
                .. '/mason/bin/OpenDebugAD7.cmd'
            end
            require('mason-nvim-dap').default_setup(config)
          end,

          python = function(config)
            config.adapters = {
              type = 'executable',
              command = 'python',
              args = {
                '-m',
                'debugpy.adapter',
              },
            }
            config.configurations = {
              {
                type = 'python',
                request = 'launch',
                name = 'Python: Launch file',
                program = '${file}',
                pythonPath = function()
                  return vim.fn.exepath 'python'
                end,
                console = 'integratedTerminal',
              },
            }
            require('mason-nvim-dap').default_setup(config)
          end,
        },

        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          -- 'cppdbg',
          -- 'python',
          -- 'delve',
        },
      }

      dap.adapters['pwa-node'] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          detached = false,
          command = vim.fn.stdpath 'data' .. '/mason/bin/js-debug-adapter.cmd',
          args = { '${port}' },
        },
      }

      for _, language in ipairs {
        'typescript',
        'typescriptreact',
        'javascript',
        'javascriptreact',
      } do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Jest Tests',
            -- trace = true, -- include debugger info
            runtimeExecutable = 'node',
            runtimeArgs = {
              './node_modules/jest/bin/jest.js',
              '--runInBand',
            },
            rootPath = '${workspaceFolder}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
          },
        }
      end

      vim.keymap.set('n', '<leader>di', dap.step_into, {
        desc = 'Step Into',
      })

      vim.keymap.set('n', '<leader>do', dap.step_over, {
        desc = 'Step Over',
      })

      vim.keymap.set('n', '<leader>dO', dap.step_out, {
        desc = 'Step Out',
      })

      vim.keymap.set('n', '<leader>dc', dap.continue, {
        desc = 'Start/Continue',
      })

      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, {
        desc = 'Toggle Breakpoint',
      })

      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, {
        desc = 'Toggle Breakpoint',
      })

      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Set Breakpoint' })

      -- Toggle to see last session result.
      vim.keymap.set('n', '<leader>du', dapui.toggle, {
        desc = 'Open Ui',
      })

      -- Dap UI setup
      dapui.setup()
      require('nvim-dap-virtual-text').setup {}

      vim.api.nvim_set_hl(0, 'DapBreakpoint', {
        ctermbg = 0,
        bg = '#261c1c',
      })

      vim.api.nvim_set_hl(0, 'DapLogPoint', {
        ctermbg = 0,
        bg = '#261c1c',
      })

      vim.api.nvim_set_hl(0, 'DapStopped', {
        ctermbg = 0,
        bg = '#261c1c',
      })

      vim.fn.sign_define('DapBreakpoint', {
        text = '',
        texthl = 'WarningMsg',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint',
      })

      vim.fn.sign_define('DapBreakpointCondition', {
        text = '',
        texthl = 'Question',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint',
      })

      vim.fn.sign_define('DapBreakpointRejected', {
        text = '',
        texthl = 'WarningMsg',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint',
      })

      vim.fn.sign_define('DapLogPoint', {
        text = '',
        texthl = 'Question',
        linehl = 'DapLogPoint',
        numhl = 'DapLogPoint',
      })

      vim.fn.sign_define('DapStopped', {
        text = '',
        texthl = 'WarningMsg',
        linehl = 'DapStopped',
        numhl = 'DapStopped',
      })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
}
