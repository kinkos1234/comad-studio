#!/usr/bin/env bash
# doctor.sh — diagnose dependencies for comad-studio's 5 skills.
#
# Exits 0 on full readiness, 1 if any required dependency missing.

set -uo pipefail

ok() { printf '  \033[1;32m✓\033[0m %s\n' "$*"; }
miss() { printf '  \033[1;31m✗\033[0m %s\n' "$*"; }
hint() { printf '    \033[1;33m→\033[0m %s\n' "$*"; }

missing=0

check_cmd() {
  local cmd="$1" install_hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    local ver="$($cmd --version 2>&1 | head -1 || echo unknown)"
    ok "$cmd  ($ver)"
    return 0
  else
    miss "$cmd  not found"
    hint "$install_hint"
    missing=$((missing + 1))
    return 1
  fi
}

echo "comad-studio dependency check"
echo "──────────────────────────────"

echo
echo "[Codex CLI]  needed by: comad-image, comad-pptx"
check_cmd codex "npm i -g @openai/codex   (or follow OpenAI docs)"

echo
echo "[Node.js]    needed by: comad-motion, comad-pptx, comad-app-prototype"
check_cmd node "brew install node   (or volta/nvm/asdf)"

echo
echo "[ffmpeg]     needed by: comad-motion"
check_cmd ffmpeg "brew install ffmpeg"

echo
echo "[Python 3]   needed by: (general — many scripts use python3)"
check_cmd python3 "brew install python   (macOS comes with python3 by default)"

echo
echo "[Playwright] needed by: comad-motion, comad-infographic, comad-app-prototype"
if command -v node >/dev/null 2>&1 && [ -d "$HOME/.cache/ms-playwright" ]; then
  ok "playwright browsers detected at \$HOME/.cache/ms-playwright"
else
  miss "playwright browsers not installed"
  hint "npx playwright install chromium"
  missing=$((missing + 1))
fi

echo
echo "──────────────────────────────"
if [ $missing -eq 0 ]; then
  printf '\033[1;32m✅ all dependencies present\033[0m — 5 skills ready to use.\n'
  exit 0
else
  printf '\033[1;31m⚠️  %d dependency gap(s)\033[0m — install above before triggering skills.\n' "$missing"
  echo
  echo "Note: skills degrade gracefully — comad-image/pptx work without ffmpeg, etc."
  echo "Each skill checks its own deps at trigger time."
  exit 1
fi
