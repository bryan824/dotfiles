# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Python
export PYTHONIOENCODING=UTF-8    # UTF-8 for stdin/stdout/stderr
export PYTHONDONTWRITEBYTECODE=1 # suppress __pycache__ / .pyc files

# Tool-specific
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/ripgreprc"
export SEABORN_DATA="${XDG_CONFIG_HOME}/seaborn-data"
export ZSH_EVALCACHE_DIR="$ZDOTDIR/zsh-evalcache"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export DO_NOT_TRACK=1
export INSTALLER_NO_MODIFY_PATH=1 # https://docs.astral.sh/uv/configuration/environment/#installer_no_modify_path

# Docker (colima) — only set when the colima socket is actually present,
# otherwise this breaks Docker Desktop and any other Docker daemon.
[[ -S "${HOME}/.config/colima/default/docker.sock" ]] && \
  export DOCKER_HOST="unix://${HOME}/.config/colima/default/docker.sock"

# zim
export ZIM_CONFIG_FILE="$ZDOTDIR/.zimrc"
export ZIM_HOME="$ZDOTDIR/.zim"

# PATH — prepend in priority order so later entries act as fallbacks.
# Must come before any $+commands[...] checks below so tools in these
# directories are visible when we test for their existence.
path=(
  "$XDG_DATA_HOME/mise/shims"
  "$HOME/.cache/.bun/bin"
  /Applications/WezTerm.app/Contents/MacOS
  /Applications/kitty.app/Contents/MacOS
  "$PNPM_HOME"
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "$XDG_DATA_HOME/mise/shims"   # mise-managed tools — must precede $+commands checks
  "$XDG_DATA_HOME/nvim/mason/bin"
  $path
)

# Pager
if (( $+commands[less] )); then
  export PAGER="less"
  export LESS="RiMQXL"
  export LESSCHARSET="utf-8"
fi

# Editor
(( $+commands[nvim] )) && export EDITOR="nvim"
