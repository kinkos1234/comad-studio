#!/usr/bin/env bash
# comad-motion · add-music.sh
#
# Mix BGM + (optional) SFX layer into an existing MP4.
# Frequency-separated dual-track per references/audio-design.md.
#
# Usage:
#   add-music.sh <video.mp4> <bgm.mp3> [sfx.wav]
#
# Behavior:
#   - BGM  : lowpass=4000 (contain to <4kHz) · vol 0.45 · fade in 0.3s / fade out 1.5s
#   - SFX  : highpass=800 (push to >800Hz) · vol 1.0 (optional — omit arg to BGM-only)
#   - amix : normalize=0 (preserve dynamics · never use normalize=1)
#   - out  : <basename>-audio.mp4 alongside input
#
# If SFX omitted: still applies BGM lowpass + fades, warns that SFX-less mix is
# half-completion per the skill's "dual-track rule".

set -euo pipefail

VIDEO="${1:-}"
BGM="${2:-}"
SFX="${3:-}"

if [[ -z "$VIDEO" || -z "$BGM" ]]; then
  echo "Usage: add-music.sh <video.mp4> <bgm.mp3> [sfx.wav]" >&2
  exit 1
fi
[[ -f "$VIDEO" ]] || { echo "Video not found: $VIDEO" >&2; exit 1; }
[[ -f "$BGM" ]]   || { echo "BGM not found: $BGM"     >&2; exit 1; }

# Get video duration (seconds, float)
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")
BASE="${VIDEO%.*}"
OUT="${BASE}-audio.mp4"

FADE_OUT_START=$(awk "BEGIN{print $DUR - 1.5}")

if [[ -n "$SFX" ]]; then
  [[ -f "$SFX" ]] || { echo "SFX not found: $SFX" >&2; exit 1; }
  FILTER="[1:a]lowpass=f=4000,volume=0.45,afade=in:st=0:d=0.3,afade=out:st=${FADE_OUT_START}:d=1.5[bgm];"
  FILTER+="[2:a]highpass=f=800,volume=1.0[sfx];"
  FILTER+="[bgm][sfx]amix=inputs=2:duration=first:normalize=0[a]"
  ffmpeg -y -i "$VIDEO" -i "$BGM" -i "$SFX" \
    -filter_complex "$FILTER" \
    -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -shortest "$OUT"
else
  echo "⚠️  SFX omitted — this is half-completion per skill's dual-track rule." >&2
  echo "⚠️  For production output, add SFX as 3rd argument." >&2
  FILTER="[1:a]lowpass=f=4000,volume=0.50,afade=in:st=0:d=0.3,afade=out:st=${FADE_OUT_START}:d=1.5[a]"
  ffmpeg -y -i "$VIDEO" -i "$BGM" \
    -filter_complex "$FILTER" \
    -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -shortest "$OUT"
fi

echo ""
echo "✅ wrote $OUT"
echo "   Verify audio stream:"
echo "   ffprobe -v error -select_streams a -show_entries stream=codec_type,duration '$OUT'"
