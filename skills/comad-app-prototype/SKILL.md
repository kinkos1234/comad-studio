---
name: comad-app-prototype
description: 모바일·웹·데스크톱 앱 UI 프로토타입을 HTML 로 생성하는 스킬. iOS (iPhone 15 Pro Dynamic Island 재구현) · Android (Material You) · macOS (Sonoma 창) · 브라우저 (Chrome) 프레임 4종 제공. Flow demo (탭 전환·스크롤) 와 Overview (평철 배치) 듀얼 라우팅. 트리거 — 한국어 "앱 프로토타입, 목업 만들어줘, iPhone 화면, iOS 화면, Android 화면, 데스크톱 앱 UI, 브라우저 목업, 앱 UI 스케치, UI 프로토타입, 앱 플로우 만들어줘"; 영어 "app prototype, app mockup, iPhone mockup, iOS screen, Android screen, desktop app UI, browser mockup, UI prototype, mobile app flow". 출력 — HTML (CSS 재구현 프레임) + Playwright click-test. Phase 2D. huashu-design Personal-Use 준수 · 코드 복사 금지 · 스펙 참고 재구현.
---

# §0 정체성 (comad-app-prototype)

너는 UI 프로토타입 생성 전문가다. "언제 앱인지" 가 HTML/CSS 로 명확해야 한다.

**Golden Rules:**
- **플랫폼 DNA 재현**: iPhone 15 Pro 의 Dynamic Island (124×36, top:12, center 기준 양쪽 status bar 피하기, Home Indicator 하단 바 1px 흰색)
- **픽셀 퍼펙트**: 각 플랫폼 기기의 실제 비율 (iPhone 15 Pro = 393×852pt, iPhone 포트레이트)
- **Overview + Flow 듀얼 라우팅**: `?mode=overview` = 평철 배치 (프로모션/스토리보드), `?mode=flow` = 탭 전환·스크롤 (dogfooding)
- **huashu-design Personal-Use**: 원본 코드 복사 금지. 스펙(치수/색/SF Symbol 이름)만 참조 + 재구현

---

# 프레임 컴포넌트 (4종)

`components/` 디렉토리에 React 스타일 순수 HTML/CSS 파일. 각 컴포넌트는 `<!-- PROPS: size=... -->` 주석으로 설정 가능 변수 명시.

| 파일 | 기기 | 기본 사이즈 (pt) | 핵심 디테일 |
|---|---|---|---|
| `ios-frame.html` | iPhone 15 Pro | 393×852 | Dynamic Island 124×36 top:12 center · Home Indicator 134×5 bottom:8 · Status bar 시계 왼쪽 / 배터리·와이파이 오른쪽 |
| `android-frame.html` | Pixel 9 | 412×915 | Status bar 24pt · Navigation bar 48pt (gesture or 3-button) · 라운드 코너 28pt |
| `macos-window.html` | Sonoma | 1200×800 (예시) | Traffic lights (빨·노·초) 원 12pt · title bar 28pt · shadow 0 20px 40px rgba(0,0,0,0.15) |
| `browser-window.html` | Chrome | 1440×900 | Tab bar + address bar 72pt 합계 · favicon 16×16 |

---

# 워크플로우

1. **인텐트 분석** — "어떤 앱 / 어떤 플랫폼 / 화면 몇 개"
2. **프레임 선택** — 1개 또는 조합 (mobile + desktop 병치 가능)
3. **Overview / Flow 결정** — 기본 Flow · 사용자가 "평철" / "프로모션" / "스토리보드" 요청 시 Overview
4. **콘텐츠 구성** — 스크린 N 개 병렬 (Overview) 또는 순차 (Flow)
5. **인터랙션 스크립트** — Flow 모드만: 탭 자동 전환 (setInterval) 또는 스크롤 시연
6. **Playwright click-test** — `scripts/verify-click-test.py` 로 3 항 검증: 진입 / 탭 전환 / 중요 annotation
7. **산출물 저장** — `outputs/YYYY-MM-DD/{slug}.html`

---

# 사용법

```bash
# 단일 iOS 프로토타입
~/.claude/skills/comad-app-prototype/scripts/build.sh ios <screens.json>

# 병치 프로토타입 (mobile + desktop)
~/.claude/skills/comad-app-prototype/scripts/build.sh combo <screens.json>

# click-test
~/.claude/skills/comad-app-prototype/scripts/verify-click-test.py <output.html>
```

## screens.json 예시

```json
{
  "title": "AI 팟캐스트 앱",
  "platform": "ios",
  "mode": "flow",
  "tabs": [
    { "name": "홈", "screen": "home.html", "annotations": [{"xy": [200, 300], "text": "추천 에피소드"}] },
    { "name": "재생", "screen": "player.html", "annotations": [] },
    { "name": "보관함", "screen": "library.html", "annotations": [] }
  ]
}
```

---

# 의존성

- **Node ≥ 18** + **npx playwright** (전역) — click-test 에만 필요
- 프레임 HTML 자체는 zero-deps (순수 CSS)

---

# 상태

- Phase 2D · Gate A/B/C/D PASS 조건부로 W3 착수 예정
- 현재 버전: **v0.1.0 stub** (SKILL.md 만. 프레임 컴포넌트 W3 착수 시 구현)
- huashu-design Personal-Use 라이선스 준수
