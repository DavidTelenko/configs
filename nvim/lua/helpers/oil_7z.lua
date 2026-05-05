local M = {}

local function make_oil_7z_handler(config)
  return function()
    local oil = require 'oil'
    local Progress = require 'oil.mutator.progress'
    local entry = oil.get_cursor_entry()
    local g = require 'helpers.general'

    local progress = Progress.new()
    -- This is hackish
    progress.lines[1] = config.status
    local finished = false

    local function finish()
      if not finished then
        finished = true
        progress:close()
      end
    end

    if not entry or entry.type ~= config.entry_type then
      return
    end

    local dir = oil.get_current_dir()
    local path = dir .. entry.name

    vim.defer_fn(function()
      if not finished then
        progress:show {
          cancel = function()
            finish()
          end,
        }
      end
    end, 100)

    local cmd_opts = config.cmd_opts(path, dir)

    -- TODO: actual progress
    vim.system(
      cmd_opts.command,
      cmd_opts.options,
      vim.schedule_wrap(function(out)
        finish()
        vim.cmd.edit()

        if out.code == 0 then
          g.notify('Successfully ' .. config.name .. 'ed!')
          return
        else
          g.notify('Failed to unpack', vim.log.levels.ERROR)
          g.notify(vim.inspect(out), vim.log.levels.WARN)
        end
      end)
    )
  end
end

M.archive = make_oil_7z_handler {
  name = 'archive',
  status = 'Archiving...',
  entry_type = 'directory',
  cmd_opts = function(entry_path)
    return {
      command = { '7z', 'a', entry_path, '*' },
      options = { cwd = entry_path },
    }
  end,
}

M.unpack = make_oil_7z_handler {
  name = 'unpack',
  status = 'Unpacking...',
  entry_type = 'file',
  cmd_opts = function(entry_path, current_dir)
    return {
      command = { '7z', 'x', entry_path, '-o*' },
      options = { cwd = current_dir },
    }
  end,
}

return M
