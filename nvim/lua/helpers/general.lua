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

M.require_available = make_require(is_available)
M.require_config = make_require(is_config_present)

return M
