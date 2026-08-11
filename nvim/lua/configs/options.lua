-- Leader mappings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Fallback theme
vim.cmd.colorscheme 'retrobox'

-- window border
vim.o.winborder = 'rounded'

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.o.number = false
vim.o.relativenumber = false

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- This thing ---------------------------------------------------------------->
vim.o.colorcolumn = '80'
-- vim.o.textwidth = 80

-- Scroll will trigger leaving 8 lines at the bottom
vim.o.scrolloff = 8

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.smartindent = true

-- Font
vim.o.guifont = 'RobotoMono Nerd Font:h18'

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,menuone,noinsert'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true
-- vim.o.shell = 'nu'

-- This little circles to see spaces (VS Code habit)
vim.o.list = true
vim.o.listchars = 'tab:· ,trail:·,nbsp:+,space:·'
vim.o.fillchars = vim.o.fillchars .. 'diff:╱'

-- Tabs
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smarttab = true

-- Spellcheck
vim.o.spell = true
vim.o.spelllang = 'en'

-- Wrapping
vim.o.wrap = true
vim.o.linebreak = true
vim.o.smoothscroll = true

-- Folding
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99

-- Path fuzzy
vim.o.path = '.,**'
vim.o.wildmenu = true

-- Netrw
vim.g.netrw_banner = 0
vim.g.netrw_hide = 0
vim.g.netrw_bufsettings = 'noma nomod rnu nowrap ro nobl'

-- Attempt to make it work in ua_uk locale
local function escape(str)
  local escape_chars = [[;,."|\]]
  return vim.fn.escape(str, escape_chars)
end

-- stylua: ignore start
local en_n = [[qwertyuiop[]asdfghjkl;'zxcvbnm]]
local ua_n = [[йцукенгшщзхїфівапролджєячсмить]]
local en_s = [[QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>]]
local ua_s = [[ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄЯЧСМИТЬБЮ]]
-- stylua: ignore end

vim.o.langmap = vim.fn.join({
  escape(ua_n) .. ';' .. escape(en_n),
  escape(ua_s) .. ';' .. escape(en_s),
}, ',')

vim.o.langremap = false
vim.o.fileformats = 'unix,dos'

-- MS Windows shenanigans
-- if vim.fn.has 'win32' == 1 then
--   vim.o.isfname = '@,48-57,/,.,-,_,+,,,#,$,%,~,=,(,),[,]'
--   vim.o.shellslash = true
--   vim.o.completeslash = 'slash'
-- end

-- Custom filetypes
vim.filetype.add {
  extension = {
    ['tdesktop-theme'] = 'css',
    ['mdx'] = 'markdown',
    ['c3'] = 'c3',
    ['c3i'] = 'c3',
    ['c3t'] = 'c3',
    ['kitty-session'] = 'kitty',
    ['me3'] = 'toml',
    ['kk'] = 'koka',
  },
}

-- Neovide setup for easier jumpstart in OS Windows
if vim.g.neovide then
  vim.g.neovide_fullscreen = true
  vim.g.neovide_cursor_trail_size = 0.2
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_left = 10
end

-- Zen mode
vim.g.zen = false
-- remove or comment to disable it by default
require('helpers.zen').toggle_zen_mode()

-- vim: ts=2 sts=2 sw=2 et
