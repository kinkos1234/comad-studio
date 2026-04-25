# Phase 2 · Placement-Aware Prompting (재설계)

> **Status**: Draft · 2026-04-25
> **Supersedes**: 초기 Phase 2 계획 ("SAM3 로 이미지 요소 분할")
> **Reason**: SAM3 는 **proprietary Meta 라이센스 + CUDA 12.6+ GPU 필수** 로 Mac arm64 로컬 실행 불가. Replicate/HF Inference API 우회도 pay-per-call 비용 + 네트워크 지연 + 외부 의존성 증가. 투자 회수율이 낮다.

## Phase 1C 의 한계

- Codex `/imagen` 이 슬라이드 PNG 한 장을 통째로 렌더 → **pixel-perfect 디자인 품질 확보**.
- 하지만 사용자가 "슬라이드 3 의 제목만 바꾸고 싶다" 는 요청 시 **편집 경로 B (multimodal diff)** 가 불안정. Codex 는 `이미지 + "제목만 수정하라"` 지시에 대해 전체 레이아웃을 재해석하는 경향이 있어 원본 구도를 보존 못 함.
- 결과: 사실상 **경로 A (spec 수정 후 재생성)** 에 의존 → 단일 요소 수정 시에도 슬라이드 전체 regenerate. 토큰 비용 · 일관성 (lighting/font) 모두 낭비.

## Phase 2 목표 재정의

**"슬라이드 이미지의 특정 영역을 구조적으로 식별 가능하게 만들고, 그 영역에 대해서만 재생성/편집하도록 한다."**

SAM3 를 못 쓰니 **이미지 생성 시점**에 구조를 강제하는 방향으로 전환.

## 접근 B · Placement-Aware Prompting

### 원리

Codex `/imagen` 프롬프트에 **슬라이드 레이아웃을 그리드 형태로 미리 명시**하고, 각 영역의 의미 (title / kpi / bullet / image / cta) 를 고정한다. 렌더링 후에는 이 구조를 **spec.json** 에 저장해 재편집 시 그대로 사용.

### 레이아웃 그리드 표준

슬라이드는 12 × 7 그리드 (16:9 비율 · 960×540 정규화 단위).

```
┌─────────────────────────┬─────────────────────────┐
│ row 1-2 · Title Zone    │                         │ ← col 1-8: Title, 9-12: Accent KPI
├─────────────────────────┼─────────────────────────┤
│ row 3-5 · Content Zone                            │ ← col 1-12: 3 Card columns or 2 Split
├───────────────────────────────────────────────────┤
│ row 6-7 · Footer Zone   │                         │ ← col 1-6: CTA, 7-12: Meta/Logo
└───────────────────────────────────────────────────┘
```

### 프롬프트 템플릿 예시

```yaml
slide:
  type: "three-card"       # cover | problem | solution | market | competitor | roadmap | ask | three-card | kpi-hero
  zones:
    title:
      col: "1-8"
      row: "1-2"
      text: "투자자 3 페인 포인트"
      align: "left"
    kpi_accent:
      col: "9-12"
      row: "1-2"
      value: "73%"
      label: "불안"
      color: "red"
    card_1:
      col: "1-4"
      row: "3-5"
      title: "투자자 73%"
      body: "AI 정보 과잉에 지침"
    card_2:
      col: "5-8"
      row: "3-5"
      title: "전문가 42%"
      body: "공신력 부족을 체감"
    card_3:
      col: "9-12"
      row: "3-5"
      title: "포트폴리오 2.8x"
      body: "리서치 시간 증가"
```

### Codex `/imagen` 프롬프트 생성 규칙

스크립트가 spec.yaml → 확장 프롬프트 조립:

```text
Generate a slide image (16:9, 1920×1080 compatible) with this EXACT layout:

TITLE ZONE (top-left, columns 1-8, rows 1-2):
  Text: "투자자 3 페인 포인트"
  Style: Pretendard Variable SemiBold, 72pt, #eef2ff on #0a0f1c
  Alignment: left, vertically centered

KPI ACCENT ZONE (top-right, columns 9-12, rows 1-2):
  Big number: 73%
  Label: "불안"
  Color: emerald (#6ee7b7) accent on navy

CONTENT ZONE (middle, full width, rows 3-5):
  3 equal cards side-by-side (4/4/4 columns)
  Card 1 (col 1-4): title "투자자 73%", body "AI 정보 과잉에 지침"
  Card 2 (col 5-8): title "전문가 42%", body "공신력 부족을 체감"
  Card 3 (col 9-12): title "포트폴리오 2.8x", body "리서치 시간 증가"
  Each card: 20px rounded border, #111827 bg, #1f2937 border

FOOTER ZONE (bottom, rows 6-7):
  Left (col 1-6): no content (empty)
  Right (col 7-12): small logo "comad world" in #5b6686

Do NOT add decorations outside zones. Do NOT rotate elements.
Respect column gutters (48px between cards).
Native 16:9 aspect ratio (1672×941 from Codex is OK).
```

