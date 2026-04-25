# 14 Animation Pitfalls · 피해야 할 패턴

> 실제 실패 사례 기반. 각 규칙 위반 시 1-3 라운드 재작업.

## 1. `position: absolute` 자식 있는 부모는 `position: relative` 명시

**실패**: sentence-wrap 안에 bracket-layer (absolute) 3개. sentence-wrap 에 relative 없어 `.canvas` 를 기준으로 떠서 화면 밖 200px 로 날아감.

**규칙**: absolute 자식을 품은 **모든 부모**에 `position: relative`. 시각 이동이 필요 없어도 좌표계 앵커로 명시.

## 2. 희귀 Unicode 글리프 금지

**실패**: `␣` (U+2423 OPEN BOX) 로 공백 시각화. Noto Serif SC / Cormorant 에 이 글리프 없어 빈 네모.

**규칙**: 모든 문자가 선택한 폰트에 존재하는지 확인. 메타 문자 (공백/엔터/탭) 는 CSS 박스로 만들어라.

## 3. 데이터 주도 Grid 템플릿 동기화

**실패**: JS 상수 `N = 6` 과 CSS `grid-template-columns: 80px repeat(5, 1fr)` 불일치. 6번째 토큰 컬럼 없어 레이아웃 와해.

**규칙**: 개수가 JS 배열에서 온다면 CSS 템플릿도 데이터 주도.
```css
el.style.setProperty('--cols', N);
.grid { grid-template-columns: 80px repeat(var(--cols), 1fr); }
```

## 4. Scene 전환 공백 제거 (크로스페이드)

**실패**: zoom1 out (0.6s) → zoom2 in (0.6s) 사이 stagger 0.2s 에서 1초 공백. 관객 "멈췄나" 오인.

**규칙**: 전 scene fade out 과 다음 scene fade in 을 **겹치게**. 1초 crossfade 기본.

## 5. Pure Render 원칙 — 애니메이션은 seek 가능

**실패**: `setTimeout` 체인으로 상태 전환. 녹화 중 seek 불가. 이미 실행된 setTimeout 은 "과거로 돌아갈" 수 없음.

**규칙**: `render(t)` 는 pure function. 주어진 t 에 대해 유일한 DOM 상태. 부득이 부작용 쓰면 `fired` Set + `reset()` 페어. `window.__seek(t)` 노출.

## 6. 폰트 로드 전 측정 금지

**실패**: DOMContentLoaded 시점에 `getBoundingClientRect`. 폴백 폰트 너비로 측정되어 bracket 위치 영구 오프셋.

**규칙**: 모든 측정은 `document.fonts.ready.then(...)` 안에서. 추가 `requestAnimationFrame` 1회로 layout commit 대기.

## 7. 녹화 준비 — `window.__ready` 신호

**실패**: Playwright recordVideo 는 context 생성 시점부터 녹화. 페이지/폰트 로드 2초가 녹화됨. 영상 앞 2초 까만 화면.

**규칙**: 첫 paint 직후 `window.__ready = true`. `render-video.js` 가 이 시점을 t=0 기준으로 trim. Stage 컴포넌트가 자동 수행.

## 8. 화면 내 가짜 chrome 금지

**실패**: 화면 안에 "진행바 / 타임코드 / 저작권 레이블" 직접 그리면 녹화된 영상에 실제 chrome 과 겹쳐 이중 표시.

**규칙**: 화면 내에 chrome 류 UI 그리지 말 것. 꼭 필요하면 `.no-record` 클래스 → Playwright init-script 가 숨김.

## 9. Babel-standalone 성능 함정

**실패**: 30초 영상에 Babel 인라인 변환을 매 프레임. CPU 100%, 드롭프레임.

**규칙**: production 빌드 때는 사전 컴파일. 또는 `@babel/standalone` 결과를 첫 1회만 실행.

## 10. React key 중복

**실패**: 동적 리스트에 `key={index}` 쓰면 요소 재순서 시 재마운트. 애니메이션 중 DOM 리플로우.

**규칙**: 불변 고유 id 사용 (`id: nanoid()` 등).

## 11. scrollIntoView 사용 금지

**실패**: 내부 focus 이동에 `scrollIntoView`. 바깥 컨테이너 스크롤까지 건드려 레이아웃 파손.

**규칙**: 수동 `element.scrollTop = ...` 또는 `transform: translateY()`.

## 12. `getComputedStyle` 문자열 파싱 오류

**실패**: `parseInt(style.paddingLeft)` 로 `"10px"` 는 10 나오지만 `"1.5em"` 는 1. 단위 가정 위험.

**규칙**: `getBoundingClientRect` 로 픽셀 단위 가져오기. `getComputedStyle` 은 참조만.

## 13. rAF 내부 동기 heavy 연산

**실패**: requestAnimationFrame 콜백 안에 JSON.parse / 대용량 배열 연산. 프레임 드롭.

**규칙**: rAF 콜백은 읽기 + DOM 쓰기만. 계산은 외부 워커 또는 사전 캐시.

## 14. filter: blur() 성능 저하

**실패**: `filter: blur(20px)` 를 Stage 전체에 적용. 60fps 못 씀.

**규칙**: `transform: translateZ(0)` 로 레이어 승격 or `backdrop-filter` 만 작은 영역에. blur 는 특별한 목적에만.

## 체크리스트

애니메이션 작성 시 순서대로:
- [ ] 1. absolute 자식 → 부모 relative 명시
- [ ] 6. 측정 로직은 fonts.ready 안
- [ ] 7. Stage 에서 __ready 자동 설정 (엔진이 함)
- [ ] 5. setTimeout 체인 금지 · render(t) pure
- [ ] 4. scene 전환 crossfade 겹침
- [ ] 8. 화면 내 chrome 없거나 `.no-record`
- [ ] 2. 사용 글리프 폰트 커버리지 확인
- [ ] 3. JS N 과 CSS cols 일치
