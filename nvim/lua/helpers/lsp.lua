M = {}

--- This function is for LSP when it connects to a particular buffer.
---@param client vim.lsp.Client
---@param buffer number
M.on_attach = function(client, buffer)
  local telescope = require 'telescope.builtin'
  local map = function(keys, desc, func)
    vim.keymap.set({ 'n', 'v' }, keys, func, {
      buffer = buffer,
      desc = desc,
    })
  end

  local function map_next_prev_diagnostic(config)
    local next = { key = ']', count = 1, message = 'Next' }
    local prev = { key = '[', count = -1, message = 'Previous' }

    for _, conf in ipairs { next, prev } do
      map(
        conf.key .. config.key,
        conf.message .. ' ' .. config.message,
        function()
          vim.diagnostic.jump {
            count = conf.count,
            float = true,
            severity = config.severity,
          }
        end
      )
    end
  end

  do -- move
    map_next_prev_diagnostic {
      severity = vim.diagnostic.severity.ERROR,
      key = 'e',
      message = 'error',
    }
    map_next_prev_diagnostic {
      severity = vim.diagnostic.severity.WARN,
      key = 'w',
      message = 'warning',
    }
    map_next_prev_diagnostic {
      severity = nil,
      key = 'd',
      message = 'diagnostic',
    }
  end

  do -- Go to
    map('gd', 'Definition', telescope.lsp_definitions)
    map('gR', 'References', telescope.lsp_references)
    map('gI', 'Implementation', telescope.lsp_implementations)

    -- map('gd', 'Definition', vim.lsp.buf.definition)
    -- map('gR', 'References', vim.lsp.buf.references)
    -- map('gI', 'Implementation', vim.lsp.buf.implementation)

    if client:supports_method('textDocument/declaration', buffer) then
      map('gD', 'Declaration', vim.lsp.buf.declaration)
    end
  end

  do -- actions
    map('<leader>rn', 'Rename', vim.lsp.buf.rename)
    map('<leader>rf', 'Format', vim.lsp.buf.format)
    map('<leader>ca', 'Code Action', vim.lsp.buf.code_action)
    map('<leader>cI', 'Toggle inlay hints', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
    end)
  end

  do -- search
    map('<leader>ss', 'Document Symbols', telescope.lsp_document_symbols)
  end

  do --help
    map('K', 'Hover Documentation', function()
      vim.lsp.buf.hover { border = 'rounded' }
    end)

    -- Never used it???
    -- map('gK', 'Signature Documentation', function()
    --   vim.lsp.buf.signature_help { border = 'rounded' }
    -- end)
  end

  do -- workspace
    map('<leader>wa', 'Add Folder', vim.lsp.buf.add_workspace_folder)
    map('<leader>ws', 'Symbols', telescope.lsp_dynamic_workspace_symbols)
    map('<leader>wr', 'Remove Folder', vim.lsp.buf.remove_workspace_folder)
    map('<leader>wl', 'List Folders', function()
      vim.print(vim.lsp.buf.list_workspace_folders())
    end)
  end
end

return M
