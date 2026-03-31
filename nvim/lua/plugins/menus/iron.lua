return {
  'Vigemus/iron.nvim',
  keys = {
    { '<leader>i<space>', desc = 'Interrupt' },
    { '<leader>iR', '<cmd>IronRestart<cr>', desc = 'Restart Repl' },
    { '<leader>ib', desc = 'Send Code Block' },
    { '<leader>ic', desc = 'Clear' },
    { '<leader>if', desc = 'Send File' },
    { '<leader>il', desc = 'Send Line' },
    { '<leader>im', desc = 'Send Mark' },
    { '<leader>ip', desc = 'Send Paragraph' },
    { '<leader>iq', desc = 'Exit' },
    { '<leader>ir', '<cmd>IronRepl<cr>', desc = 'Toggle Repl' },
    { '<leader>iu', desc = 'Send Until Cursor' },
    { '<leader>iv', desc = 'Visual Send', mode = 'v' },
    { '<C-`>', desc = 'Open terminal' },
    { '<leader>t', desc = 'Open terminal' },
  },
  config = function()
    local iron = require 'iron.core'
    local view = require 'iron.view'

    iron.setup {
      config = {
        scratch_repl = true,
        repl_definition = {
          typescript = {
            command = { 'node', '--experimental-transform-types' },
          },
          javascript = {
            command = { 'node' },
          },
          lua = {
            command = { 'lua' },
          },
          nu = {
            command = { 'nu' },
          },
          sh = {
            command = { 'bash' },
          },
        },
        repl_open_cmd = {
          -- view.split.vertical.botright(0.4),
          view.split.horizontal.botright(0.4),
        },
      },
      highlight = {
        bold = true,
      },
      ignore_blank_lines = true,
    }

    vim.keymap.set('v', '<leader>iv', iron.visual_send, {
      desc = 'Visual Send',
    })

    vim.keymap.set('n', '<leader>if', iron.send_file, {
      desc = 'Send File',
    })

    vim.keymap.set('n', '<leader>il', iron.send_line, {
      desc = 'Send Line',
    })

    vim.keymap.set('n', '<leader>ip', iron.send_paragraph, {
      desc = 'Send Paragraph',
    })

    vim.keymap.set('n', '<leader>iu', iron.send_until_cursor, {
      desc = 'Send Until Cursor',
    })

    vim.keymap.set('n', '<leader>im', iron.send_mark, {
      desc = 'Send Mark',
    })

    vim.keymap.set('n', '<leader>ib', iron.send_code_block, {
      desc = 'Send Code Block',
    })

    vim.keymap.set('n', '<leader>iq', iron.close_repl, {
      desc = 'Exit',
    })

    vim.keymap.set('n', '<leader>i<space>', function()
      iron.send(nil, string.char(03))
    end, { desc = 'Interrupt' })

    local function toggle_repl()
      local meta = iron.repl_for 'nu'
      local winid = vim.fn.bufwinid(meta.bufnr)
      if winid ~= -1 then
        vim.api.nvim_set_current_win(winid)
        -- vim.cmd.startinsert()
      end
    end

    vim.keymap.set({ 'n', 't' }, '<C-`>', toggle_repl, {
      desc = 'Open terminal',
    })

    vim.keymap.set('n', '<leader>t', toggle_repl, {
      desc = 'Open terminal',
    })
  end,
}
