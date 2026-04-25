# SFX · ffmpeg Synthesized

> **생성 방식**: `scripts/synthesize-sfx.sh` · ffmpeg `aevalsrc` / `anoisesrc` 기반 합성
> **라이선스**: **생성물 — Public Domain 유사**. sine wave / white noise / 수학 함수 조합은 창작 저작권 대상이 아닙니다. 스크립트 자체의 comad-motion 라이선스를 따름.
> **Attribution 불필요**

## 생성 일자: 2026-04-24 · 16 파일

| 파일 | 카테고리 | P등급 | 생성 방식 | Duration |
|---|---|---|---|---|
| ui/click-soft.mp3 | UI · click | P0 | sine decay (1800Hz + 900Hz) | 0.15s |
| ui/click.mp3 | UI · click | P0 | sine decay (2400Hz) | 0.10s |
| ui/tap-finger.mp3 | UI · tap | P0 | sine decay (1200Hz + 600Hz) | 0.18s |
| ui/hover-subtle.mp3 | UI · hover | P2 | sine sweep rising | 0.25s |
| ui/focus.mp3 | UI · focus | P0 | bell-like 3-tone cluster | 0.40s |
| ui/toggle-on.mp3 | UI · toggle | P1 | sine chirp rising | 0.14s |
| transition/whoosh.mp3 | transition | P1 | bandpass noise burst | 0.35s |
| transition/whoosh-fast.mp3 | transition | P1 | bandpass noise short | 0.20s |
| transition/slide-in.mp3 | transition | P1 | bandpass noise with fade | 0.50s |
| impact/soft.mp3 | impact | P1 | low sine thud | 0.40s |
| impact/snap.mp3 | impact | P1 | high sine snap | 0.12s |
| keyboard/type-1.mp3 | keyboard | P0 | sine pair decay | 0.08s |
| keyboard/type-2.mp3 | keyboard | P0 | sine pair decay (variation) | 0.07s |
| magic/sparkle.mp3 | magic | P1 | bell cluster (A6-C7-G7-C8) | 0.70s |
| feedback/success.mp3 | feedback | P1 | E5→A5 rising two-tone chime | 0.80s |
| progress/tick.mp3 | progress | P2 | high sine click | 0.05s |

## 재생성 명령

```bash
~/.claude/skills/comad-motion/scripts/synthesize-sfx.sh
```

## 합성 한계 & 교체 안내

ffmpeg 합성 SFX 는 기본 UI 음(click/tick/chime/whoosh) 에 적합하지만 **복잡한 음색 (mechanical keyboard · terminal beep · paper rustle · real impact)** 은 합성으로 재현하기 어려움. 다음 경우 실제 녹음/다운 파일로 교체 권장:

| 상황 | 대안 |
|---|---|
| 진짜 기계식 키보드 타격감이 필요 | [Freesound.org CC0 mechanical keyboard](https://freesound.org/search/?q=mechanical+keyboard&f=license:%22Creative+Commons+0%22) |
| 자연스러운 UI notification | Pixabay SFX / Zapsplat free tier |
| Whoosh / swoosh 를 더 시네마틱하게 | 영상 제작용 SFX 팩 (다수 CC0 팩 존재) |

교체 시 이 표에 raw source URL / artist 기록 필수.
