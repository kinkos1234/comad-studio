# Imagery · 영상용 이미지 생성 가이드

> comad-motion 이 씬별 이미지가 필요할 때 `comad-image` 를 호출하는 통합 가이드.
> 저장 위치: 프로젝트 `assets/generated/<slug>-NN.png`
>
> **필수 선행 참조** (2026-04-25 추가): `~/.claude/skills/comad-image/references/prompt-patterns.md`
> - §6 스타일 DNA 6종 (에디토리얼·시네마틱매크로·정보밀도·업무만화·한국럭셔리·미니멀한지) 중 1개 고정
> - §5 한국 감성 키워드 1-2개 모든 프레임에 반복 삽입
> - §1-3 종횡비 (영상 프레임은 16:9 고정)

## 핵심 원칙

### 1. 씬마다 이미지가 필요한지 먼저 판단

모든 씬이 이미지 필요한 것 아니다. **이미지를 추가해야 하는 씬**:
- Hero / Opening — 감정 톤 확립
- 개념적 전환 — 말로 설명하기 어려운 추상
- Climax / Key moment — 시각 임팩트
- Brand / product shot — 로고/제품

**이미지가 방해되는 씬**:
- 순수 타이포그래피 강조 (large numeric reveal 등)
- 데이터 시각화 (차트 자체가 이미지)
- 코드/텍스트 중심 스크린

경험칙: **6 씬 영상에 2-3 장 이미지 적정**. 모든 씬에 이미지 넣으면 정보 과부하.

### 2. 스타일 DNA 고정 (가장 중요)

6 이미지가 서로 다른 스타일로 나오면 영상 품질 붕괴. **모든 이미지 프롬프트에 공통 DNA 문장 삽입** 필수.

**스타일 DNA 템플릿**:
```
Style DNA (apply consistently to all frames):
- Mood: {mood keyword 1-2개}
- Palette: {3가지 색 + bg tone}
- Texture: {grain/finish}
- Lighting: {light quality}
- Composition: {camera distance / angle 룰}
- Technical: 16:9 landscape, no text, no people (or: portrait/group if project needs)
```

**예시 DNA (cinematic minimalist warm)**:
```
Style DNA:
- Mood: contemplative, editorial
- Palette: deep charcoal (#1a1a1a) base, soft terracotta accent, dusty cream highlights
- Texture: 16mm film grain, slight matte
- Lighting: soft natural, out-of-focus light spheres in upper third
- Composition: shallow depth of field, asymmetric balance
- Technical: 16:9 landscape, 1920x1080, no text, no people
```

프로젝트별로 `.comad/motion-style.md` 에 DNA 저장해두면 영상 여러 편에서 재사용 가능.

### 3. Scene 당 프롬프트 구조

```
[Style DNA block - 공통 붙여넣기]

Scene intent: {한 문장으로 이 씬이 말하려는 것}

Visual subject: {구체 묘사 — 어떤 오브젝트/공간/질감}

Avoid:
- {프로젝트 내 다른 씬과 겹치면 안 되는 요소}
- {AI slop 패턴 — 보라그라디언트/이모지 등}
```

### 4. 병렬 생성 전략

6 씬에 각 1장 → **병렬로 codex exec** 호출하면 총 ~60초 (1장씩 ~30초). 순차로는 3분+.

하지만 codex exec 세션 간 충돌 가능성 있어 실험 필요. 안전 옵션: 순차 (3분), 빠른 옵션: 병렬 (60초 · 충돌 리스크).

### 5. 5-10-2-8 품질 게이트 (huashu-design 차용)

중요 씬 (Hero / Logo) 은 **2-3 후보 생성 후 best 선택**:
- 프롬프트는 동일, 각 후보를 `{slug}-01.png`, `{slug}-02.png`, `{slug}-03.png` 로 저장
- 나란히 view 후 best 선정
- 나머지는 `_rejected/` 폴더로 이동 (comad-learn 이 패턴 학습 가능)

장식 씬 (배경/과도기) 은 1장으로 충분.

