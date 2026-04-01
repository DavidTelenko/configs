local wezterm = require 'wezterm' --[[@as Wezterm]]
local keybinds = require 'helpers.keybinds'

-- wezterm.plugin.require 'https://github.com/abidibo/wezterm-sessions'
require 'plugins.tabline'

local config = wezterm.config_builder()
local act = wezterm.action

if wezterm.target_triple == 'aarch64-apple-darwin' then
  config.default_prog = { '/opt/homebrew/bin/nu' }
else
  config.default_prog = { 'nu' }
end

config.automatically_reload_config = true

config.tab_max_width = 30
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.enable_tab_bar = true
config.native_macos_fullscreen_mode = true
config.enable_wayland = true
-- config.window_background_opacity = 0.8
-- config.win32_system_backdrop = 'Acrylic'

config.font = wezterm.font 'RobotoMono Nerd Font'
config.font_size = 18

config.window_padding = {
  top = 0,
  bottom = 0,
}

config.color_scheme = 'GruvboxDark'
config.colors = {
  background = 'black',
  tab_bar = {
    background = require('tabline.config').theme.normal_mode.c.bg,
  },
}

config.keys = {
  {
    key = 'u',
    mods = 'CTRL|SHIFT',
    action = act.ScrollByPage(-1),
  },
  {
    key = 'd',
    mods = 'CTRL|SHIFT',
    action = act.ScrollByPage(1),
  },
  {
    key = 'k',
    mods = 'CTRL|SHIFT',
    action = act.ScrollByLine(-1),
  },
  {
    key = 'j',
    mods = 'CTRL|SHIFT',
    action = act.ScrollByLine(1),
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  },
  {
    key = 'a',
    mods = 'CTRL|SHIFT',
    action = act.ShowTabNavigator,
  },
  {
    key = 'Backspace',
    mods = 'CTRL',
    action = act.SendKey {
      key = 'w',
      mods = 'CTRL',
    },
  },
  {
    key = 'N',
    mods = 'CTRL|SHIFT',
    action = keybinds.new_workspace,
  },
  {
    key = '{',
    mods = 'CTRL|SHIFT',
    action = act.MoveTabRelative(-1),
  },
  {
    key = '}',
    mods = 'CTRL|SHIFT',
    action = act.MoveTabRelative(1),
  },
  {
    key = 't',
    mods = 'CTRL|SHIFT',
    action = keybinds.spawn_next_tab,
  },
  {
    key = 'Q',
    mods = 'CTRL|SHIFT',
    action = act.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
    },
  },
  {
    key = 's',
    mods = 'CTRL|SHIFT',
    action = act { EmitEvent = 'save_session' },
  },
  {
    key = 'r',
    mods = 'CTRL|SHIFT',
    action = act { EmitEvent = 'restore_session' },
  },
  {
    key = 'v',
    mods = 'CTRL|SHIFT',
    action = keybinds.vim_scrollback,
  },
  {
    key = '!',
    mods = 'CTRL|SHIFT',
    action = act.SwitchToWorkspace {
      name = 'default',
      spawn = {
        args = { 'nu' },
      },
    },
  },
  {
    key = ')',
    mods = 'CTRL|SHIFT',
    action = act.SwitchToWorkspace {
      name = 'arch',
      spawn = {
        domain = {
          DomainName = 'WSL:Arch',
        },
      },
    },
  },
}

-- Switch to tab on Alt+<n>
for i = 0, 8 do
  table.insert(config.keys, {
    key = tostring(i + 1),
    mods = 'ALT',
    action = act.ActivateTab(i),
  })
end

-- Rest of the workspaces will be just numbers
for i, key in ipairs { '@', '#', '$', '%', '^', '&', '*' } do
  table.insert(config.keys, {
    key = key,
    mods = 'CTRL|SHIFT',
    action = act.SwitchToWorkspace {
      name = tostring(i + 1),
    },
  })
end

wezterm.on('gui-startup', function(_)
  local _, pane, window = wezterm.mux.spawn_window {}
  window:gui_window():perform_action(wezterm.action.ToggleFullScreen, pane)
end)

return config
