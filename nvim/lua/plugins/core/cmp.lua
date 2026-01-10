return {
  -- Autocompletion
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- Snippet Engine
    'L3MON4D3/LuaSnip',
    'rafamadriz/friendly-snippets',

    -- Sources
    'hrsh7th/cmp-nvim-lsp',
    -- 'hrsh7th/cmp-calc',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-emoji',
    'chrisgrieser/cmp-nerdfont',
    'saadparwaiz1/cmp_luasnip',

    -- Completion icons
    'onsails/lspkind.nvim',
  },
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'

    require('luasnip.loaders.from_vscode').lazy_load()

    luasnip.config.setup {}

    cmp.setup.filetype('TelescopePrompt', {
      enabled = false,
    })

    cmp.setup {
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'buffer' },
        { name = 'path' },
      }, {
        -- { name = 'calc' },
        { name = 'emoji' },
        { name = 'nerdfont' },
      }),
      window = {
        completion = cmp.config.window.bordered { border = 'rounded' },
        documentation = cmp.config.window.bordered { border = 'rounded' },
      },
      formatting = {
        fields = {
          'icon',
          'abbr',
          -- 'kind', -- experimenting with this
          'menu',
        },
      },
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      mapping = {
        ['<Tab>'] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(1) then
            luasnip.jump(1)
          elseif cmp.visible() then
            cmp.confirm {
              select = true,
              behavior = cmp.ConfirmBehavior.Insert,
            }
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if luasnip.locally_jumpable(-1) then
            return luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<Down>'] = cmp.mapping.select_next_item(),
        ['<A-j>'] = cmp.mapping.select_next_item(),
        ['<Up>'] = cmp.mapping.select_prev_item(),
        ['<A-k>'] = cmp.mapping.select_prev_item(),
        ['<A-i>'] = cmp.mapping.complete(),
        ['<A-u>'] = cmp.mapping.scroll_docs(-4),
        ['<A-d>'] = cmp.mapping.scroll_docs(4),
      },
    }
  end,
}