### 6. HTML Sprite 안에 이미지 embed 방법

**`<img>` 직접 로드** (권장):
```jsx
function SceneWithBg() {
  const { t } = useSprite();
  const opacity = fader(t, 0.2, 0.85);
  const scale   = interpolate(t, [0, 1], [1.06, 1.00], Easing.easeOut);  // slow zoom out (Ken Burns)
  return (
    <div className="stage" style={{ opacity }}>
      <img
        src="file:///abs/path/to/assets/generated/scene-01.png"
        style={{
          position: 'absolute', inset: 0,
          width: '100%', height: '100%',
          objectFit: 'cover',
          transform: `scale(${scale})`,
          filter: 'brightness(0.9)',
        }}
      />
      {/* 텍스트 레이어 위에 */}
      <div className="center overlay">...</div>
    </div>
  );
}
```

**Ken Burns 효과**: 배경 이미지를 scale 1.06 → 1.00 으로 천천히 이동 + opacity fade → **정지 이미지가 "살아있는" 느낌**.

**주의**:
- `file://` 절대 경로 사용 (Playwright file-URL 환경)
- `objectFit: 'cover'` 로 비율 자동 조정
- `filter: 'brightness(0.9)'` 으로 텍스트 가독성 확보
- 텍스트 레이어는 `position: absolute; z-index: 2` 로 이미지 위에

### 7. 이미지 + 텍스트 대비 확보

흰 텍스트를 그냥 이미지 위에 얹으면 대비 부족. 3 방법:

1. **그라디언트 오버레이**: 이미지 위에 `linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0))` 레이어
2. **Vignette**: `radial-gradient(ellipse at center, transparent 30%, rgba(0,0,0,0.4) 70%)`
3. **텍스트 영역만 blur**: 이미지 사본에 blur(20px) 입혀서 텍스트 뒤쪽에만 배치

### 8. comad-image 호출 예시

영상 제작 워크플로우 내에서:

```bash
# 스타일 DNA 파일 로드
STYLE=$(cat .comad/motion-style.md)

# 씬별 프롬프트 파일 생성
cat > /tmp/prompt-scene01.md <<EOF
/imagen $STYLE

Scene 1 (Hero): wide horizon at dawn, single figure silhouette observing,
deep contemplation mood, empty space dominant.

Save to {TARGET_PATH} direct copy no post-processing, verify sha1.
EOF

# imagen.sh 호출
bash ~/.claude/skills/comad-image/scripts/imagen.sh \
  /tmp/prompt-scene01.md \
  $PWD/assets/generated/scene-01.png
```

## 피해야 할 것 (반복 실패 패턴)

- ❌ 각 씬 프롬프트 독립 작성 (DNA 없이) → 스타일 불일치
- ❌ AI 기본 톤 ("minimalist modern design") → 차별화 없는 일반 이미지
- ❌ 텍스트를 이미지에 포함 시도 (LLM 이미지 모델은 텍스트 못 그림)
- ❌ 사람 얼굴 극단 클로즈업 (AI 얼굴 왜곡 위험)
- ❌ 정해진 로고 재현 (잘못 그리면 품질 폭락) — 실제 로고 파일은 별도 embed

## 권장 워크플로우 (comad-motion 통합)

1. **Storyboard 우선** — 씬 목록 + 각 씬 intent + 이미지 필요성 판정
2. **Style DNA 확정** — 프로젝트 `.comad/motion-style.md` 생성 (혹은 기존 것 재사용)
3. **이미지 생성** — 필요 씬만 comad-image 호출 (병렬 또는 순차)
4. **선정** — 중요 씬은 5-10-2-8 적용, 나머지는 1장으로
5. **HTML 작성** — `<img src="file://...">` embed + Sprite fade + Ken Burns + 오버레이
6. **렌더** — render-video.js (평소대로)
7. **오디오 믹싱** — add-music.sh

이미지 통합은 영상 품질의 **창의성 차원을 8-9점 대로 끌어올리는** 핵심 레버리지.
