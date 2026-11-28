# Notes

As `ghostty` is a `GTK` application it suffers from some hardcoded input keybindings. To disable this go into `/usr/share/applications` and edit `com.mitchellh.ghostty.desktop` like this:

```diff
[Desktop Entry]
- Exec=ghostty
+ Exec=env GTK_IM_MODULE=none ghostty
```
