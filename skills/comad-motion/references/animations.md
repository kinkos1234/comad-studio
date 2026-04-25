# Stage + Sprite 애니메이션 엔진 스펙

> 시간축 기반 React 애니메이션 엔진의 설계 문서. `engine/animations.js` 의 구현 가이드.

## 설계 목표

1. **Pure render** — 임의의 시간 `t` 주면 유일한 DOM 상태 반환. seek/scrub 가능.
2. **선언적 컴포지션** — `<Stage>` 안에 `<Sprite>` 를 start/end 로 배치. setTimeout 체이닝 금지.
3. **녹화 친화** — `window.__ready` 자동 설정, chrome 엘리먼트 자동 숨김 훅 제공.
4. **경량** — React 18 + 외부 의존 없음. CDN 에서 `<script>` 로 inline 가능.

## 4가지 핵심 API

### 1. `<Stage duration={N}>`
전체 타임라인 컨테이너. 내부 상태로 `time` (seconds) 보관.
- Prop: `duration` (필수, 초 단위 숫자), `fps` (기본 60, 내부 업데이트 주기만. 녹화 fps 는 Playwright 설정 따름)
- 첫 `useEffect` 후 `requestAnimationFrame` 루프 시작, `document.fonts.ready` 가 끝나면 `window.__ready = true` 세팅
- Context 로 자식에게 `{ time, duration, playing }` 전달
- 재생 완료 시 `playing = false` → Sprite 들이 "최종 프레임" 에서 정지

### 2. `<Sprite start={s} end={e}>`
시간 구간 `[s, e]` 동안만 마운트되는 자식 컨테이너.
- Prop: `start` (시작 초), `end` (끝 초). 모두 Stage time 기준.
- 현재 `time < start` 또는 `time > end` 면 null 반환 (DOM 에서 제외)
- 자식에게 Context 로 `{ t: 0→1, elapsed: seconds, duration: e - s }` 전달

### 3. `useTime()`
Stage 의 현재 `time` (seconds) 반환. Sprite 밖에서도 호출 가능.

### 4. `useSprite()`
가장 가까운 `<Sprite>` 의 지역 진행률 반환. Sprite 밖에서 호출 시 `{ t: 0, elapsed: 0, duration: 0 }`.

### 5. `interpolate(t, [inStart, inEnd], [outStart, outEnd], easing?)`
- `t <= inStart` → `outStart`
- `t >= inEnd` → `outEnd`
- 그 사이 선형 보간 후 선택적 easing 적용
- easing 은 함수 (`(t) => t`) 를 받음

### 6. `Easing` (프리셋)

| 이름 | 함수 | 언제 쓰나 |
|---|---|---|
| `linear` | `t => t` | 기계적·산업적 · 진행바 |
| `easeIn` | `t => t * t` | 빠져나가는 요소 · 떠나가는 느낌 |
| `easeOut` | `t => 1 - (1-t)**2` | 들어오는 요소 (기본 선택) |
| `easeInOut` | 중간 대칭 | 카메라 이동 · 페이지 전환 |
| **`expoOut`** | `t === 1 ? 1 : 1 - 2**(-10t)` | **Anthropic 메인 easing.** 급가속 후 천천히 정지. 숫자·텍스트 요소에 물리적 무게감 부여. `cubic-bezier(0.16, 1, 0.3, 1)` 등가. |
| `overshoot` | c1=1.70158 기반 | 토글·버튼 팝업 · 탄성 바운스. `cubic-bezier(0.34, 1.56, 0.64, 1)` 등가. |
| `spring` | 지수감쇠 sine | 진동하며 정착 |
| `anticipation` | 역행 후 전진 | "가속 전 살짝 당김" · Disney 12원칙 |

## 사용 예

```jsx
const { Stage, Sprite, useSprite, interpolate, Easing } = window.comadAnim;

function Hero() {
  const { t } = useSprite();
  const opacity = interpolate(t, [0, 0.2], [0, 1], Easing.expoOut);
  const y = interpolate(t, [0, 0.4], [40, 0], Easing.expoOut);
  return <h1 style={{ opacity, transform: `translateY(${y}px)` }}>제목</h1>;
}

function App() {
  return (
    <Stage duration={10}>
      <Sprite start={0} end={3}><Hero /></Sprite>
      <Sprite start={2} end={6}><Body /></Sprite>
      <Sprite start={5} end={10}><Outro /></Sprite>
    </Stage>
  );
}
```

**크로스페이드 패턴** (Sprite 간 전환):
- `Sprite A` end=3, `Sprite B` start=2 — 1초 겹침
- A 내부 easeOut fade 0.4s, B 내부 easeIn fade 0.4s → 0.2s 완전겹침 구간에서 crossfade

## 녹화 친화 자동화

`<Stage>` 마운트 시 자동 수행:
- `document.fonts.ready.then(() => requestAnimationFrame(() => { window.__ready = true; }))` 세팅
- `addEventListener('keydown', ...)` 로 `r` 키 = 재생 재시작, `→/←` = 0.1초 seek, `Space` = pause/play (디버깅)
- `<style>` 태그 inject: `.no-record { display: none !important; }` (녹화 시 Playwright init-script 가 `.no-record` 붙여 chrome 제거)

## Sprite 내부 `t` 의 의미

`t: 0 → 1` 은 **Sprite 자체 수명 기준 진행률**. 즉 `start=2, end=5` 이면:
- Stage time 2초 → Sprite t = 0
- Stage time 3.5초 → Sprite t = 0.5
- Stage time 5초 → Sprite t = 1

이렇게 지역 진행률을 쓰면 Sprite 의 start/end 를 나중에 바꿔도 내부 애니메이션 로직은 그대로.

## 14 Pitfalls (별도 문서 `references/pitfalls.md` 에서 상술 예정)

- 부모 `position: relative` 누락
- 폰트 로드 전 `getBoundingClientRect`
- setTimeout 체이닝 (seek 불가)
- 희귀 Unicode 글리프 (⎇ ␣ ↩)
- JS 상수 N 과 CSS grid-template-columns 개수 불일치
- Scene 전환 cross-fade 공백 없음
- fps × duration 계산 오류
- `<Stage>` 밖에서 `useSprite()` 호출
- `scrollIntoView` 사용 (컨테이너 스크롤 파괴)
- `getComputedStyle` 반환값 파싱 오류 ("10px" 문자열)
- `requestAnimationFrame` 내부에 동기 heavy 연산
- React key 중복 → 재마운트 반복
- `transform: translateZ(0)` 없이 `filter: blur()` → 성능 저하
- Shadow DOM 바깥에서 내부 요소 측정 실패
