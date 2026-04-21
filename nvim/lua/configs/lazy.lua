local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  defaults = {
    lazy = true,
    version = nil,
    cond = nil,
  },
  spec = {
    { import = 'plugins.core' },
    { import = 'plugins.menus' },
    { import = 'plugins.motions' },
    { import = 'plugins.specifics' },
    { import = 'plugins.themes' },
  },
  git = {
    log = { '-8' },
    timeout = 120,
    url_format = 'https://github.com/%s.git',
    filter = true,
  },
  install = {
    missing = true,
    colorscheme = { 'gruvbox' },
  },
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = true,
    border = 'rounded',
    backdrop = 60,
    title = 'Lazy',
    title_pos = 'center',
    pills = true,
    icons = {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
      import = ' ',
      loaded = '',
      not_loaded = '',
      list = {
        '●',
        '➜',
        '★',
        '‒',
      },
    },
    browser = nil,
    throttle = 20,
    custom_keys = {},
  },
  diff = {
    cmd = 'git',
  },
  checker = {
    enabled = false,
    ---@type number? set to 1 to check for updates very slowly
    concurrency = nil,
    notify = true, -- get a notification when new updates are found
    frequency = 3600, -- check for updates every hour
    check_pinned = false, -- check for pinned packages that can't be updated
  },
  change_detection = {
    enabled = true,
    notify = false, -- get a notification when changes are found
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true, -- reset the package path to improve startup time
    rtp = {
      reset = true, -- reset the runtime path to $VIMRUNTIME and your config directory
      paths = {}, -- add any custom paths here that you want to includes in the rtp
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        -- 'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
  readme = {
    enabled = true,
    root = vim.fn.stdpath 'state' .. '/lazy/readme',
    files = { 'README.md', 'lua/**/README.md' },
    skip_if_doc_exists = true,
  },
  state = vim.fn.stdpath 'state' .. '/lazy/state.json', -- state info for checker and other things
  build = {
    warn_on_override = true,
  },
  profiling = {
    loader = false,
    require = false,
  },
}

-- built-in plugins
vim.cmd.packadd 'nvim.undotree'
vim.cmd.packadd 'nvim.difftool'
