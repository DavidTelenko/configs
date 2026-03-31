local silent_expr = { expr = true, silent = true }
local silent = { silent = true }
local map = vim.keymap.set

do -- Un-maps (some clumsiness / muscle memory unlearning)
  map({ 'n', 'v' }, '<Space>', '<NOP>', silent)
  map({ 'n', 'i', 'v' }, '<F1>', '<NOP>', silent)

  map('n', '<C-u>', '<NOP>')
  map('n', '<C-d>', '<NOP>')
  map('n', '<C-o>', '<NOP>')
  map('n', '<C-i>', '<NOP>')

  map('i', '<C-k>', '<NOP>')
  map('i', '<C-j>', '<NOP>')
end

do -- System-wide remapped keys
  map({ 'n', 'v' }, '<A-u>', '<C-u>zz')
  map({ 'n', 'v' }, '<PageUp>', '<C-u>zz')

  map({ 'n', 'v' }, '<A-d>', '<C-d>zz')
  map({ 'n', 'v' }, '<PageDown>', '<C-d>zz')

  map({ 'n', 'v' }, '<A-o>', '<C-o>')
  map({ 'n', 'v' }, '<A-i>', '<C-i>')
  map({ 'n', 'v' }, '<A-r>', '<C-r>')
end

do -- Jumps
  -- L and H - begin and end of the line
  -- Who uses Low Middle High after all?
  map({ 'n', 'v' }, 'L', '$')
  map({ 'n', 'v' }, 'H', '_')

  -- Begin end of a tag
  map('n', ']t', 'vat<esc>', { desc = 'Next tag' })
  map('n', '[t', 'vato<esc>', { desc = 'Prev tag' })
end

do -- Go to
  -- Matching bracket
  map('n', 'gm', '%', { desc = 'Matching' })

  -- Windows (panes)
  map('n', 'gh', '<C-w>h', { desc = 'Left pane' })
  map('n', 'gj', '<C-w>j', { desc = 'Bottom pane' })
  map('n', 'gk', '<C-w>k', { desc = 'Top pane' })
  map('n', 'gl', '<C-w>l', { desc = 'Right pane' })
end

do -- QoL improvements
  -- Remap asymmetric + -
  map('n', '_', '-')

  -- Paste without reyanking
  map('v', 'p', 'P', {
    desc = 'Paste without copying selected text in visual mode',
  })

  -- Navigation in insert mode
  map('i', '<A-k>', '<up>')
  map('i', '<A-h>', '<left>')
  map('i', '<A-l>', '<right>')
  map('i', '<A-j>', '<down>')
  map('i', '<A-b>', '<C-o>b')
  map('i', '<A-w>', '<C-o>w')

  -- Actions in insert mode
  map({ 'i', 't' }, '<C-H>', '<C-w>')
  map({ 'i', 't' }, '<C-BS>', '<C-w>')
  map({ 'i', 't' }, '<A-BS>', '<C-w>')
  map({ 'i', 't' }, '<C-D>', '<C-o>dw')

  -- Remaps for dealing with word wrap
  map('n', '0', "v:count == 0 ? 'g0' : '0'", silent_expr)
  map('n', '$', "v:count == 0 ? 'g$' : '$'", silent_expr)
  map({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", silent_expr)
  map({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", silent_expr)

  -- How do i exit terminal in vim?
  map('t', '<C-ESC>', '<C-\\><C-n>')

  -- Toggle quickfix
  map('n', '<leader>q', function()
    vim.cmd 'ToggleQuickfix'
  end, {
    silent = true,
    desc = 'Toggle quickfix',
  })

  -- Zen mode
  map('n', '<leader>z', require('helpers.zen').toggle_zen_mode, {
    desc = 'Zen Mode',
  })

  -- Command sugar to replace current selection
  local desc = { desc = 'Replace current selection' }
  map('v', '<leader>rr', '"hy:%s/<C-r>h//g<left><left>', desc)
  map('n', '<leader>rr', '"hyiw:%s/<C-r>h//g<left><left>', desc)
end

do -- Buffer related keymaps
  map('n', '<leader><cr>', function()
    vim.cmd 'only'
  end, { desc = 'Focus current buffer' })

  map('n', '<leader>fx', function()
    vim.cmd '%bd'
  end, { desc = 'Delete all buffers' })
end

do -- File / Path related keymaps
  map('n', '<leader>fy', function()
    vim.fn.setreg('+', vim.fn.expand '%:.')
  end, { desc = 'Yank path' })

  map('n', '<leader>fh', function()
    vim.cmd 'TOhtml'
  end, { desc = 'To HTML' })

  map('n', '<leader>fs', ':w !sudo tee %<cr>', {
    desc = 'Sudo save',
  })

  map('n', '<leader>f\\/', function()
    vim.cmd '%s/\\\\/\\//g'
  end, { desc = 'Replace \\ with /' })
end

do -- Tabs
  map({ 'n' }, 'gt', function()
    vim.api.nvim_exec2('tabnew', {})
  end)

  for i = 1, 9 do
    map({ 'n', 'i', 't' }, '<M-' .. i .. '>', function()
      pcall(vim.api.nvim_exec2, 'tabn' .. i, {})
    end)

    map({ 'n' }, 'g' .. i, function()
      pcall(vim.api.nvim_exec2, 'tabn' .. i, {})
    end)
  end
end

do -- Lua execute
  map('n', '<leader>cX', '<cmd>source %<CR>', {
    desc = 'Execute this file with lua',
  })

  map('n', '<leader>cx', '<cmd>.lua<CR>', {
    desc = 'Execute current line with lua',
  })

  map('v', '<leader>cx', '<cmd>lua<CR>', {
    desc = 'Execute current selection with lua',
  })
end

do -- to Common User Access or not to Common User Access?
  map({ 'n', 'i', 't' }, '<C-S-w>', function()
    vim.cmd 'q'
  end)

  map({ 'n', 'i' }, '<A-s>', function()
    vim.cmd 'noa update'
  end)
end

do -- silent quickfix navigation
  map({ 'n' }, ']q', '<cmd>silent cnext<cr>')
  map({ 'n' }, '[q', '<cmd>silent cprev<cr>')
end
