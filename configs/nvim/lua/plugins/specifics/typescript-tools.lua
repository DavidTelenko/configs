return {
  'pmizio/typescript-tools.nvim',
  event = 'VeryLazy',
  enabled = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig',
  },
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  opts = {
    on_attach = require('helpers.lsp').on_attach,
  },
}
