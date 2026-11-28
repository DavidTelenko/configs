local colors = require 'theme.palette'

return {
  normal_mode = {
    a = { bg = colors.light2, fg = colors.dark0 },
    b = { bg = colors.dark0, fg = colors.light2 },
    c = { bg = colors.black, fg = colors.light3 },
  },
  copy_mode = {
    a = { bg = colors.bright_yellow, fg = colors.dark0 },
    b = { bg = colors.dark0, fg = colors.light2 },
    c = { bg = colors.black, fg = colors.light1 },
  },
  search_mode = {
    a = { bg = colors.bright_green, fg = colors.dark0 },
    b = { bg = colors.dark0, fg = colors.light2 },
    c = { bg = colors.black, fg = colors.light1 },
  },
  tab = {
    active = { bg = colors.dark0, fg = colors.light2 },
    inactive = { bg = colors.black, fg = colors.light3 },
    inactive_hover = { bg = colors.dark4, fg = colors.dark0 },
  },
}
