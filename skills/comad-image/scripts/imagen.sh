#!/usr/bin/env bash
# /pumasi:image — Codex /imagen 호출 래퍼
# Usage: imagen.sh <prompt_file> <target_image_path>

set -euo pipefail

PROMPT_FILE="${1:-}"
TARGET_PATH="${2:-}"

if [[ -z "$PROMPT_FILE" || -z "$TARGET_PATH" ]]; then
  echo "Usage: $0 <prompt_file> <target_image_path>" >&2
  exit 2
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "ERROR: prompt file not found: $PROMPT_FILE" >&2
  exit 2
fi

# codex 설치 확인
if ! command -v codex >/dev/null 2>&1; then
  echo "ERROR: codex CLI not found. Install: npm install -g @openai/codex" >&2
  exit 3
fi

# 1) feature flag 확인 + 자동 활성화
FLAG_STATE=$(codex features list 2>&1 | awk '/^image_generation/ {print $NF}' | head -n1)
if [[ "$FLAG_STATE" != "true" ]]; then
  echo "[imagen.sh] enabling image_generation feature flag..."
  codex features enable image_generation >/dev/null 2>&1
fi

# 2) 저장 디렉토리 준비
TARGET_DIR=$(dirname "$TARGET_PATH")
mkdir -p "$TARGET_DIR"

# 3) 프롬프트 본문 + 후처리 금지 가드 조합
PROMPT_BODY=$(cat "$PROMPT_FILE")

CODEX_PROMPT=$(cat <<EOF
/imagen ${PROMPT_BODY}

저장 규칙 (반드시 준수):
- 생성된 원본 이미지 파일을 ${TARGET_PATH} 에 **그대로 복사**만 할 것
- sips, ImageMagick, Pillow, 그 외 어떤 후처리(크롭/리사이즈/재인코딩/알파 조작)도 **절대 금지**
- 생성 원본(~/.codex/generated_images/... 하위)과 저장 파일의 sha1 해시가 **반드시 일치**해야 함
- 복사 후 shasum 으로 두 파일 해시 확인하여 출력할 것
EOF
)

# 4) codex exec 호출
LOG_FILE=$(mktemp -t imagen-log.XXXXXX)
echo "[imagen.sh] calling codex /imagen — target: $TARGET_PATH"
echo "[imagen.sh] log: $LOG_FILE"

if ! codex exec \
    --skip-git-repo-check \
    --dangerously-bypass-approvals-and-sandbox \
    "$CODEX_PROMPT" > "$LOG_FILE" 2>&1; then
  echo "ERROR: codex exec failed. See log: $LOG_FILE" >&2
  tail -50 "$LOG_FILE" >&2
  exit 4
fi

# 5) 결과 파일 존재 확인
if [[ ! -f "$TARGET_PATH" ]]; then
  echo "ERROR: target file not created: $TARGET_PATH" >&2
  echo "--- codex log tail ---" >&2
  tail -50 "$LOG_FILE" >&2
  exit 5
fi

# 6) 파일 정보 출력
SIZE=$(wc -c < "$TARGET_PATH" | tr -d ' ')
FILE_INFO=$(file "$TARGET_PATH")
SHA1=$(shasum "$TARGET_PATH" | awk '{print $1}')

cat <<EOF
[imagen.sh] SUCCESS
  path:  $TARGET_PATH
  size:  $SIZE bytes
  info:  $FILE_INFO
  sha1:  $SHA1
  log:   $LOG_FILE
EOF
