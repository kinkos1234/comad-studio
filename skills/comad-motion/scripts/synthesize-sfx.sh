#!/usr/bin/env bash
# comad-motion · synthesize-sfx.sh
#
# Generate 12 SFX via ffmpeg (no external assets needed).
# Output to assets/sfx/<category>/<name>.mp3 at 44.1kHz stereo 128kbps.
#
# Techniques:
#   - sine bursts with ADSR envelope → clicks, ticks, chimes
#   - bandpass-filtered white noise with sweep → whoosh, slide, hiss
#   - sine chord arpeggio → success chime, sparkle
#
# Usage:
#   ./synthesize-sfx.sh              (writes to skill's assets/sfx/)
#   OUTDIR=/tmp/sfx ./synthesize-sfx.sh

set -euo pipefail

OUTDIR="${OUTDIR:-$HOME/.claude/skills/comad-motion/assets/sfx}"
mkdir -p "$OUTDIR"/{ui,transition,impact,keyboard,magic,feedback,progress}

# Common args
ENC_ARGS=(-ar 44100 -ac 2 -b:a 128k -y)

# ----- ui/click-soft.mp3 (50ms filtered click) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*1800*t)*exp(-t*60)+sin(2*PI*900*t)*exp(-t*40)*0.5':s=44100:d=0.15,volume=0.8" \
  "${ENC_ARGS[@]}" "$OUTDIR/ui/click-soft.mp3"

# ----- ui/click.mp3 (sharper click) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*2400*t)*exp(-t*80)':s=44100:d=0.1,volume=0.9" \
  "${ENC_ARGS[@]}" "$OUTDIR/ui/click.mp3"

# ----- ui/tap-finger.mp3 (soft finger tap) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*1200*t)*exp(-t*45)+sin(2*PI*600*t)*exp(-t*30)*0.4':s=44100:d=0.18,volume=0.7" \
  "${ENC_ARGS[@]}" "$OUTDIR/ui/tap-finger.mp3"

# ----- ui/hover-subtle.mp3 (gentle sine rise) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*(800+200*t)*t)*exp(-t*8)':s=44100:d=0.25,volume=0.35" \
  "${ENC_ARGS[@]}" "$OUTDIR/ui/hover-subtle.mp3"

# ----- ui/focus.mp3 (focus ping — bell-like) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='(sin(2*PI*1568*t)+sin(2*PI*2093*t)*0.6+sin(2*PI*2637*t)*0.3)*exp(-t*6)':s=44100:d=0.4,volume=0.55" \
  "${ENC_ARGS[@]}" "$OUTDIR/ui/focus.mp3"

# ----- ui/toggle-on.mp3 (snap up) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*(1500+800*t)*t)*exp(-t*25)':s=44100:d=0.14,volume=0.75" \
  "${ENC_ARGS[@]}" "$OUTDIR/ui/toggle-on.mp3"

# ----- transition/whoosh.mp3 (noise bandpass sweep, short) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "anoisesrc=d=0.35:c=white:a=0.6,bandpass=f=1400:w=1200,volume=0.7,afade=in:st=0:d=0.08,afade=out:st=0.27:d=0.08" \
  "${ENC_ARGS[@]}" "$OUTDIR/transition/whoosh.mp3"

# ----- transition/whoosh-fast.mp3 (quick swoosh) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "anoisesrc=d=0.2:c=white:a=0.7,highpass=f=1000,lowpass=f=3500,volume=0.7,afade=in:st=0:d=0.03,afade=out:st=0.15:d=0.05" \
  "${ENC_ARGS[@]}" "$OUTDIR/transition/whoosh-fast.mp3"

# ----- transition/slide-in.mp3 (rising noise) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "anoisesrc=d=0.5:c=white:a=0.5,bandpass=f=2000:w=1600,volume=0.65,afade=in:st=0:d=0.25,afade=out:st=0.35:d=0.15" \
  "${ENC_ARGS[@]}" "$OUTDIR/transition/slide-in.mp3"

# ----- impact/soft.mp3 (soft thud) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*80*t)*exp(-t*15)+sin(2*PI*160*t)*exp(-t*20)*0.5':s=44100:d=0.4,volume=0.85" \
  "${ENC_ARGS[@]}" "$OUTDIR/impact/soft.mp3"

# ----- impact/snap.mp3 (commit/lock snap) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*3200*t)*exp(-t*90)+sin(2*PI*1600*t)*exp(-t*60)*0.6':s=44100:d=0.12,volume=0.8" \
  "${ENC_ARGS[@]}" "$OUTDIR/impact/snap.mp3"

# ----- keyboard/type-1.mp3 (soft key press) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*2000*t)*exp(-t*70)+sin(2*PI*1000*t)*exp(-t*50)*0.4':s=44100:d=0.08,volume=0.65" \
  "${ENC_ARGS[@]}" "$OUTDIR/keyboard/type-1.mp3"

# ----- keyboard/type-2.mp3 (variation) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*2200*t)*exp(-t*75)+sin(2*PI*1100*t)*exp(-t*55)*0.35':s=44100:d=0.07,volume=0.6" \
  "${ENC_ARGS[@]}" "$OUTDIR/keyboard/type-2.mp3"

# ----- magic/sparkle.mp3 (bell cluster) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='(sin(2*PI*1760*t)*exp(-t*5)+sin(2*PI*2349*t)*exp(-t*5)*0.7+sin(2*PI*3136*t)*exp(-t*5)*0.5+sin(2*PI*4186*t)*exp(-t*6)*0.3)*0.5':s=44100:d=0.7,volume=0.55" \
  "${ENC_ARGS[@]}" "$OUTDIR/magic/sparkle.mp3"

# ----- feedback/success.mp3 (two-tone chime E5→A5, second tone delayed 180ms) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*659*t)*exp(-t*4)':s=44100:d=0.8" \
  -f lavfi \
  -i "aevalsrc='sin(2*PI*880*t)*exp(-t*4)':s=44100:d=0.62" \
  -filter_complex "[1:a]adelay=180|180[b];[0:a][b]amix=inputs=2:normalize=0,volume=0.55" \
  "${ENC_ARGS[@]}" "$OUTDIR/feedback/success.mp3"

# ----- progress/tick.mp3 (metronome tick) -----
ffmpeg -hide_banner -loglevel error -f lavfi \
  -i "aevalsrc='sin(2*PI*2800*t)*exp(-t*100)':s=44100:d=0.05,volume=0.55" \
  "${ENC_ARGS[@]}" "$OUTDIR/progress/tick.mp3"

echo ""
echo "✅ generated 16 SFX files"
find "$OUTDIR" -name "*.mp3" -type f | sort
echo ""
echo "--- duration check ---"
for f in $(find "$OUTDIR" -name "*.mp3" -type f | sort); do
  DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
  SIZE=$(ls -l "$f" | awk '{print $5}')
  echo "$(basename $f)  ${DUR}s  ${SIZE}B"
done
