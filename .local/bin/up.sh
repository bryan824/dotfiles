#!/bin/zsh
# Every self-update/upgrade in one shot. Two callers: the `up` function in
# .config/zsh/50_functions.zsh, and the dev.mise.self-update LaunchAgent
# declared in .config/mise/config.bryan.toml.
#
# Steps whose tool is missing are skipped. Tools installed *by* mise (bun,
# rustup, node…) are deliberately absent -- `mise upgrade` already owns them.
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

# mise, by absolute path since nothing has activated it.
eval "$("$HOME/.local/bin/mise" activate zsh)"

# zim, because `zimfw` is a shell function rather than a binary. Sourcing it
# again under the interactive caller is harmless -- this is a subprocess.
: ${ZIM_HOME:=${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}/.zim}
[[ -e ${ZIM_HOME}/init.zsh ]] && source ${ZIM_HOME}/init.zsh

# gcloud, which is not a mise tool and lives off PATH. Mirrors 40_tools.zsh.
gcloud_bin=${XDG_DATA_HOME:-${HOME}/.local/share}/google-cloud-sdk/bin
[[ -d $gcloud_bin ]] && path=($gcloud_bin $path)

local -a steps=(
  'mise self-update -y'
  'mise upgrade'
  'zimfw upgrade'
  'zimfw update'
  'uv tool upgrade --all'
  'gcloud components update --quiet'
)
local step tool
for step in $steps; do
  tool=${step%% *}
  (( $+commands[$tool] || $+functions[$tool] )) || continue
  print -Pru2 -- "%F{5}[INFO]%f: $step"
  ${(z)step} || print -Pru2 -- "%F{1}%B[ERROR]%f%b: $step failed"
done
