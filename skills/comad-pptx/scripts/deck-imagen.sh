#!/usr/bin/env bash
# deck-imagen.sh — Full image-first PPTX build.
#
# Flow: spec.json → (for each slide, parallel) slide-imagen.sh → PNG → image2pptx.js → PPTX
#
# spec.json shape:
# {
#   "deck": { "output_dir": "outputs/2026-04-24/echo", ... },
#   "slides": [
#     { "id": "slide-1", "prompt_file": "prompts/slide-1.txt", "image": "slide-1.png" },
#     ...
#   ]
# }
#
# Usage:
#   deck-imagen.sh <spec.json> [output.pptx]

set -euo pipefail

SKILL_DIR="$HOME/.claude/skills/comad-pptx"
SPEC="${1:-}"
OUT="${2:-}"

[[ -n "$SPEC" && -f "$SPEC" ]] || { echo "Usage: $0 <spec.json> [output.pptx]" >&2; exit 2; }

GLOBAL_ROOT=$(npm root -g 2>/dev/null || echo "")
[[ -n "$GLOBAL_ROOT" ]] && export NODE_PATH="$GLOBAL_ROOT${NODE_PATH:+:$NODE_PATH}"

SPEC_DIR=$(cd "$(dirname "$SPEC")" && pwd)

if [[ -z "$OUT" ]]; then
  BASE=$(basename "$SPEC" .json)
  DATE=$(date +%Y-%m-%d)
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  mkdir -p "$ROOT/outputs/$DATE"
  OUT="$ROOT/outputs/$DATE/${BASE}.pptx"
fi

# 1. Generate all slide images in parallel (up to 4 concurrent)
echo "🎨 deck-imagen: generating slide images..." >&2

MAX_PARALLEL="${MAX_PARALLEL:-3}"

# Write slide job list: SID<TAB>PROMPT_ABS<TAB>IMG_ABS
JOBS=$(mktemp)
trap "rm -f $JOBS" EXIT
python3 - "$SPEC" "$SPEC_DIR" > "$JOBS" <<'PY'
import json, os, sys
spec_path, spec_dir = sys.argv[1], sys.argv[2]
spec = json.load(open(spec_path))
for s in spec.get('slides', []):
    sid = s.get('id', '')
    pf = s.get('prompt_file', '')
    im = s.get('image', '')
    if not sid or not pf or not im:
        continue
    pa = pf if os.path.isabs(pf) else os.path.join(spec_dir, pf)
    ia = im if os.path.isabs(im) else os.path.join(spec_dir, im)
    print(f"{sid}\t{pa}\t{ia}")
PY

# Run in parallel using xargs -P (portable)
cat "$JOBS" | while IFS=$'\t' read -r SID PA IA; do
  [[ -z "$SID" ]] && continue
  if [[ -f "$IA" ]]; then
    echo "⏭  skip (exists): $SID → $(basename "$IA")" >&2
    continue
  fi
  if [[ ! -f "$PA" ]]; then
    echo "⚠ prompt missing for $SID: $PA" >&2
    continue
  fi
  printf '%s\t%s\t%s\n' "$SID" "$PA" "$IA"
done | xargs -P "$MAX_PARALLEL" -I {} bash -c '
  IFS=$'"'"'\t'"'"' read -r SID PA IA <<< "{}"
  bash "'"$SKILL_DIR"'/scripts/slide-imagen.sh" "$PA" "$IA" 2>&1 | sed "s/^/[$SID] /"
' || true

echo "🔧 deck-imagen: assembling pptx..." >&2
node "$SKILL_DIR/engine/image2pptx.js" "$SPEC" "$OUT"
echo "✅ done: $OUT" >&2
