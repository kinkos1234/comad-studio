---
name: comad-pptx
description: 고품질 PPTX 생성 스킬 — Codex /imagen 으로 슬라이드 한 장씩 이미지 생성 후 pptxgenjs 로 LAYOUT_WIDE PPTX 조립. 디자인 품질은 Codex 이미지 그대로 · 편집은 overlay 텍스트 또는 spec 수정 후 재생성. 트리거 — 한국어 "PPT 만들어줘, 슬라이드 만들어줘, 발표자료, PPT 로 뽑아줘, 프리젠테이션, deck 만들어줘, 파워포인트, 기획안 PPT, 마케팅 덱, 릴리스 슬라이드"; 영어 "create pptx, make slides, pitch deck, presentation slides, export pptx, slide deck, marketing deck, investor deck". 출력 — pptx (LAYOUT_WIDE 13.333×7.5") 각 슬라이드 이미지 기반. Phase 1C.
---

# §0 정체성 (comad-pptx · image-first)

너는 마케팅·제안서 수준의 PPTX 를 생성한다. **이미지 우선 아키텍처** — Codex `/imagen` 이 각 슬라이드를 디자인 완성도 높은 이미지로 렌더링, pptxgenjs 가 pptx 컨테이너로 조립한다.

**핵심 원칙**:
- 🎨 **디자인 품질 우선**: HTML→PPTX 번역의 한계 (그라데이션, SVG, 폰트 fallback) 없음
- 🔒 **예측 가능**: Keynote/PPT 에서 이미지는 100% 그대로 렌더
- 🔁 **편집 루프**: "slide 3 따뜻하게" 같은 요청 → spec.json 업데이트 후 재생성 또는 multimodal edit
- 📝 **검색 가능**: 선택 시 overlay 텍스트 레이어 (투명)로 스크린리더·검색·부분 편집 지원

---

# 아키텍처

```
spec.json (deck + slides vars)
  ↓ build prompt from references/imagen-prompts.md template
  ↓
prompts/slide-N.txt
  ↓ scripts/slide-imagen.sh (wraps comad-image/scripts/imagen.sh)
  ↓
slide-N.png (1280×720)
  ↓ engine/image2pptx.js (pptxgenjs · LAYOUT_WIDE)
  ↓
output.pptx
```

---

# 슬라이드 타입 (템플릿 7종)

`references/imagen-prompts.md` 에 상세:
1. **cover** — 제목 deck 커버
2. **problem / pain-points** — 3 카드 통증점
3. **solution / flow** — 3-step 솔루션
4. **metric / market** — 3 big numbers (다크)
5. **comparison / competitors** — 3열 비교
6. **roadmap / timeline** — 4 노드 분기 타임라인
7. **ask / CTA** — 투자 요청 + usage chips

각 타입마다 prompt skeleton + variable slots (`{title}`, `{palette}`, ...).

---

# 사용법

## 1. Spec 작성
```json
// deck.spec.json
{
  "deck": {
    "title": "Echo · AI Podcast Launch",
    "style": "editorial-minimal",
    "palette": { "navy": "#0f172a", "accent": "#10b981" }
  },
  "slides": [
    {
      "id": "slide-1",
      "type": "cover",
      "prompt_file": "prompts/slide-1.txt",
      "image": "slide-1.png",
      "vars": { "title": "...", "subtitle": "..." },
      "overlays": [
        { "text": "Echo · AI Podcast 2026", "x_in": 1.0, "y_in": 1.15, "hidden": true }
      ]
    }
  ]
}
```

## 2. 빌드
```bash
~/.claude/skills/comad-pptx/scripts/deck-imagen.sh deck.spec.json [output.pptx]
```
- 각 슬라이드 prompt 를 Codex /imagen 으로 병렬 호출 (3 parallel)
- 생성된 이미지 검증 (SHA1)
- pptxgenjs 로 LAYOUT_WIDE PPTX 조립

## 3. 편집

**경로 A — spec 재생성** (구조/카피 변경):
```bash
# spec.json vars 업데이트 후
~/.claude/skills/comad-pptx/scripts/deck-imagen.sh deck.spec.json
# (이미 존재하는 png 는 skip · 변경된 슬라이드만 regenerate)
```

**경로 B — multimodal 편집** (색/톤/미세 조정):
```bash
# TODO: slide-edit.sh 향후 추가
codex exec "Here's current slide [image]. Keep layout identical. Change color palette from navy to warm amber."
```

---

# 의존성

- **node** ≥ 18 + **npx** 로 pptxgenjs 접근
- **pptxgenjs** (전역): `npm install -g pptxgenjs`
- **codex CLI** (ChatGPT 로그인 필요): `npm install -g @openai/codex` + `codex login`
- **comad-image skill** 설치되어 있어야 함 (imagen.sh 재사용)

---

# 상태

- v0.9 (2026-04-24) — image-first 파이프라인 초기 구축
- HTML → PPTX 번역 방식은 deprecated (폐기됨): pptxgenjs 의 그라데이션·SVG·폰트 fallback 한계로 품질 불충분. 코드 삭제됨.
- Phase 1C. 골든 샘플: Echo pitch 7 슬라이드.
