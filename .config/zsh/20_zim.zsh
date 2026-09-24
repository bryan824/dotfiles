# zim — plugin manager. compinit lives in 25_completion.zsh, which must run
# after this file so zsh-completions is already on fpath, and before 30_mise.zsh
# because `mise activate` runs its own `compinit -i` when compdef is undefined.

# Personal completion functions must be on fpath before compinit runs in 25.
fpath+=("$ZDOTDIR/completions")

# Download zimfw if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and regenerate init.zsh if stale.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

zstyle ':zim' disable-version-check yes
source ${ZIM_HOME}/init.zsh

# ---------------------------------------------------------------------------
# Deferred plugin loading
# ---------------------------------------------------------------------------
# zsh-defer pushes work past the first prompt, keeping startup instant.
# zsh-syntax-highlighting must be sourced last — it wraps ZLE widgets.

source ${ZIM_HOME}/modules/zsh-defer/zsh-defer.plugin.zsh

# history-substring-search bindings must be set after the plugin is loaded.
function _load_zsh_history_substring_search() {
  source ${ZIM_HOME}/modules/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  zmodload -F zsh/terminfo +p:terminfo
  if [[ -n ${terminfo[kcuu1]} && -n ${terminfo[kcud1]} ]]; then
    bindkey ${terminfo[kcuu1]} history-substring-search-up
    bindkey ${terminfo[kcud1]} history-substring-search-down
  fi
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
}
zsh-defer _load_zsh_history_substring_search
zsh-defer source ${ZIM_HOME}/modules/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
