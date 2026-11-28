local M = {}

local wezterm = require 'wezterm' --[[@as Wezterm]]
local act = wezterm.action

M.spawn_next_tab = wezterm.action_callback(function(window, pane)
  local mux_window = window:mux_window()

  local tabs = mux_window:tabs_with_info()
  local current_index = 0
  for _, tab_info in ipairs(tabs) do
    if tab_info.is_active then
      current_index = tab_info.index
      break
    end
  end

  mux_window:spawn_tab {}

  window:perform_action(act.MoveTab(current_index + 1), pane)
end)

M.vim_scrollback = wezterm.action_callback(function(window, pane)
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)

  local name = os.tmpname()
  local f = io.open(name, 'w+')

  if f == nil then
    wezterm.log_info 'Temp file does not exist'
    return
  end

  f:write(text)
  f:flush()
  f:close()

  window:perform_action(
    act.SpawnCommandInNewTab {
      args = { 'nvim', name },
    },
    pane
  )

  wezterm.sleep_ms(1000)
  os.remove(name)
end)

M.new_workspace = act.PromptInputLine {
  description = wezterm.format {
    { Attribute = { Intensity = 'Bold' } },
    { Foreground = { AnsiColor = 'Green' } },
    { Text = 'Enter name for new workspace' },
  },
  action = wezterm.action_callback(function(window, pane, line)
    if not line then
      return
    end
    window:perform_action(
      act.SwitchToWorkspace {
        name = line,
      },
      pane
    )
  end),
}

return M
