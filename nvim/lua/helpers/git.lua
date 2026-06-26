local M = {}

---@class ShowCommitOpts
---@field name-only boolean
---TODO: more `git show` stuff here if needed

local g = require 'helpers.general'

---Show git commit in new buffer
---@param commit string
---@param opts? ShowCommitOpts
M.show_commit = function(commit, opts)
  local command = { 'git', 'show' }
  vim.list_extend(command, g.make_args(opts))
  table.insert(command, commit)

  vim.system(
    command,
    { text = true },
    vim.schedule_wrap(function(out)
      if out.code ~= 0 or not out.stdout then
        g.notify('Not a git commit ' .. commit, vim.log.levels.ERROR)
        return
      end

      local output = vim.split(out.stdout, '\n')

      local buf = vim.api.nvim_create_buf(true, true)
      local options = { scope = 'local', buf = buf }

      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_set_option_value('filetype', 'git', options)
      vim.api.nvim_set_option_value('buftype', 'nofile', options)
      vim.api.nvim_set_option_value('bufhidden', 'hide', options)
      vim.api.nvim_set_option_value('swapfile', false, options)

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)

      vim.api.nvim_set_option_value('readonly', true, options)
      vim.api.nvim_set_option_value('modifiable', false, options)
    end)
  )
end

---Show uncommitted changes in quickfix list
---@param opts? table<string, any>
M.show_uncommitted = function(opts)
  local command = { 'git', 'status', '--porcelain', '-u' }

  if opts and opts.args then
    vim.list_extend(command, vim.split(opts.args, ' '))
  end

  vim.system(
    command,
    { text = true },
    vim.schedule_wrap(function(out)
      if out.code ~= 0 or not out.stdout then
        g.notify('Not a git repository', vim.log.levels.ERROR)
        return
      end

      local output = vim.split(out.stdout, '\n')
      local qf_list = {}

      for _, line in ipairs(output) do
        if line ~= '' then
          local status = line:sub(1, 2)
          local file = line:sub(4)

          -- Parse status: first char is index, second is working tree
          local status_text = ''
          if status:match '[MADRCU]' then
            status_text = status:match '^%s' and 'M' or 'S' .. status
          elseif status == '??' then
            status_text = '?'
          elseif status:match '^!' then
            status_text = '!'
          end

          table.insert(qf_list, {
            filename = file,
            text = status_text .. ' ' .. file,
            lnum = 1,
            col = 1,
          })
        end
      end

      if #qf_list > 0 then
        vim.fn.setqflist(qf_list)
        vim.api.nvim_command 'copen'
        g.notify(
          'Showing ' .. #qf_list .. ' uncommitted changes',
          vim.log.levels.INFO
        )
      else
        g.notify('No uncommitted changes found', vim.log.levels.INFO)
      end
    end)
  )
end

--- @param args vim.api.keyset.create_autocmd.callback_args
M.setup = function(args)
  vim.keymap.set({ 'n' }, 'gd', function()
    -- TODO: verify that word under cursor is indeed a commit hash
    M.show_commit(vim.fn.expand '<cword>')
  end, { buf = args.buf })

  vim.keymap.set({ 'n' }, 'gD', function()
    -- TODO: verify that word under cursor is indeed a commit hash
    M.show_commit(vim.fn.expand '<cword>', { ['name-only'] = true })
  end, { buf = args.buf })

  -- Uses custom alias
  vim.keymap.set({ 'n' }, 'rI', '<cmd>Git restack<cr>', { buf = args.buf })
end

return M
