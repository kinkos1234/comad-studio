#!/usr/bin/env bash
# comad-motion · convert-formats.sh
#
# Derive 60fps MP4 and palette-optimized GIF from a 25fps source MP4.
#
# Usage:
#   convert-formats.sh <video.mp4> [--60fps] [--gif] [--gif-width=900]
#
# Defaults: both outputs. Pass flags to limit.
#
# 60fps: uses ffmpeg minterpolate (motion estimation). Takes time; produces
# smooth playback even though source was 25fps.
#
# GIF: two-pass palette (palettegen + paletteuse) to minimize dithering noise
# and output file size. --gif-width defaults to 900px (fits Discord / GitHub).

set -euo pipefail

VIDEO="${1:-}"
if [[ -z "$VIDEO" ]]; then
  echo "Usage: convert-formats.sh <video.mp4> [--60fps] [--gif] [--gif-width=900]" >&2
  exit 1
fi
[[ -f "$VIDEO" ]] || { echo "Not found: $VIDEO" >&2; exit 1; }

BASE="${VIDEO%.*}"
OUT_60="${BASE}-60fps.mp4"
OUT_GIF="${BASE}.gif"

DO_60=true
DO_GIF=true
GIF_W=900

# If any explicit flag given, start with both off then turn on the requested
DO_EXPLICIT=false
for arg in "$@"; do
  case "$arg" in
    --60fps|--gif) DO_EXPLICIT=true ;;
    --gif-width=*) GIF_W="${arg#*=}" ;;
  esac
done
if $DO_EXPLICIT; then
  DO_60=false; DO_GIF=false
  for arg in "$@"; do
    case "$arg" in
      --60fps) DO_60=true ;;
      --gif)   DO_GIF=true ;;
    esac
  done
fi

if $DO_60; then
  echo "→ rendering 60fps via minterpolate: $OUT_60"
  ffmpeg -y -i "$VIDEO" \
    -vf "minterpolate=fps=60:mi_mode=mci:mc_mode=aobmc:me_mode=bidir:vsbmc=1" \
    -c:v libx264 -crf 18 -preset slower -pix_fmt yuv420p -c:a copy \
    "$OUT_60"
  echo "   ✅ $OUT_60"
fi

if $DO_GIF; then
  PALETTE="$(mktemp -t palette.XXXXXX).png"
  echo "→ pass 1 palette: $PALETTE"
  ffmpeg -y -i "$VIDEO" -vf "fps=20,scale=${GIF_W}:-1:flags=lanczos,palettegen=stats_mode=diff" "$PALETTE"
  echo "→ pass 2 paletteuse: $OUT_GIF"
  ffmpeg -y -i "$VIDEO" -i "$PALETTE" \
    -filter_complex "[0:v]fps=20,scale=${GIF_W}:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
    "$OUT_GIF"
  rm -f "$PALETTE"
  SIZE=$(ls -l "$OUT_GIF" | awk '{print $5}')
  echo "   ✅ $OUT_GIF (${SIZE} bytes)"
fi
