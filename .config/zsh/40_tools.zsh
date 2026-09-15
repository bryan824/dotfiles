# Tool completions / shell hooks — deferred for startup performance.
#
# Runs after 30_mise.zsh so the $+commands checks see mise-managed tools without
# relying on shims, and after 20_zim.zsh for _evalcache and zsh-defer.
# starship is intentionally not deferred: it must render before the first prompt.
#
# Only tools whose integration must be *sourced* belong here. A tool that merely
# prints a #compdef script is handled by `mise run shell:completions`, which
# writes it into $ZDOTDIR/completions for zsh to autoload on first use — no
# startup cost at all.
(($+commands[kopia]   )) && zsh-defer _evalcache kopia --completion-script-zsh
(($+commands[atuin]   )) && zsh-defer _evalcache atuin init zsh
(($+commands[zoxide]  )) && zsh-defer _evalcache zoxide init zsh
(($+commands[starship])) && _evalcache starship init zsh
(($+commands[tv]      )) && zsh-defer _evalcache tv init zsh
(($+commands[k9s]     )) && zsh-defer _evalcache k9s completion zsh

# fzf — completion half only.
#
# `fzf --zsh` emits two sections. key-bindings.zsh grabs ^R, which atuin owns,
# plus ^T and Alt-C; completion.zsh is the half that is actually wanted. It
# records whatever ^I was bound to when it loads and falls back to that binding
# whenever the ** trigger is absent, so ordinary Tab completion is unchanged.
#
# _evalcache hashes a function's definition along with its name, so editing the
# filter below invalidates the cache by itself.
if (( $+commands[fzf] )); then
  _fzf_completion_init() {
    fzf --zsh | sed -n '/^### completion.zsh ###$/,/^### end: completion.zsh ###$/p'
  }
  zsh-defer _evalcache _fzf_completion_init
fi

# Google Cloud SDK — installed under XDG_DATA_HOME rather than $HOME.
if [[ -d "$XDG_DATA_HOME/google-cloud-sdk" ]]; then
  path=("$XDG_DATA_HOME/google-cloud-sdk/bin" $path)
  zsh-defer source "$XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc"
fi
