#!/usr/bin/env bash
# slide-imagen.sh — 단일 슬라이드 spec (JSON) + prompt → Codex /imagen → PNG
#
# Usage:
#   slide-imagen.sh <prompt.txt> <output.png>
#
# Prompt file 는 완성된 /imagen 프롬프트. references/imagen-prompts.md 의
# 템플릿 + vars 치환으로 생성한다. 이 스크립트는 단순 래퍼.
#
# 실제 본체는 comad-image/scripts/imagen.sh 를 재사용 (DRY).

set -euo pipefail

PROMPT_FILE="${1:-}"
TARGET="${2:-}"

[[ -n "$PROMPT_FILE" && -n "$TARGET" ]] || {
  echo "Usage: $0 <prompt.txt> <output.png>" >&2
  exit 2
}

IMAGEN_WRAPPER="$HOME/.claude/skills/comad-image/scripts/imagen.sh"
[[ -x "$IMAGEN_WRAPPER" ]] || {
  echo "comad-image skill not found at $IMAGEN_WRAPPER" >&2
  exit 3
}

echo "🎨 slide-imagen: $TARGET" >&2
bash "$IMAGEN_WRAPPER" "$PROMPT_FILE" "$TARGET"
