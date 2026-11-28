dir="$HOME/.config/rofi/themes/launchers/type-2"
theme='style-1'

hyprctl clients \
    | rg ^Window \
    | rofi -dmenu -theme ${dir}/${theme}.rasi \
    | awk '{print $2}' \
    | xargs -I{} hyprctl dispatcher focuswindow "address:0x{}"

# ## Run
# rofi \
#     -show window \
#     -theme ${dir}/${theme}.rasi
