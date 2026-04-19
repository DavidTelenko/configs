# cspell: disable
use './dirs.nu' *

const core = [$modules, core.nu] | path join
const pc = [$modules, pc.nu] | path join

use $core *
use $pc

let platform_dirs = ($nu.os-info.family | if $in == "windows" {{
  data: $env.LOCALAPPDATA
}} else {{
  data: ([$nu.home-dir, '.local', 'share'] | path join)
}})

let dirs = $platform_dirs
| insert videos {
  try { $env.VIDEOSDIR } catch { [$nu.home-dir, Videos] | path join}
}

def grid-ls [] {
  ls | sort-by type name -i | grid -c
}

def timer [
  time: duration
] {
  sleep $time;
  pc notify $"your ($time) timer is up";
}

# weird shenanigan but aliasing 'scoop search' directly to 'scoop-search' makes
# it search the word 'search')
def __scoop_search [param: string] {
  scoop-search $param
}

def __scoop_remove [package: string] {
  scoop uninstall $package
  scoop clean $package
}

def __scoop_renew [package: string] {
  scoop update $package
  scoop cleanup $package
}

def auto-commit [] {
  git add .
  git commit -m $'(date now)'
  git push
}

def search-kill [processName: string] {
  let toKill = ps | where name =~ ("(?i)" + $processName)

  $toKill | is-empty | if $in {
    print $"'($processName)' not found"
    return 1
  }

  print $toKill

  print "Are you sure you want to kill all of this?"

  ['yes', 'no'] | input list | if $in == 'yes' {
    $toKill | each {
      try {
        kill -f $in.pid
      }
    }
    return 0
  }

  return 1
}

def translate [word: string] {
  [$nu.home-dir, Documents, Utility, Dictionaries, eng-rus.txt]
  | path join
  | open $in
  | rg $word
}

def open_nvim [what: list<string>] {
  $what | path join | do {
    cd $in
    nvim $in
  }
}

def search-url [...query: string] {
  try {
    start $"($env.PREFERRED_SEARCH_ENGINE)?q=($query | str join ' ')"
  } catch {
    start $"https://duckduckgo.com/?q=($query | str join ' ')"
  }
}

def record-screen [
  monitor: number = 0
] {
  let captures_dir = [$dirs.videos, Captures] | path join

  mkdir $captures_dir # create if not exist

  let filepath = [
    $captures_dir,
    $"Capture_(date now | format date '%Y-%m-%d_%H-%M-%S').mp4"
  ] | path join

  # TODO: figure out the best usability parametrization of these two

  const rate_control = 20
  const preset = "p7"

  # TODO: add av1 codec support, or rewrite the whole thing using it

  (ffmpeg
    -framerate 60
    -offset_x ($monitor * 1920) # this selects offset to second monitor
    -video_size 1920x1080       # resolution {width}x{height}
    -f gdigrab                  # video grabber
    -i desktop                  # input device
    -c:v h264_nvenc             # codec (nvidia nvenc)
    -preset:v $preset           # preset (p1-p7 lower is ++speed --quality/size)
    -profile:v high             # limits the output to a specific H.264 profile
    -tune:v hq                  # tune preset
    -pix_fmt yuv420p            # pixel format (for dumb players)
    -rc:v vbr                   # constant quality vbr mode
    -cq:v $rate_control         # rate control (0-51 lower is ++quality --size)
    -bf:v 2                     # b-frames
    -b:v 0                      # bitrate (reset)
    $filepath
  )
}

def wiztree-pic [destination?: path] {
  wiztree $"($destination | default (pwd))"
}

def clean-dir [dir: path, --older: duration = 1wk] {
  let toDelete = $dir | ls $in | where modified < ((date now) - $older)

  $toDelete | is-empty | if $in {
    print $"(ansi green)'($dir)' (ansi reset)does not have files older then ($older)"
    return
  }

  print $toDelete
  print "Are you sure you want to delete all of this?"

  ['yes', 'no'] | input list | if $in == 'yes' {
    $toDelete | each { rm -rf $in.name }
  }
}

def clean-shada [--older: duration = 1wk] {
  clean-dir ([$dirs.data, nvim-data, shada] | path join) --older $older
}

def clean-pwd [--older: duration = 1wk] { clean-dir $"(pwd)" --older $older }
def clean-tmp [--older: duration = 1day] { clean-dir $nu.temp-path --older $older }

def restart [processName: string] {
  search-kill $processName | if $in == 0 {
    ^$"($processName)"
  }
}

def imgcat [] {
  if (is-wezterm) {
    $in | wezterm imgcat
    return
  }

  if (is-kitty) {
    $in | kitten icat
    return
  }

  $in | ^imgcat
}

def ll [] {
  if (is-windows) {
    ^exa -la --icons=auto
  } else {
    ^eza -la --icons=auto
  }
}

def "from gif"  [] { imgcat }
def "from jpeg" [] { imgcat }
def "from jpg"  [] { imgcat }
def "from png"  [] { imgcat }
def "from webp" [] { imgcat }
def "from mp3"  [] { $in | ffplay -autoexit -nodisp - }
def "from flac" [] { $in | ffplay -autoexit -nodisp - }
def "from wav"  [] { $in | ffplay -autoexit -nodisp - }
def "from mkv"  [] { $in | ffplay -autoexit - }
def "from avi"  [] { $in | ffplay -autoexit - }

alias todo = open_nvim [$nu.home-dir, Documents, Markdowned, Todo]
alias mark = open_nvim [$nu.home-dir, Documents, Markdowned]

alias cal = cal --week-start mo
alias ffmpeg = ffmpeg -hide_banner

alias pcs = pc sleep
alias pcr = pc reboot
alias pcn = pc snooze
alias pcsr = pc soft-reboot

alias enva = pc env add
alias envr = pc env remove

alias patha = pc path add
alias pathr = pc path remove
alias pathls = pc path list

alias v = nvim .
alias c = clear

alias lsg = grid-ls
alias sk = search-kill
# alias mv = ^mv
alias cp = cp -p
# disk picture
alias dp = wiztree-pic
# record screen
alias rs = record-screen
alias lg = lazygit
alias vi = nvim
alias dnf = sudo dnf
alias apt = sudo apt
alias ':q' = exit

alias "scoop search" = __scoop_search
alias "scoop remove" = __scoop_remove
alias "scoop renew" = __scoop_renew
alias "scoop i" = scoop install
alias "scoop u" = scoop uninstall
alias "scoop ls" = scoop list

alias conf = nvim $configDir
alias jmplst = nvim $env.JUMP_LIST
alias clear = echo "please stop obsessive clearing all the time!"
