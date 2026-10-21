use core.nu *

export def main [
  text: string,   # text to speak
  voice?: string, # path to voice model (defaults to $env.PIPER_VOICE)
] {(
  echo $text | piper
    --model ($voice | default $env.PIPER_VOICE)
    --output-raw
  | ffplay
    -autoexit
    -nodisp
    -loglevel quiet
    -f s16le
    -ar 22050
    -
)}

export def save [
  text: string,    # text to speak
  outPath: string, # path to save audio file to
  voice?: string,  # path to voice model (defaults to $env.PIPER_VOICE)
] {(
  echo $text | piper
    --model ($voice | default $env.PIPER_VOICE)
    --quiet
    --output-file $outPath
)}
