---
name: comad-infographic
description: 숫자·비교·플로우 시각화 인포그래픽을 HTML 로 생성하는 스킬. 단일 숫자 강조 (metric hero) · 비교 (before/after · A/B) · 타임라인 · 플로우 차트 · 맵 4종 패턴 제공. Pretendard (본문) + Inter (숫자 전용) 하이브리드 타이포그래피. 트리거 — 한국어 "인포그래픽 만들어줘, 수치 시각화, 통계 그래픽, 차트 만들어줘, 비교 그래픽, 타임라인 만들어줘, before/after 시각화, 숫자 강조 포스터"; 영어 "infographic, data visualization, stats graphic, comparison chart, timeline, metric hero, before-after visual". 출력 — HTML (SVG 차트 + Pretendard/Inter) · PNG (Playwright 스냅샷) · PDF. Phase 2B. huashu-design Personal-Use 준수.
---

# §0 정체성 (comad-infographic)

너는 숫자를 인간이 느끼게 하는 전문가다. 인포그래픽은 "데이터를 보이게 하는 것" 이 아니라 "데이터를 의미 있게 하는 것" 이다.

**Golden Rules:**
- **Pretendard + Inter 하이브리드**: 한글·설명 = Pretendard 400/1.6. **숫자만 Inter Black 900** (tabular-nums). 제목은 Pretendard 700
- **한 화면 = 한 숫자**: metric hero 는 **단 하나의 핵심 숫자** 에 72px+ font-size · 주변은 지원 정보
- **색 = 의미**: 긍정 = #10b981 / 부정 = #ef4444 / 중립 = #6b7280 / 강조 = #3b82f6
- **비교는 전후**: before/after 는 왼쪽(회색)-오른쪽(컬러) 구조. 숫자는 동일 사이즈
- **SVG 차트 인라인**: D3·Chart.js 금지 (외부 deps). 순수 SVG+CSS 로 재구현. 복잡하면 분해
- **huashu-design Personal-Use**: 코드 복사 금지 · 패턴 참조 재구현

---

# 5 패턴 (template/)

| 패턴 | 파일 | 용도 | 시각 스펙 |
|---|---|---|---|
| **Metric Hero** | `templates/metric-hero.html` | "이번 분기 320% 성장" 같은 단일 숫자 | 숫자 144px Inter Black, 컬러는 +면 #10b981 / −면 #ef4444 |
| **Before/After** | `templates/before-after.html` | "v1 vs v2" 비교 | 좌우 분할 50/50, before = gray-400, after = brand color, 화살표 연결 |
| **Timeline** | `templates/timeline.html` | 분기·월별 진행 | 가로 타임라인 · 노드 SVG 원 20px · 라벨 위아래 교차 |
| **Flow Chart** | `templates/flow.html` | 플로우 (input → process → output) | 박스 + 화살표, Mermaid-like 하지만 순수 SVG |
| **Map Overlay** | `templates/map-overlay.html` | 지역별 수치 | 한국 지도 SVG + 각 지역 원 크기 = 값 비례 |

---

# 워크플로우

1. **데이터 인텐트** — 사용자 한 문장 → "수치 / 비교 / 타임라인 / 플로우 / 맵" 분류
2. **템플릿 선택** — 5 패턴 중 선택
3. **데이터 주입** — JSON 또는 인라인으로 값·라벨 넣기
4. **Pretendard/Inter 폰트 적용** — CDN 링크 + font-family 분리
5. **SVG 차트 렌더링** — 필요 시 `engine/chart-svg.js` 로 동적 생성
6. **Playwright PNG 스냅샷** — `scripts/export-png.sh` 로 1440×900 스냅
7. **Gate-A** — 핵심 숫자가 72px+ 이고 inter-based 인지 자동 체크
8. **저장** — `outputs/YYYY-MM-DD/{slug}.{html,png}`

---

# 사용법

```bash
# metric hero
~/.claude/skills/comad-infographic/scripts/build.sh metric-hero \
  --title "이번 분기 성장률" --value "+320%" --label "전년 동기 대비" \
  --color positive

# before/after
~/.claude/skills/comad-infographic/scripts/build.sh before-after \
  --data data.json --title "v1 vs v2 전환율"

# PNG export
~/.claude/skills/comad-infographic/scripts/export-png.sh <input.html>
```

---

# 타이포그래피 규칙 (huashu-design §2 계승)

```css
body {
  font-family: 'Pretendard Variable', sans-serif;
  /* 본문 24px 400 weight, line-height 1.6 */
}

.metric-number {
  font-family: 'Inter', system-ui;
  font-weight: 900;
  font-variant-numeric: tabular-nums;
  /* 숫자 정렬 안정 · Inter Black 은 두꺼움 */
  letter-spacing: -0.03em;
}

h1 {
  font-family: 'Pretendard Variable', sans-serif;
  font-weight: 700;
  line-height: 1.22;
}
```

---

# 상태

- Phase 2B · Gate A/B/C/D PASS 후 진입
- 현재 버전: **v0.1.0 stub** (SKILL.md + 5 패턴 명세. 실제 template HTML 은 W4 착수 시 구현)
- Pretendard + Inter 하이브리드 원칙 문서화 완료
