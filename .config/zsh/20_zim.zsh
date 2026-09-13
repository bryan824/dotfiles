# zim — plugin manager, and the single owner of compinit.
#
# Must run before any fragment that wants completions: `mise activate` (30) runs
# its own `compinit -i` when compdef is undefined, which would pre-empt zim's
# completion module — double compinit, and zsh-completions' fpath missed on the
# first pass.

# Personal completion functions must be on fpath before zim's compinit runs.
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
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
}
zsh-defer _load_zsh_history_substring_search
zsh-defer source ${ZIM_HOME}/modules/zsh-autosuggestions/zsh-autosuggestions.zsh
zsh-defer source ${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