### 편집 경로

**Zone-Level 편집** (새로운 경로 C):
- 사용자: "카드 2 의 수치를 '42%' 에서 '58%' 로 바꾸고 싶어"
- 스크립트가 spec.yaml 의 `card_2.title` 만 수정 후 전체 재생성 (단, 프롬프트 내 다른 zone 은 동일 → lighting/font 일관성 높음)
- 진정한 "해당 영역만 수정" 은 여전히 불가 (Codex API 제약), 하지만 **비지정 zone 을 freeze 하는 지시** 로 drift 최소화

**Overlay 편집** (경로 D · 편집가능 PPT):
- pptxgenjs 에서 이미지를 슬라이드 배경으로 깔고, `title_zone` 좌표에 **pptxgenjs text box 를 같은 좌표로 overlay**
- 이미지 내 텍스트는 "시각적 프리젠테이션", overlay text 는 "실제 편집 가능 텍스트". 투명도 100 이 아니라 **이미지 텍스트를 지우고 (inpaint 불가) 그 자리에 덮음**
- 절충: 이미지 쪽 텍스트는 그대로 두고, overlay 를 그 위에 씌워 100% 동일 텍스트로 덮음 → 편집 시 overlay 만 바꿔도 시각적 동일
- **주의**: 폰트/크기/색/자간이 picture-perfect 로 맞아야 하므로 **CSS→TTF 매칭 테이블 필요** — 이미지 내 Pretendard SemiBold 72pt = pptxgenjs `{ fontFace: 'Pretendard Variable', fontSize: 72, bold: false, charSpacing: -200 }` 대응

## 실행 계획

| Phase | 작업 | 산출물 | 시간 |
|---|---|---|---|
| 2A | Zone spec schema 작성 | `references/zone-schema.json` | 2h |
| 2B | 스크립트 `spec-to-prompt.js` — zone spec → Codex 프롬프트 변환 | engine/spec-to-prompt.js | 3h |
| 2C | pptxgenjs overlay 코드 생성기 | engine/image2pptx-overlay.js | 4h |
| 2D | 7 slide-type 별 zone template 라이브러리 | references/zone-templates/*.yaml | 3h |
| 2E | **Echo 7-slide pitch** 재작성 (Zone spec 으로) + 비교 (Phase 1C vs Phase 2) | `/tmp/echo-deck-v2/` | 4h |

**Total**: 16h 이전 Phase 1C 의 3h 대비 5배 투자. 가치 있는지는 **2E 의 실증** 으로 판정.

## 판정 기준 (Gate)

Phase 2 go 조건 (Phase 1C 의 이미지 품질은 유지하면서 편집성 ≥ 50%):

1. **Zone accuracy**: 프롬프트에 명시한 zone 좌표와 실제 렌더된 텍스트 위치 오차 < 5% (1920 × 1080 기준 ±50px)
2. **Edit cost**: 단일 zone 수정 시 (ex. "카드 2 수치 교체") token 비용 ≤ Phase 1C 방식의 60%
3. **Font match**: overlay 텍스트가 이미지 텍스트와 시각적으로 구분 불가 (블라인드 테스트 7/10 이상)
4. **Re-edit robustness**: 연속 5회 편집 후에도 레이아웃 drift 없음

실패 시 **Phase 2 보류** 후 다음 대안:
- C1. SVG-first: Codex 는 PNG 배경만 렌더, 모든 텍스트/KPI 를 pptxgenjs 로 조립
- C2. Template-first: 10 슬라이드 타입 하드코딩, Codex 는 이미지 없이 pptxgenjs 만으로 조립 (이미지 품질 ↓, 편집성 ↑)

## 현재 블로커

없음 — Phase 1C 는 안정 v1.0, Phase 2 는 선택적 업그레이드. 사용자 트리거 시 착수.
