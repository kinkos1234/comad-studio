# Video Export Pipeline

> HTML → MP4 → (60fps | GIF) → +BGM/SFX. 단계별 툴과 플래그.

## 파이프라인 전체

```
 your-anim.html
      │
      │ render-video.js  (Playwright recordVideo → ffmpeg h264)
      ▼
 your-anim.mp4                     ← 기본 산출물 (25fps, 무음)
      │
      ├── convert-formats.sh --60fps
      │        │ (ffmpeg minterpolate · CPU heavy)
      │        ▼
      │   your-anim-60fps.mp4       ← 부드러운 60fps 파생
      │
      ├── convert-formats.sh --gif --gif-width=900
      │        │ (2-pass palettegen + paletteuse)
      │        ▼
      │   your-anim.gif             ← 20fps GIF · 디스코드/README 용
      │
      └── add-music.sh bgm.mp3 sfx.wav
               │ (lowpass 4k / highpass 800 / normalize=0)
               ▼
          your-anim-audio.mp4       ← ⭐ 최종 전달물 (오디오 포함)
```

## render-video.js · 옵션

| 옵션 | 기본 | 설명 |
|---|---|---|
| `<html>` | — | 입력 HTML (file:// 로드) |
| `--duration=N` | 10 | 녹화 길이 (초) |
| `--width=N` | 1920 | viewport 가로 |
| `--height=N` | 1080 | viewport 세로 |
| `--fontwait=N` | 1.5 | `window.__ready` 없을 때 폰트 대기 시간 |
| `--readytimeout=N` | 8 | `__ready` 대기 최대 |
| `--trim=N` | auto | 앞쪽 trim 수동 지정 (없으면 __ready 시각) |
| `--keep-chrome` | off | chrome 엘리먼트 숨기지 않음 (디버깅) |

**실행**:
```bash
NODE_PATH=$(npm root -g) node ~/.claude/skills/comad-motion/scripts/render-video.js \
  my-anim.html --duration=10 --width=1920 --height=1080
```

## add-music.sh · 옵션

```bash
add-music.sh <video.mp4> <bgm.mp3> [sfx.wav]
```
- 출력: `<basename>-audio.mp4`
- SFX 생략 시 경고 출력 (반쪽 완성)
- 자동 적용: `lowpass=4000` (BGM) · `highpass=800` (SFX) · `volume=0.45/1.0` · `afade` in/out · `amix normalize=0`

## convert-formats.sh · 옵션

```bash
convert-formats.sh <video.mp4> [--60fps] [--gif] [--gif-width=900]
```
- 플래그 없으면 둘 다 생성
- 60fps: `minterpolate` 사용. 30s 영상에 CPU 2-3분
- GIF: 20fps · 기본 너비 900px · 2-pass palette

## 검증 체크리스트 (전달 전 필수)

```bash
# 1. 오디오 스트림 존재
ffprobe -v error -select_streams a -show_entries stream=codec_type,duration your-anim-audio.mp4

# 2. duration ±0.5초 일치
ffprobe -v error -show_entries format=duration -of csv=p=0 your-anim-audio.mp4

# 3. 콘솔 에러 0 (render-video.js stderr 확인)

# 4. 파일 크기 합리적
# 10s @ 1920×1080 → 3-5MB 기대
# 30s → 10-15MB
# 60s → 20-30MB
ls -lh your-anim-audio.mp4
```

## 자주 겪는 문제

### "No video recording"
- recordVideo dir 이 read-only · /tmp 공간 부족
- 해결: 디스크 공간 확인, `tmpDir` 권한 확인

### 영상 앞쪽이 검게 나옴
- `window.__ready` 세팅 안 됨 (Stage 컴포넌트 누락)
- 해결: HTML 에 `engine/animations.js` 로드 + `<Stage>` 사용

### GIF 파일 20MB+
- 1080p GIF 는 원래 큼. `--gif-width=640` 로 축소 권장
- 배경에 gradient/blur 많으면 palette 효율 낮음

### 60fps 변환이 너무 느림
- `minterpolate` 는 CPU 집약 작업. 10s @ 1080p 에 1-2분 정상
- 급하면 `-preset faster`, 또는 skip (25fps 그대로 충분할 때)
