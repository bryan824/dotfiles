#!/usr/bin/env zsh
# zmodload zsh/zprof  # uncomment to profile startup time

# Startup fragments load in lexical order; the number prefix is the contract.
# Gaps of 10 so a new fragment inserts without renumbering.
#
#   00 environment/PATH   30 mise            60 aliases
#   10 options/history    40 tool hooks      70 keybindings
#   20 zim (compinit)     50 functions       80 host-specific
#
# 20 before 30 matters: zim owns compinit, and mise runs its own when compdef
# is still undefined.
#
# Glob qualifiers: N = null-glob (no error if empty), - = resolve symlinks
# before testing, . = regular files only.
#
# The `-` is load-bearing. mise deploys these fragments as symlinks, and zsh
# does not consider a symlink a regular file, so a bare (N.) silently matches
# nothing and the entire shell config stops loading.
for file ($ZDOTDIR/[0-9]*.zsh(N-.)) source $file
