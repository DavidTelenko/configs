local M = {}

local is_available = function(fmt)
  return require('conform').get_formatter_info(fmt).available ~= nil
end

local is_non_empty = function(tbl)
  if type(tbl) == 'table' then
    return not vim.tbl_isempty(tbl)
  end
  return not not tbl
end

local is_config_present = function(fmt)
  return vim.fs.root(vim.fn.getcwd(), require('helpers.root_markers')[fmt])
    ~= nil
end

--- @param predicate fun(fmt: string): boolean
--- @return fun(list: table|string): string[]
local make_require = function(predicate)
  return function(list)
    if type(list) == 'string' then
      return predicate(list) and { list } or {}
    end

    return vim.iter(list):flatten():filter(predicate):totable()
  end
end

--- Returns first element from flattened table with all non-empty elements
---@param list table
---@return table
M.first = function(list)
  return vim
    .iter(list)
    :filter(is_non_empty)
    :take(1)
    :flatten(math.huge)
    :totable()
end

--- Returns flattened table with all non-empty elements
---@param list table
---@return table
M.all = function(list)
  return vim.iter(list):filter(is_non_empty):flatten(math.huge):totable()
end

---Searches for the file walking up the tree starting from the directory
---provided by `root` searching for the file provided by `search_path`
---stops at directory provided by `stop`.
---@param search string | string[] target filename or filename variants
---@param root? string relative path to search from (defaults to `vim.api.nvim_buf_get_name(0)`)
---@param stop? string file to stop at (defaults to `vim.fn.getcwd`)
---@return string | nil search_path absolute path to found target filename
M.root_relative = function(search, root, stop)
  local Path = require 'plenary.path'

  local current = Path:new(root or vim.api.nvim_buf_get_name(0)):absolute()
  stop = stop or vim.fn.getcwd()

  if type(search) == 'string' then
    while current ~= stop and current ~= '/' and current ~= '' do
      if Path:new(current, search):exists() then
        return current
      end

      current = Path:new(current):parent():absolute()
    end
    return
  end

  while current ~= stop and current ~= '/' and current ~= '' do
    for _, search_variant in ipairs(search) do
      if Path:new(current, search_variant):exists() then
        return current
      end
    end

    current = Path:new(current):parent():absolute()
  end
end

---Transforms table of arguments to cli arguments
---@param args? table<string,string|number|boolean>
---@return table<string>
M.make_args = function(args)
  return vim
    .iter(args or {})
    :map(function(key, value)
      if type(value) == 'boolean' then
        if not value then
          return
        end
        return '--' .. key
      end
      return '--' .. key .. '=' .. tostring(value)
    end)
    :totable()
end

---Safer vim.notify for fast event contexts
M.notify = function(msg, level)
  if vim.in_fast_event() then
    vim.schedule(function()
      vim.notify(msg, level)
    end)
  else
    vim.notify(msg, level)
  end
end

---Returns current visual selection by temporarily copying it to register `v`
---@return string
M.visual_selection = function()
  local saved_reg = vim.fn.getreg 'v'
  vim.cmd [[noa silent norm! "vy]]
  local selection = vim.fn.getreg 'v'
  vim.fn.setreg('v', saved_reg)
  return selection
end

M.require_available = make_require(is_available)
M.require_config = make_require(is_config_present)

return M
