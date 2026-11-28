local wezterm = require 'wezterm' --[[@as Wezterm]]
local tabline =
  require('wezterm').plugin.require 'https://github.com/michaelbrusegard/tabline.wez'
local nf = wezterm.nerdfonts
local git_helpers = require 'helpers.git'

local function with_icon(value, icon)
  if not value then
    return ''
  end
  return icon .. ' ' .. value .. ' '
end

tabline.setup {
  options = {
    icons_enabled = true,
    tabs_enabled = true,
    theme_overrides = require 'theme.tabline',
    section_separators = {
      right = nf.ple_left_half_circle_thick,
      left = nf.ple_right_half_circle_thick,
    },
    component_separators = {
      right = '',
      left = '',
    },
    tab_separators = {
      right = nf.ple_left_half_circle_thick,
      left = nf.ple_right_half_circle_thick,
    },
  },
  sections = {
    tabline_a = {
      {
        'mode',
        fmt = function(str)
          return str:sub(1, 1)
        end,
      },
    },
    tabline_b = { 'workspace' },
    tabline_c = { ' ' },
    tab_active = {
      { 'index', padding = 1 },
      { 'cwd', padding = { right = 1 } },
    },
    tab_inactive = {
      { 'index', padding = 1 },
    },
    tabline_x = {
      function(window)
        local branch = with_icon(git_helpers.branch(window), nf.oct_git_branch)

        return wezterm.format {
          { Attribute = { Intensity = 'Bold' } },
          {
            Text = branch,
          },
        }
      end,
    },
    tabline_y = {
      { 'datetime', style = '%H:%M - %a %d' },
      -- 'battery',
    },
    tabline_z = { 'domain' },
  },
  extensions = {},
}
