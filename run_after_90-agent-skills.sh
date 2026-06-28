#!/bin/bash
set -euo pipefail

if ! command -v bunx >/dev/null 2>&1; then
  echo "agent skills: bunx is required to install remote skills" >&2
  exit 127
fi

export DISABLE_TELEMETRY=1
export DO_NOT_TRACK=1

install_skills() {
  local repo="$1"

  bunx --yes skills@latest add "$repo" \
    --global \
    --copy \
    --full-depth \
    --skill '*' \
    --agent codex \
    --agent claude-code \
    --yes
}

# Codex creates the shared ~/.agents/skills directory. Pi loads that directory
# natively, and OpenCode uses the same skills CLI target, so only Codex and
# Claude Code need to be requested here.
install_skills bryan824/kirin-pi
install_skills kepano/obsidian-skills

# Older versions of this dotfiles setup installed Pi-specific duplicates.
rm -rf "$HOME/.pi/agent/skills"
