local M = {}

---@class ShowCommitOpts
---@field name-only boolean
---TODO: more `git show` stuff here if needed

local g = require 'helpers.general'

---Show git commit in new buffer
---@param commit string
---@param opts? ShowCommitOpts
local show_commit = function(commit, opts)
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

M.setup = function()
  vim.keymap.set({ 'n' }, 'gd', function()
    -- TODO: verify that word under cursor is indeed a commit hash
    show_commit(vim.fn.expand '<cword>')
  end)

  vim.keymap.set({ 'n' }, 'gD', function()
    -- TODO: verify that word under cursor is indeed a commit hash
    show_commit(vim.fn.expand '<cword>', { ['name-only'] = true })
  end)
end

return M
