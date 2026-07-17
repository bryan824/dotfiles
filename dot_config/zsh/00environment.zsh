# Environment and base PATH

# XDG base directories are set in ~/.zshenv so every zsh invocation sees them
# before ZDOTDIR is resolved.

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
export OMO_SEND_ANONYMOUS_TELEMETRY=0
export INSTALLER_NO_MODIFY_PATH=1 # https://docs.astral.sh/uv/configuration/environment/#installer_no_modify_path
export CLOUDSDK_PYTHON="$XDG_DATA_HOME/uv/python/cpython-3.14-macos-aarch64-none/bin/python3.14"

# zim
export ZIM_CONFIG_FILE="$ZDOTDIR/.zimrc"
export ZIM_HOME="$ZDOTDIR/.zim"

# Keep PATH/fpath deterministic when multiple startup files add the same entry.
typeset -gU path fpath

# Base PATH — static/user bin dirs only. mise activation in 20mise.zsh prepends
# managed tool install dirs for interactive shells, so we do not add shims here.
path=(
  /Applications/WezTerm.app/Contents/MacOS
  /Applications/kitty.app/Contents/MacOS
  "$PNPM_HOME"
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "$XDG_DATA_HOME/nvim/mason/bin"
  $path
)

# OrbStack (macOS) — keep this managed here instead of letting OrbStack create
# an unmanaged ~/.config/zsh/.zprofile when ZDOTDIR is set.
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"

# Docker (colima) — only set when the colima socket is actually present,
# otherwise this breaks Docker Desktop and any other Docker daemon.
[[ -S "${HOME}/.config/colima/default/docker.sock" ]] && \
  export DOCKER_HOST="unix://${HOME}/.config/colima/default/docker.sock"

# Pager
if (( $+commands[less] )); then
  export PAGER="less"
  export LESS="RiMQXL"
  export LESSCHARSET="utf-8"
fi
