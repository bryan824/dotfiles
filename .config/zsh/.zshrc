#!/usr/bin/env zsh
# zmodload zsh/zprof  # uncomment to profile startup time

# Startup fragments load in lexical order; the number prefix is the contract.
# Gaps of 10 so a new fragment inserts without renumbering.
#
#   00 environment/PATH   25 completion      60 aliases
#   10 options/history    30 mise            70 keybindings
#   20 zim (plugins)      40 tool hooks      80 host-specific
#                         50 functions
#
# 25 before 30 matters: 25 owns compinit, and mise runs its own when compdef
# is still undefined. 20 before 25 matters too — zsh-completions must be on
# fpath before compinit runs.
#
# Glob qualifiers: N = null-glob (no error if empty), - = resolve symlinks
# before testing, . = regular files only.
#
# The `-` is load-bearing. mise deploys these fragments as symlinks, and zsh
# does not consider a symlink a regular file, so a bare (N.) silently matches
# nothing and the entire shell config stops loading.
for file ($ZDOTDIR/[0-9]*.zsh(N-.)) source $file
