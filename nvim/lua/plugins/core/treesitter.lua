return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    lazy = false,
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      local textobjects = require 'nvim-treesitter-textobjects'
      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'

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

      local function outer(query)
        return '@' .. query .. '.outer'
      end
      local function inner(query)
        return '@' .. query .. '.inner'
      end

      for mapping, query in pairs {
        a = 'parameter',
        f = 'function',
        c = 'class',
        b = 'block',
        ['='] = 'assignment',
      } do
        local modes = { 'x', 'o' }

        vim.keymap.set(modes, 'i' .. mapping, function()
          select.select_textobject(inner(query))
        end, { desc = 'inner ' .. query })
        vim.keymap.set(modes, 'a' .. mapping, function()
          select.select_textobject(outer(query))
        end, { desc = 'outer ' .. query })
      end

      for mapping, query in pairs {
        a = 'parameter',
        f = 'function',
        l = 'class',
        b = 'block',
      } do
        local modes = { 'n', 'x', 'o' }
        local outer_query = outer(query)
        local start_mapping = mapping
        local end_mapping = mapping:upper()

        vim.keymap.set(modes, ']' .. start_mapping, function()
          move.goto_next_start(outer_query)
        end, { desc = 'Next ' .. query .. ' start' })
        vim.keymap.set(modes, ']' .. end_mapping, function()
          move.goto_next_end(outer_query)
        end, { desc = 'Next ' .. query .. ' end' })
        vim.keymap.set(modes, '[' .. start_mapping, function()
          move.goto_previous_start(outer_query)
        end, { desc = 'Previous ' .. query .. ' start' })
        vim.keymap.set(modes, '[' .. end_mapping, function()
          move.goto_previous_end(outer_query)
        end, { desc = 'Previous ' .. query .. ' end' })
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local languages = {
        'bash',
        'c',
        'c3',
        'comment',
        'cpp',
        'css',
        'go',
        'javascript',
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
      }
      require('nvim-treesitter').install(languages)

      --- This is quite hacky solution but used everywhere to avoid ftplugin
      --- fallback (e.g telescope, older treesitter plugin)
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('NvimTreesitter', {}),
        callback = function(args)
          local filetype = vim.bo[args.buf].ft

          if not filetype or filetype == '' then
            return
          end

          local language = vim.treesitter.language.get_lang(filetype)
            or filetype

          if vim.treesitter.language.add(language) then
            return vim.treesitter.start(args.buf, language)
          end
        end,
      })
    end,
  },
}
