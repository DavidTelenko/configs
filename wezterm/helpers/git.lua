local wezterm = require 'wezterm' --[[@as Wezterm]]
local M = {}

--- @param window Window
local function cwd(window)
  local tab = window:active_tab()
  local pane = tab and tab:active_pane()
  local cwd = pane and pane:get_current_working_dir()
  local file_path = cwd and cwd.file_path
  if file_path and wezterm.target_triple:match 'windows' then
    return file_path:sub(2)
  end
  return file_path
end

M.get_head = function(git_dir)
  if not git_dir then
    return nil
  end

  local f_head = io.open(git_dir .. '/HEAD')

  if not f_head then
    return nil
  end

  local HEAD = f_head:read()
  f_head:close()

  local branch = HEAD:match 'ref: refs/heads/(.+)$'

  if branch then
    return branch
  end

  return HEAD:sub(1, 6)
end

--- @param window Window
M.branch = function(window)
  return M.get_head(cwd(window) .. '/.git')
end

return M
