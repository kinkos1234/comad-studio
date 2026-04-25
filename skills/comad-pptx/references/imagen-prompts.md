# Slide Imagen Prompt Templates

한 장씩 Codex `/imagen` 으로 슬라이드 이미지를 생성하기 위한 프롬프트 스켈레톤. 모든 출력은 **1280×720 · 16:9** 비율, 슬라이드 한 장으로 바로 사용 가능한 품질.

> **필수 선행 참조** (2026-04-25 추가): `~/.claude/skills/comad-image/references/prompt-patterns.md`
> - §4 Codex 11-필드 템플릿 — PPT 슬라이드 같은 구조화 시안에 최적
> - §4-2 용도별 추가 필드: 에디토리얼 포스터 (cover/divider), 교육/인포그래픽 (data/table), 캠페인 포스터 (ask/CTA)
> - §5 한국 감성 키워드 — 한국어 덱은 필수 삽입
> - §6 DNA 1 (타이포 히어로) + DNA 3 (정보 밀도) 주로 사용

## 공통 헤더 (모든 슬라이드 prompt 앞에 삽입)

```
16:9 aspect ratio, 1280x720 presentation slide.
Minimal editorial layout, generous whitespace.
Flat modern typography, Pretendard/Inter-like sans-serif.
No logos, no watermarks, no fake chart data unless specified.
Background extends edge-to-edge (no frames, no padding borders).
```

## 슬라이드 타입별 템플릿

### 1. cover
```
{COMMON_HEADER}

Type: deck cover slide.
Background: solid {bg_color} ({bg_hex}).
Eyebrow text top-left: "{eyebrow}" in {accent_color} small uppercase with wide letter-spacing.
Large bold title center-left: "{title}" — 3-5 words on 1-2 lines, {title_color} text.
Subtitle below (smaller, lighter gray): "{subtitle}" — one sentence.
Small meta bottom-left: "{meta}" (e.g., company name · date).
Single accent shape (small {accent_color} circle OR diagonal line) as visual anchor.
No images. No stock photos. Just typography + one accent.
```

### 2. problem / pain-points (3-card grid)
```
{COMMON_HEADER}

Type: problem slide with 3 cards horizontally.
White background.
Red eyebrow "Problem" top-left, tight wide-spaced.
Bold dark headline (2 lines): "{headline}" left-aligned, large font.
Below: 3 rounded cards side by side with subtle pastel backgrounds (red-50, amber-50, slate-50).
Each card contains:
  - Large bold statistic top-left ({num_color}): "{num}"
  - Bold card heading: "{card_title}"
  - Small body text 2 lines: "{card_body}"
Padding 32px. Cards visually balanced, equal width.
```

### 3. solution / flow (3-step)
```
{COMMON_HEADER}

Type: solution flow slide, 3 steps horizontal.
White-to-soft-gradient background.
Green eyebrow "Solution" top-left.
Bold headline (2 lines): "{headline}"
Below: 3 steps with numbered markers "01" "02" "03" in bold green, each with:
  - Step title "{step_title}"
  - Short description (1-2 lines) "{step_body}"
Between steps: small green arrow or dash connector.
```

### 4. metric / market size (3 big numbers, dark theme)
```
{COMMON_HEADER}

Type: market metrics slide, 3 big numbers on dark navy background.
Bg: solid {bg_color} (navy #0f172a).
Eyebrow "{eyebrow}" in yellow/gold top-left.
Bold white headline (2 lines): "{headline}".
Below: 3 metric cards side-by-side with faint navy-lighter card backgrounds and subtle borders.
Each card:
  - Small uppercase label gray: "{label}"
  - Huge accent-colored number: "{value}" (88px+ bold, each card a different accent: green, yellow, blue)
  - 2-line light gray body: "{body}"
```

### 5. comparison / competitors (3-column table)
```
{COMMON_HEADER}

Type: competitive comparison slide, 3 columns side-by-side.
White background.
Blue eyebrow top-left: "{eyebrow}".
Bold headline: "{headline}".
3 columns:
  Col 1 (highlighted green "Us" · our brand): rows of ✓ statements
  Col 2 (gray "Competitor A"): rows of ✗ statements
  Col 3 (gray "Competitor B"): rows of mixed statements
Each row: icon + one-line statement in 15pt.
Thin vertical dividers between columns.
```

### 6. roadmap / timeline (4 nodes)
```
{COMMON_HEADER}

Type: quarterly roadmap timeline slide.
Soft gray background.
Green eyebrow top-left: "Roadmap".
Bold headline: "{headline}".
Horizontal timeline with 4 circular nodes evenly spaced:
  Node 1: green solid "{q1_label}" below · "{q1_title}" · "{q1_body}"
  Node 2: green solid "{q2_label}" below · "{q2_title}" · "{q2_body}"
  Node 3: yellow solid "{q3_label}" below · "{q3_title}" · "{q3_body}"
  Node 4: light gray "{q4_label}" below · "{q4_title}" · "{q4_body}" (future)
Thin gray line connecting nodes.
```

### 7. ask / CTA (amount + usage)
```
{COMMON_HEADER}

Type: investment ask / CTA slide.
Background: gradient from navy (#0f172a top-left) to royal blue (#1e40af bottom-right), 135deg.
Yellow eyebrow top-left: "The Ask".
Enormous white amount text (144pt+): "{amount}" with smaller unit suffix (48pt yellow): "{unit}".
Below: white bold "{title}" subtitle.
Two-line light gray description: "{body}".
Near bottom: 4 usage chips (rounded pills, semi-transparent white border) with text: "{chip_1}" "{chip_2}" "{chip_3}" "{chip_4}".
Bottom-left small gray meta: "{meta}".
```

## spec.json 스키마

```json
{
  "deck": {
    "title": "Echo · AI Podcast Launch",
    "style": "editorial-minimal",
    "palette": {
      "navy": "#0f172a",
      "accent": "#10b981",
      "warning": "#f59e0b",
      "danger": "#ef4444"
    },
    "font_hint": "Pretendard + Inter hybrid",
    "output_dir": "outputs/YYYY-MM-DD/echo-pitch"
  },
  "slides": [
    {
      "id": "slide-1",
      "type": "cover",
      "vars": {
        "bg_color": "navy",
        "bg_hex": "#0f172a",
        "eyebrow": "Echo · AI Podcast 2026",
        "accent_color": "emerald",
        "title": "30 분 대화로\n듣는 세상",
        "title_color": "white",
        "subtitle": "AI 진행자가 매일 아침 뉴스·팟캐스트·책을 당신 목소리로 요약합니다.",
        "meta": "Echo Labs · Series A · 2026-04-24"
      }
    },
    {
      "id": "slide-2",
      "type": "problem",
      "vars": { "headline": "...", "cards": [...] }
    }
  ]
}
```

## 편집 루프

**경로 A · spec 재생성**:
```
edit spec.json (해당 slide vars 수정)
→ slide-imagen.sh <new spec> <new.png>
→ deck-imagen.sh rebuild → new.pptx
```

**경로 B · multimodal 편집**:
```
codex exec "Here is current slide [image]. Keep layout, change [X]."
→ new png
→ deck rebuild
```

두 경로 모두 `spec.json.history[]` 에 edit log append.
