# Tool completions / shell hooks — deferred for startup performance.
#
# Runs after 30_mise.zsh so the $+commands checks see mise-managed tools without
# relying on shims, and after 20_zim.zsh for _evalcache and zsh-defer.
# starship is intentionally not deferred: it must render before the first prompt.
(($+commands[kopia]   )) && zsh-defer _evalcache kopia --completion-script-zsh
(($+commands[atuin]   )) && zsh-defer _evalcache atuin init zsh
(($+commands[zoxide]  )) && zsh-defer _evalcache zoxide init zsh
(($+commands[starship])) && _evalcache starship init zsh
(($+commands[tv]      )) && zsh-defer _evalcache tv init zsh
(($+commands[k9s]     )) && zsh-defer _evalcache k9s completion zsh

# Google Cloud SDK — installed under XDG_DATA_HOME rather than $HOME.
if [[ -d "$XDG_DATA_HOME/google-cloud-sdk" ]]; then
  path=("$XDG_DATA_HOME/google-cloud-sdk/bin" $path)
  zsh-defer source "$XDG_DATA_HOME/google-cloud-sdk/completion.zsh.inc"
fi
