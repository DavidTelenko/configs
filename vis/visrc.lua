require 'vis'

local plug = (function()
  if not pcall(require, 'plugins/vis-plug') then
    os.execute(
      'git clone --quiet https://github.com/erf/vis-plug '
        .. (os.getenv 'XDG_CONFIG_HOME' or os.getenv 'HOME' .. '/.config')
        .. '/vis/plugins/vis-plug'
    )
  end
  return require 'plugins/vis-plug'
end)()

vis.events.subscribe(vis.events.INIT, function()
  -- vis:command 'set theme caelus'
end)

plug.init({
  { 'https://gitlab.com/muhq/vis-lspc' },
  { 'https://git.sr.ht/~mcepl/vis-fzf-open' },
  { 'https://codeberg.org/luxanna/vis-autoclose' },
  -- { 'https://github.com/vktec/vis-editorconfig' },
}, true)
