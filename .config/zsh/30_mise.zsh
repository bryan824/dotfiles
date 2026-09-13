# mise shell integration
#
# Run after base PATH is set, and before aliases/command-availability checks.
# Use full PATH activation for interactive shells; shims are reserved for
# non-interactive/GUI contexts that cannot run shell hooks.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# Editor — after mise activation so mise-managed Neovim is visible.
(( $+commands[nvim] )) && export EDITOR="nvim"
