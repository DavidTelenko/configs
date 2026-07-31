return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    lazy = false,
    init = function()
      vim.g.no_plugin_maps = true
      if vim.fn.has 'win32' == 1 then
        vim.env.CC = 'gcc'
      end
    end,
    config = function()
      local textobjects = require 'nvim-treesitter-textobjects'

      textobjects.setup {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
        },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'
      local map = vim.keymap.set

      for mapping, query in pairs {
        a = 'parameter',
        f = 'function',
        c = 'class',
        b = 'block',
        -- ['='] = 'assignment', -- TODO: figure out letter binding
      } do
        local outer_query = '@' .. query .. '.outer'
        local inner_query = '@' .. query .. '.inner'
        local upper_mapping = mapping:upper()

        do -- select
          map({ 'x', 'o' }, 'i' .. mapping, function()
            select.select_textobject(inner_query)
          end, { desc = 'inner ' .. query })

          map({ 'x', 'o' }, 'a' .. mapping, function()
            select.select_textobject(outer_query)
          end, { desc = 'outer ' .. query })
        end

        do -- move
          map({ 'n', 'x', 'o', 'v' }, ']' .. mapping, function()
            move.goto_next_start(outer_query)
          end, { desc = 'Next ' .. query .. ' start' })

          map({ 'n', 'x', 'o', 'v' }, ']' .. upper_mapping, function()
            move.goto_next_end(outer_query)
          end, { desc = 'Next ' .. query .. ' end' })

          map({ 'n', 'x', 'o', 'v' }, '[' .. mapping, function()
            move.goto_previous_start(outer_query)
          end, { desc = 'Previous ' .. query .. ' start' })

          map({ 'n', 'x', 'o', 'v' }, '[' .. upper_mapping, function()
            move.goto_previous_end(outer_query)
          end, { desc = 'Previous ' .. query .. ' end' })
        end

        do -- swap
          map({ 'n' }, '<leader>S' .. mapping, function()
            swap.swap_next(inner_query)
          end, { desc = 'Swap next ' .. query })

          map({ 'n' }, '<leader>S' .. upper_mapping, function()
            swap.swap_previous(inner_query)
          end, { desc = 'Swap previous ' .. query })
        end
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    dependencies = { 'Hdoc1509/gh-actions.nvim' },
    config = function()
      require('gh-actions.tree-sitter').setup()

      local languages = {
        'bash',
        'c',
        'c3',
        'comment',
        'cpp',
        'css',
        'diff',
        'go',
        'javascript',
        'jsdoc',
        'json',
        'lua',
        'markdown',
        'markdown_inline',
        'nu',
        'python',
        'regex',
        'rust',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
        'zig',
      }
      require('nvim-treesitter').install(languages)

      --- This is quite hacky solution but used everywhere to avoid ftplugin
      --- fallback (e.g telescope, older treesitter plugin)
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('NvimTreesitter', {}),
        callback = function(args)
          local filetype = vim.bo[args.buf].ft
          local language = vim.treesitter.language.get_lang(filetype)
            or filetype

          if
            language
            and language ~= ''
            and vim.treesitter.language.add(language)
          then
            return vim.treesitter.start(args.buf, language)
          end
        end,
      })
    end,
  },
}
