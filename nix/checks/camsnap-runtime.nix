{ runCommand, camsnap }:

runCommand "camsnap-runtime" {} ''
  export HOME="$TMPDIR/home"
  mkdir -p "$HOME"
  PATH= ${camsnap}/bin/camsnap doctor > "$out" 2>&1
  grep -F 'ffmpeg found in PATH' "$out"
''
