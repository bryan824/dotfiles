# mise shell integration
#
# Run after base PATH is set, and before aliases/command-availability checks.
# Use full PATH activation for interactive shells; shims are reserved for
# non-interactive/GUI contexts that cannot run shell hooks.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# A mac whose miserc.toml lacks the desktop layer loads the base tools only and
# skips every GUI dotfile -- silently, since nothing errors. $(<file) reads
# without forking, so this costs nothing on the machines where it is right.
() {
  local rc=$XDG_CONFIG_HOME/mise/miserc.toml
  [[ $OSTYPE != darwin* ]] || [[ -r $rc && $(<$rc) == *'"desktop"'* ]] ||
    print -u2 -- "mise: $rc does not list the \"desktop\" layer; see ~/.dotfiles/README.md"
}

# Editor — after mise activation so mise-managed Neovim is visible.
# VISUAL too: git, crontab and sudoedit prefer it and fall back to EDITOR only
# when it is unset, so leaving it empty hands those tools vi on some systems.
(( $+commands[nvim] )) && export EDITOR="nvim" VISUAL="nvim"
