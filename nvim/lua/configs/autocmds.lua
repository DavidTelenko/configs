-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank { timeout = 200 }
  end,
  group = vim.api.nvim_create_augroup('YankHighlight', {
    clear = true,
  }),
  pattern = '*',
})

-- netrw keymaps for more 'lettered' experience
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  group = vim.api.nvim_create_augroup('NetrwKeymaps', {
    clear = true,
  }),
  callback = function()
    vim.keymap.set('n', 'l', '<cr>', { buffer = true, remap = true })
    vim.keymap.set('n', 'h', '-', { buffer = true, remap = true })
    vim.keymap.set('n', 'a', '%', { buffer = true, remap = true })
    vim.keymap.set('n', '<F1>', '<Esc>', { buffer = true, remap = true })
  end,
})

-- Git specific features (TODO: research ftplugin a bit more)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'git', 'gitrebase', 'fugitive' },
  group = vim.api.nvim_create_augroup('GitMappings', {
    clear = true,
  }),
  callback = require('helpers.git').setup,
})

-- Clear redundant spaces at the end of lines
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vim.api.nvim_create_augroup('ClearPostSpaces', { clear = true }),
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

-- Disable some options in terminal mode
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('TerminalMode', { clear = true }),
  pattern = '*',
  callback = function()
    vim.o.spell = false
    vim.wo.signcolumn = 'yes'
  end,
})

-- Toggle Quickfix list
vim.api.nvim_create_user_command('ToggleQuickfix', function()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win['quickfix'] == 1 then
      qf_exists = true
    end
  end
  if qf_exists then
    vim.cmd 'cclose'
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd 'copen'
  else
    print 'Quickfix list is empty'
  end
end, {})
