#!/bin/zsh
# Every self-update/upgrade in one shot. Two callers: the `up` function in
# .config/zsh/50_functions.zsh, and the dev.mise.self-update LaunchAgent
# declared in .config/mise/config.{bryan,irene}.toml.
#
# Steps whose tool is missing are skipped. Tools installed *by* mise (bun,
# node…) are deliberately absent -- `mise upgrade` already owns them. rustup is
# not one of them: it lives standalone in ~/.cargo/bin, so it gets a step.
#
# No `set -e`: the point of the loop is that one failing step does not stop the
# rest. Each failure is reported and the run continues.
#
# launchd gives this no interactive shell, so everything the steps resolve
# through is set up by hand. zsh still sources ~/.zshenv here, so ZDOTDIR and
# the XDG variables are already set; the rest is not. Getting this wrong fails
# silently -- the guard below skips a step whose tool does not resolve, so a
# missed path means the update quietly stops happening rather than erroring.
set -uo pipefail

# `zimfw` is a shell function, not a binary, and this is the whole of what
# zim's generated init.zsh defines for it. Sourcing all of init.zsh would load
# every module too, for nothing.
: ${ZIM_HOME:=${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}/.zim}
[[ -e ${ZIM_HOME}/zimfw.zsh ]] && zimfw() { source ${ZIM_HOME}/zimfw.zsh "$@" }

# mise, by absolute path since nothing has activated it.
eval "$("$HOME/.local/bin/mise" activate zsh)"

# The toolchains that live off mise, mirroring 00_environment.zsh and
# 40_tools.zsh. launchd's PATH has neither. Without ~/.cargo/bin, `rustup`
# resolves only to mise's rust shim, which has no version outside a project
# that pins rust and nothing left to fall back to -- so the rustup step and the
# _cargo/_rustup completions were silently skipped on every scheduled run.
path=(${HOME}/.cargo/bin(N-/) ${XDG_DATA_HOME:-${HOME}/.local/share}/google-cloud-sdk/bin(N-/) $path)

local -a steps=(
  'mise self-update -y'
  'mise upgrade'
  'zimfw upgrade'
  'zimfw update'
  'uv tool upgrade --all'
  'rustup update'
  # pi itself is a mise npm tool, upgraded above; its extensions are not.
  'pi update --extensions'
  'gcloud components update --quiet'
  # Both caches describe the versions above. _evalcache keys on the command
  # string, not the binary, so it serves a stale init forever otherwise — this
  # held a direnv init long after direnv left the config. Expanded here, at
  # array-build time: ${(z)} below splits words without expanding them.
  "rm -rf -- ${ZDOTDIR:?}/zsh-evalcache"
  'mise run shell:completions'
)
local step tool
for step in $steps; do
  tool=${step%% *}
  (( $+commands[$tool] || $+functions[$tool] )) || continue
  print -Pru2 -- "%F{5}[INFO]%f: $step"
  ${(z)step} || print -Pru2 -- "%F{1}%B[ERROR]%f%b: $step failed"
done
