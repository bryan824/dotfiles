export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"


# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING=UTF-8
# Disable unnecessary, temporary files
export PYTHONDONTWRITEBYTECODE=1
# Prefer US English and use UTF-8.
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/ripgreprc"
export SEABORN_DATA="${XDG_CONFIG_HOME}/seaborn-data"
export ZSH_EVALCACHE_DIR="$ZDOTDIR/zsh-evalcache"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export DO_NOT_TRACK=1


# zim set up
# zstyle ':zim:zmodule' use 'degit'
export ZIM_CONFIG_FILE="$ZDOTDIR/.zimrc"
export ZIM_HOME="$ZDOTDIR/.zim"

# https://docs.astral.sh/uv/configuration/environment/#installer_no_modify_path
export INSTALLER_NO_MODIFY_PATH=1
