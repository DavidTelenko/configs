local M = {}

--- Serialize a quickfix list to a string format
--- Format: filename:line or filename:line:col or filename:line:col: type: message
---@param qf_list table[] List of quickfix items
---@return string Serialized quickfix list as string
function M.serialize(qf_list)
  local lines = {}

  for _, item in ipairs(qf_list) do
    local filename = item.bufnr and vim.fn.bufname(item.bufnr) or ''
    local lnum = item.lnum or 0
    local col = item.col or 0
    local type_char = item.type or ''
    local text = item.text or ''

    local line
    -- If text equals filename, treat it as no message
    if text == filename then
      text = ''
    end

    if text == '' and type_char == '' then
      -- Format: filename:line:col or filename:line
      if col == 0 then
        line = string.format('%s:%d', filename, lnum)
      else
        line = string.format('%s:%d:%d', filename, lnum, col)
      end
    elseif type_char ~= '' then
      -- Format: filename:line:col: type: message
      line =
        string.format('%s:%d:%d: %s: %s', filename, lnum, col, type_char, text)
    else
      -- Format: filename:line:col message (no trailing colon)
      line = string.format('%s:%d:%d: %s', filename, lnum, col, text)
    end
    table.insert(lines, line)
  end

  return table.concat(lines, '\n')
end

--- Deserialize a string into a quickfix list format
--- Supports multiple formats:
--- 1. filename:line
--- 2. filename:line:col (text defaults to filename as vim does)
--- 3. filename:line:col message
--- 4. filename:line:col: type: message
---@param content string Content to deserialize
---@return table[] Parsed quickfix list
function M.deserialize(content)
  local qf_list = {}

  for line in content:gmatch '[^\r\n]+' do
    if line:match '%S' then -- Skip empty lines
      -- Try to parse the line in various formats
      local filename, lnum, col, type_char, text

      -- Format: filename:line:col: type: message
      filename, lnum, col, type_char, text =
        line:match '^(.-)%:(%d+)%:(%d+)%:%s*(%w+)%:%s*(.*)$'

      if not filename then
        -- Format: filename:line:col: message (with space, no colon)
        filename, lnum, col, text = line:match '^(.-)%:(%d+)%:(%d+)%:%s+(.+)$'
      end

      if not filename then
        -- Format: filename:line:col (no message, text defaults to filename)
        filename, lnum, col = line:match '^(.-)%:(%d+)%:(%d+)$'
      end

      if not filename then
        -- Format: filename:line
        filename, lnum = line:match '^(.-)%:(%d+)$'
        col = '0'
        type_char = ''
        text = filename -- Default to filename
      end

      if filename and lnum then
        table.insert(qf_list, {
          filename = filename,
          lnum = tonumber(lnum),
          col = tonumber(col or 0),
          type = type_char,
          text = text or filename,
        })
      end
    end
  end

  return qf_list
end

--- Read current buffer and parse it as a quickfix list, then load it
---@return boolean Success status
function M.load_from_buffer()
  -- Get all lines from current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')

  -- Deserialize the content
  local qf_list = M.deserialize(content)

  if #qf_list == 0 then
    vim.notify('No valid quickfix entries found in buffer', vim.log.levels.WARN)
    return false
  end

  -- Set the quickfix list
  vim.fn.setqflist(qf_list)

  -- Open quickfix window
  vim.cmd 'copen'

  vim.notify(
    string.format('Loaded %d entries into quickfix list', #qf_list),
    vim.log.levels.INFO
  )
  return true
end

--- Save current quickfix list to a buffer
---@return boolean Success status
function M.save_to_buffer()
  -- Get current quickfix list
  local qf_list = vim.fn.getqflist()

  if #qf_list == 0 then
    vim.notify('Quickfix list is empty', vim.log.levels.WARN)
    return false
  end

  -- Serialize the quickfix list
  local content = M.serialize(qf_list)

  -- Create a new buffer
  vim.cmd 'new'
  local bufnr = vim.api.nvim_get_current_buf()

  -- Set buffer options
  local options = { scope = 'local', buf = bufnr }
  vim.api.nvim_set_option_value('buftype', 'nofile', options)
  vim.api.nvim_set_option_value('bufhidden', 'hide', options)
  vim.api.nvim_set_option_value('swapfile', false, options)

  -- Write the content to the buffer
  local lines = vim.split(content, '\n')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  vim.notify(
    string.format('Saved %d entries to buffer', #qf_list),
    vim.log.levels.INFO
  )
  return true
end

return M
