# ---------------------------------------------------------------------------
# Colored log helpers — write to stderr so they never pollute pipelines
# ---------------------------------------------------------------------------
function print::warning() { print -Pru2 -- "%F{3}[WARNING]%f: $*"; }
function print::error()   { print -Pru2 -- "%F{1}%B[ERROR]%f%b: $*"; }
function print::debug()   { print -Pru2 -- "%F{4}[DEBUG]%f: $*"; }
function print::info()    { print -Pru2 -- "%F{5}[INFO]%f: $*"; }
function print::notice()  { print -Pru2 -- "%F{13}[NOTICE]%f: $*"; }
function print::success() { print -Pru2 -- "%F{2}%B[SUCCESS]%f%b: $*"; }

# ---------------------------------------------------------------------------
# Completion introspection
# ---------------------------------------------------------------------------

# Show the file that provides completions for a command
whichcomp() {
  for 1; do
    ( print -raC 2 -- $^fpath/${_comps[$1]:?unknown command}(NP*$1*) )
  done
}

# Show fpath entry and whence info for a completion function
from-where() {
  print -l -- $^fpath/$_comps[$1](N)
  whence -v $_comps[$1]
}

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

# Print all 16 ANSI colors with bold/underline/invert combinations
printcolors() {
  print -l -- '' \
    $'\033[0K\033[1mBold\033[0m \033[7mInvert\033[0m \033[4mUnderline\033[0m' \
    $'\033[0K\033[1m\033[7m\033[4mBold & Invert & Underline\033[0m' \
    ''
  echo -e '\033[0K\033[31m Red \033[32m Green \033[33m Yellow \033[34m Blue \033[35m Magenta \033[36m Cyan \033[0m'
  echo -e '\033[0K\033[1m\033[4m\033[31m Red \033[32m Green \033[33m Yellow \033[34m Blue \033[35m Magenta \033[36m Cyan \033[0m'
  echo
  echo -e '\033[0K\033[41m Red \033[42m Green \033[43m Yellow \033[44m Blue \033[45m Magenta \033[46m Cyan \033[0m'
  echo -e '\033[0K\033[1m\033[4m\033[41m Red \033[42m Green \033[43m Yellow \033[44m Blue \033[45m Magenta \033[46m Cyan \033[0m'
  echo
  echo -e '\033[0K\033[30m\033[41m Red \033[42m Green \033[43m Yellow \033[44m Blue \033[45m Magenta \033[46m Cyan \033[0m'
  echo -e '\033[0K\033[30m\033[1m\033[4m\033[41m Red \033[42m Green \033[43m Yellow \033[44m Blue \033[45m Magenta \033[46m Cyan \033[0m'
}

# Back up a file in-place:  bak somefile  →  somefile.orig
bak() { cp $1{,.orig}; }

# Copy the current directory path to the clipboard (macOS only)
if [[ $OSTYPE == darwin* ]]; then
  pbcopydir() { pwd | tr -d '\r\n' | pbcopy; }
fi

# Send a macOS notification banner (macOS only)
if [[ $OSTYPE == darwin* ]]; then
  osxnotify() { osascript -e 'display notification "'"$*"'"'; }
fi

# Delete a large directory quickly via rsync empty-dir trick
# (avoids the per-inode overhead of plain rm -rf on huge trees)
rmf() {
  (( $+commands[rsync] )) || { print::error 'rmf requires rsync'; return 1; }
  local empty=$(mktemp -d)
  rsync -a --delete "$empty/" "$1"
  rm -rf "$empty" "$1"
}

# Diff two directories, filtering macOS and Windows noise
diffd() { diff -qr "$1" "$2" | grep -v -e 'DS_STORE' -e 'Thumbs' | sort; }
