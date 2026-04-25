#!/usr/bin/env bash
# install.sh — copy this repo's 5 visual/media skills into ~/.claude/skills/.
#
# Safe to re-run: overwrites existing files (takes a .bak-<ts> before each).
# Does NOT touch ~/.claude/settings.json (skills auto-discover via filesystem).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${CLAUDE_HOME:-$HOME/.claude}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }

SKILLS=(comad-image comad-motion comad-pptx comad-infographic comad-app-prototype)

mkdir -p "$TARGET/skills"

copy_dir() {
  local src="$1" dst="$2"
  if [ -d "$dst" ]; then
    local backup="${dst}.bak-${TS}"
    log "backed up existing → $backup"
    mv "$dst" "$backup"
  fi
  cp -R "$src" "$dst"
  log "installed $(basename "$dst") ($(find "$dst" -type f | wc -l | tr -d ' ') files)"
}

for s in "${SKILLS[@]}"; do
  if [ ! -d "$REPO_ROOT/skills/$s" ]; then
    warn "missing source: $REPO_ROOT/skills/$s — skipping"
    continue
  fi
  copy_dir "$REPO_ROOT/skills/$s" "$TARGET/skills/$s"
done

# Make scripts executable (best-effort; some skills don't have shell scripts)
find "$TARGET/skills" \( -name "*.sh" -o -name "*.cmd" \) \( \
       -path "*/comad-image/*" -o -path "*/comad-motion/*" -o \
       -path "*/comad-pptx/*" -o -path "*/comad-infographic/*" -o \
       -path "*/comad-app-prototype/*" \) -exec chmod +x {} +

echo
log "✅ install complete. 5 visual/media skills installed."
echo
cat <<EOF
Next steps:

1. Run dependency doctor:
     ./doctor.sh

2. Trigger a skill (Claude Code session):
     "이미지 만들어줘 — 미니멀 로고"        → comad-image
     "30초 릴리스 영상 만들어"               → comad-motion
     "5장짜리 deck 만들어줘"                 → comad-pptx
     "before/after 인포그래픽"                → comad-infographic
     "iPhone 앱 프로토타입 3-screen flow"    → comad-app-prototype

3. Sister repos (optional):
     https://github.com/kinkos1234/comad-world             (8 core modules)
     https://github.com/kinkos1234/comad-world-extensions  (9 hooks + 5 skills)
EOF
