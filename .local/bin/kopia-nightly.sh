#!/bin/zsh
# Nightly kopia backup. Run by the dev.mise.kopia-backup LaunchAgent, which is
# declared in .config/mise/config.{bryan,irene}.toml.
#
# launchd gives this no interactive shell and no activated mise, so mise is
# activated here by absolute path. It also gives no pipefail, which is why this
# is a script and not a `zsh -c` one-liner: without it a failing `kopia
# snapshot create` is masked by the exit status of the `tr` on the other side
# of the pipe, and the run reports success.
set -euo pipefail
eval "$("$HOME/.local/bin/mise" activate zsh)"

# The only thing standing between a failed run and nobody noticing. launchd
# writes the detail to the agent's StandardErrorPath.
trap 'osascript -e "display notification \"Nightly run failed - see ~/Library/Logs/kopia-launchagent.err\" with title \"Kopia backup\"" 2>/dev/null || true' ERR

# stdbuf/tr turn kopia's progress carriage returns into ordinary log lines.
kopia snapshot create "$HOME" --progress-update-interval 1m 2>&1 |
    stdbuf -oL -eL tr '\r' '\n'

# Index-vs-storage check: finds pack blobs the index references but storage
# does not have, i.e. an rclone/Drive PutBlob that acked and never landed.
# Listing only, no download. That failure is otherwise invisible until the next
# full maintenance, which then fails on every run (the 2026-07-14..07-27
# outage). Slow against Drive - the blob listing is the whole cost.
kopia content verify
