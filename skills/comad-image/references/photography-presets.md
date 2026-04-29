# Photography Presets — Modular Set Catalog

> **목적**: 카메라/렌즈/필름·그레이딩/라이팅을 단일 "박힌 셋"으로 쓰지 않고, **모듈형 프리셋**으로 분리해서 매 요청마다 적합한 1-3개를 자동 선택·조합한다.
>
> **출처**: `01-comad/photo_prompts_master_reference.md` (전공자급 키워드 사전 16 파트) + `01-comad/image-prompt-ref/` (1487 prompts) + GPT-Image 2.0 공식 가이드
>
> **사용처**: `comad-image` (필수) · `comad-motion` (씬별 룩) · `comad-pptx` (시트별 톤)
>
> **원칙**: GPT-Image 2.0 은 키워드 스태킹보다 **자연어 서술**이 정확하다 (`prompt-patterns.md §1-1`). 프리셋은 키워드 사전이 아니라 **자연어 문장 템플릿**이다.

---

## 1. 카메라·필름 베이스 셋 (CAM-01 ~ CAM-06)

### CAM-01 · ARRI Alexa Mini LF · 시네마 디지털
- **Body**: ARRI Alexa Mini LF, ARRI Log-C 4.5K open-gate
- **ISO**: EI 800 native, dual native ISO 1280
- **Shutter**: 1/48s (180° shutter angle at 24fps)
- **자연어**: *"shot on ARRI Alexa Mini LF in ARRI Log-C, EI 800 native, 1/48 second 180-degree shutter — the texture of a finished feature film still"*
- **어울리는 영역**: 인물 시네마틱, 영화 한 장면, 인디 필름, anamorphic scope
- **꺼리는 영역**: SNS 셀카, 광고 클린 컷, 인포그래픽

### CAM-02 · Hasselblad H6D-100c · 광고 중형 디지털
- **Body**: Hasselblad H6D-100c (또는 X2D 100C, Phase One XF IQ4 150MP)
- **ISO**: ISO 64-200 ultra clean
- **Shutter**: 1/250s flash sync
- **자연어**: *"shot on Hasselblad H6D-100c medium format digital, ISO 64 noiseless, leaf-shutter strobe sync — the surgical clarity of a luxury commercial campaign"*
- **어울리는 영역**: 패션 화보, 럭셔리 제품, 호스피탈리티 키비주얼, 광고 실사
- **꺼리는 영역**: 다큐, 거친 그레인 룩, 인디 필름

### CAM-03 · Leica M11 · 35mm 르포·스트리트
- **Body**: Leica M11 (또는 Leica Q3, Contax G2 필름 RF 도 호환)
- **ISO**: ISO 200-1600 working range
- **자연어**: *"shot on Leica M11 with rangefinder framing, ISO 800 working light — the unhurried observational rhythm of street and reportage photography"*
- **어울리는 영역**: 일상 다큐, 스트리트, 자연광 인물, 여행
- **꺼리는 영역**: 화려한 화보, 시네마 widescreen

### CAM-04 · Sony A7R V / Canon R5 · 모던 미러리스
- **Body**: Sony A7R V (또는 Canon R5, Nikon Z9)
- **ISO**: ISO 100-3200
- **자연어**: *"shot on Sony A7R V full-frame mirrorless, 60-megapixel detail, native color science — the everyday-pro look of contemporary commercial photography"*
- **어울리는 영역**: 제품, 인물, 일반 광고, 라이프스타일
- **꺼리는 영역**: 노스탤지어 룩, 아트하우스 영화

### CAM-05 · 35mm 필름 SLR + Vision3 500T · 인디 필름룩
- **Body**: Nikon F3 / Canon AE-1 / Pentax K1000 with **Kodak Vision3 500T** (또는 Cinestill 800T) **pushed +1 stop**
- **ISO**: EI 800 (push), visible fine grain
- **자연어**: *"35mm film negative scan, Kodak Vision3 500T pushed +1 stop, fine but visible grain in the shadows and clean midtones — the texture of a Korean independent feature film"*
- **어울리는 영역**: 노스탤지어 인물, 인디 영화 톤, 늦은 밤 실내, halation 풍부
- **꺼리는 영역**: 클린 광고, 깨끗한 제품 컷

### CAM-06 · Polaroid SX-70 / Contax T2 · 90s 패션 컴팩트
- **Body**: Polaroid SX-70 (즉석) / Contax T2 / Yashica T4 (90s 컴팩트)
- **자연어**: *"Polaroid SX-70 instant frame, soft mid-1970s color shift, slight vignetting, dreamlike imperfection — the warm imperfect intimacy of a personal snapshot"*
- **어울리는 영역**: 빈티지 무드, 패션 스냅, 일기적 친밀감
- **꺼리는 영역**: 시네마 와이드, 광고 정밀

---

## 2. 렌즈·광학 셋 (LENS-01 ~ LENS-06)

### LENS-01 · Cooke Anamorphic /i SF 50mm @ T2.0 · 시네마 anamorphic
- **자연어**: *"Cooke Anamorphic /i SF 50mm with 1.8x squeeze, opened to T2.0 — characteristic horizontal oval bokeh and anamorphic streak flare"*
- **호환 비율**: 2.39:1, 2.35:1, 2.76:1
- **어울리는 영역**: 시네마 widescreen, 인디 영화 톤
- **꺼리는 영역**: 정사각·세로

### LENS-02 · Sony GM 85mm f/1.4 · 패션 표준
- **자연어**: *"Sony GM 85mm f/1.4 portrait prime, creamy circular bokeh, gentle subject compression — the editorial fashion standard"*
- **호환 비율**: 4:5, 3:2, 1:1
- **어울리는 영역**: 패션, 인물 화보, 미디엄 클로즈업

### LENS-03 · Leica Summilux 35mm f/1.4 ASPH · 글로우 35mm
- **자연어**: *"Leica Summilux 35mm f/1.4 ASPH wide-open, gentle highlight glow, three-dimensional pop — the rangefinder reportage signature"*
- **어울리는 영역**: 르포, 환경 인물, 스트리트, 여행

### LENS-04 · Helios 44-2 58mm · 빈티지 swirly bokeh
- **자연어**: *"Helios 44-2 58mm vintage Soviet glass, swirly out-of-focus background, painterly imperfections, slight character vignette — dreamlike and slightly off-kilter"*
- **어울리는 영역**: 노스탤지어 인물, 회화적 무드, 일기

### LENS-05 · Canon RF 50mm f/1.2L · 영화적 표준
- **자연어**: *"Canon RF 50mm f/1.2L wide-open, razor-thin depth of field with creamy fall-off — the cinematic standard prime, eyes-as-anchor focus"*
- **어울리는 영역**: 인물 시네마틱 (anamorphic 아닐 때), 광고 인물

### LENS-06 · 100mm Macro 1:1 · 매크로
- **자연어**: *"100mm macro at 1:1 magnification, paper-thin focal plane, every micro-texture rendered — the surgical intimacy of a product macro"*
- **어울리는 영역**: 제품, 디테일 인서트, 음식, 보석

---

## 3. 필름·그레이딩 셋 (GRADE-01 ~ GRADE-06)

### GRADE-01 · Kodak Vision3 500T pushed +1 · 시네마 텅스텐
- **Halation**: 강함 (highlight 주변 따뜻한 후광)
- **Grain**: visible fine in shadows, clean midtones
- **자연어**: *"Kodak Vision3 500T tungsten cinema stock pushed +1 stop, gentle halation around bright highlights, fine grain pattern"*
- **어울리는 mood**: 야간 실내, 시네마틱, 노스탤지어 인디
- **호환 카메라셋**: CAM-01, CAM-05

### GRADE-02 · Kodak Portra 400 · 인물 표준
- **자연어**: *"Kodak Portra 400 color negative, soft natural Asian skin tones placed on Zone V, gentle low contrast, lifted shadows"*
- **어울리는 mood**: 일상 인물, 따뜻한 결혼식, 가족
- **호환 카메라셋**: CAM-03, CAM-05

### GRADE-03 · Fujifilm Velvia 50 · 극채도 풍경
- **자연어**: *"Fujifilm Velvia 50 slide film, hyper-saturated reds and greens, deep cyan skies, high micro-contrast — National Geographic 1990s landscape look"*
- **어울리는 mood**: 풍경, 자연, 여행 광고
- **꺼리는 영역**: 인물 (피부 너무 빨개짐)

### GRADE-04 · Teal & Orange · Hollywood 표준
- **자연어**: *"teal-and-orange Hollywood color grade, warm skin pushed toward orange, ambient pushed toward teal — the modern blockbuster split"*
- **주의**: 과하면 cliché. 8-15% 강도 권장

### GRADE-05 · Bleach Bypass · 표백 룩
- **자연어**: *"bleach bypass / silver retention process, desaturated muted colors, lifted blacks, milky highlights — the gritty Saving Private Ryan / Children of Men texture"*
- **어울리는 mood**: 다큐, 거친 드라마, 디스토피아

### GRADE-06 · Wong Kar-wai Warm Vintage · 90s 홍콩 인테리어
- **자연어**: *"warm vintage interior grade in the Wong Kar-wai lineage, amber-soaked highlights, deep emerald shadows, slight green cast in midtones — In the Mood for Love / Chungking Express palette"*
- **어울리는 mood**: 노스탤지어 인물, 야간 실내, 멜랑콜리

---

## 4. 라이팅 셋 (LIGHT-01 ~ LIGHT-06)

### LIGHT-01 · Low-key Chiaroscuro · 시네마 인물
- **자연어**: *"low-key chiaroscuro, single motivated practical key (warm tungsten desk lamp ~3000K) with deep negative fill on the opposite cheek, lighting ratio 4:1, short-side lighting verging on Rembrandt"*
- **어울리는 mood**: 시네마틱 인물, 사색, 늦은 밤

### LIGHT-02 · Soft Window Daylight · 페르메이르
- **자연어**: *"soft north-facing window daylight, single large diffuse source from camera-left, gentle wrap, clean fill from white wall — the painterly Vermeer interior light"*
- **어울리는 mood**: 일상 인물, 정물, 잡지 라이프스타일

### LIGHT-03 · Hard Direct Sun · Magnum 다큐
- **자연어**: *"harsh direct sunlight, hard contrasty shadows, no fill, sweat highlights — the unforgiving documentary light of Magnum street work"*
- **어울리는 mood**: 거친 다큐, 도시, 여름

### LIGHT-04 · Beauty Dish + Strip Backlight · 패션 화보
- **자연어**: *"22-inch beauty dish key from above (Hollywood/Paramount lighting, butterfly shadow under nose), twin strip lights as edge lights, white seamless background"*
- **어울리는 mood**: 패션 화보, 뷰티

### LIGHT-05 · Practical Neon Mix · Refn 네온누아르
- **자연어**: *"practical neon-only lighting, mixed magenta and cyan tubes, no key fill, deep blacks — the Drive / Only God Forgives Refn palette"*
- **어울리는 mood**: 노아르, 도시 야경 인물, 사이버

### LIGHT-06 · Golden Hour Backlight · 따뜻한 환경 인물
- **자연어**: *"golden hour low-angle backlight, warm rim around hair and shoulder, lens flare allowed, soft skin shadow — the late summer golden lifestyle look"*
- **어울리는 mood**: 라이프스타일, 광고, 여행

---

## 5. 컴포지션·필터 보조 모듈 (AUX)

자유롭게 쌓을 수 있는 보조 옵션:

- **AUX-DIFFUSION-PROMIST**: *"Tiffen Black Pro-Mist 1/4 in front of lens — gentle highlight bloom and softened micro-contrast, modern Korean indie cinema standard"*
- **AUX-DIFFUSION-GLIMMERGLASS**: *"Tiffen Glimmerglass diffusion — softer skin while preserving eye sharpness"*
- **AUX-FLARE-ANAMORPHIC**: *"single restrained anamorphic horizontal lens flare on the brightest highlight, never JJ-Abrams overload"*
- **AUX-GRAIN-OVERLAY**: *"fine 35mm film-grain overlay matched to the chosen stock, visible in shadows, clean in highlights"*
- **AUX-HALATION**: *"gentle halation overlay around the warmest highlights — the Cinestill 800T signature red bloom, restrained"*
- **AUX-SPLIT-TONE**: *"split-toning — warm amber-honey lift on key-lit highlights, desaturated teal-cyan in shadows"*
- **AUX-NEGFILL**: *"deep black flag / unlit dark wall on the shadow-side, no bounce, protected silhouette"*
- **AUX-VIGNETTE**: *"natural lens vignette, subtle corner darkening from wide-aperture optics"*
- **AUX-ATMOSPHERE-HAZE**: *"barest whisper of atmospheric haze, just enough to render the volumetric beam from the key, never theatrical fog"*
- **AUX-RULE-PHIGRID**: *"composition follows the golden ratio phi grid (1 : 0.618 : 1), subject anchored on left third, lead room on right two-thirds"*
- **AUX-SHORTSIDE-SPLIT**: *"short-side split lighting — camera-far cheek is the lit side, camera-near cheek falls into deep shadow"*

---

## 6. 호환·금기 매트릭스

| 카메라 | 호환 렌즈 | 호환 그레이딩 | 호환 라이팅 | 금기 |
|--------|-----------|---------------|-------------|------|
| CAM-01 (Alexa) | LENS-01, LENS-05, LENS-06 | GRADE-01, GRADE-04, GRADE-06 | LIGHT-01, LIGHT-05, LIGHT-06 | LIGHT-04 (광고 비율 안 맞음) |
| CAM-02 (Hasselblad) | LENS-02, LENS-05, LENS-06 | GRADE-02, GRADE-04 | LIGHT-04, LIGHT-02 | GRADE-05 (화보에 표백 안 어울림) |
| CAM-03 (Leica M11) | LENS-03 | GRADE-02, GRADE-05 | LIGHT-02, LIGHT-03 | LIGHT-04 (스튜디오 RF 부적합) |
| CAM-04 (Sony A7R V) | LENS-02, LENS-05 | GRADE-02, GRADE-04 | LIGHT-02, LIGHT-04, LIGHT-06 | — (범용) |
| CAM-05 (35mm 필름) | LENS-03, LENS-04 | GRADE-01, GRADE-02, GRADE-06 | LIGHT-01, LIGHT-02 | GRADE-04 (디지털 룩 충돌) |
| CAM-06 (Polaroid SX-70) | (built-in) | (built-in soft) | LIGHT-02, LIGHT-06 | GRADE-04, GRADE-05 (즉석 필름 후보정 부적합) |

**Cross-blend 가능**: 한 셋에 묶이지 않고 `CAM-01 + LENS-04 (Helios)` 같은 의도적 부조화로 빈티지 시네마 만들기 OK. 단 **호환표 위반 시엔 의도를 명시** ("의도적 cross-blend").

---

## 7. 자동 선택 결정 트리 (디렉터의 두뇌)

매 이미지 요청마다 아래 순서로 셋을 결정한다. **단일 셋 박지 말고 카메라/렌즈/그레이딩/라이팅을 각각 따로 고른다.**

### Step A — 사용자 요청에서 무드 키워드 추출

| 키워드 | 1차 후보 |
|--------|---------|
| "시네마틱", "영화", "시네마스코프", "Drive My Car", "Her" | CAM-01 or CAM-05 + LENS-01 + GRADE-01 + LIGHT-01 |
| "광고", "키비주얼", "럭셔리", "호스피탈리티" | CAM-02 + LENS-02 + GRADE-04(약) + LIGHT-04 or LIGHT-02 |
| "다큐", "스트리트", "르포", "여행" | CAM-03 + LENS-03 + GRADE-05 + LIGHT-03 |
| "패션", "에디토리얼", "화보" | CAM-02 + LENS-02 + GRADE-04(약) + LIGHT-04 |
| "노스탤지어", "90s", "빈티지", "필름룩" | CAM-05 + LENS-04 + GRADE-02 + LIGHT-02 |
| "왕가위", "홍콩 인테리어", "멜랑콜리" | CAM-05 + LENS-04 or LENS-03 + GRADE-06 + LIGHT-01 |
| "네온", "사이버", "야경 인물", "Refn" | CAM-01 + LENS-05 + GRADE-04(강) + LIGHT-05 |
| "라이프스타일", "골든아워", "여름" | CAM-04 + LENS-02 or LENS-03 + GRADE-04(약) + LIGHT-06 |
| "제품 매크로", "음식 디테일" | CAM-02 + LENS-06 + GRADE-04(약) + LIGHT-02 or LIGHT-04 |
| "폴라로이드", "일기", "스냅" | CAM-06 + (built-in) + (built-in) + LIGHT-02 or LIGHT-06 |

### Step B — 화면비 / 구도와 렌즈 일관성 체크

- 2.39:1 / 2.35:1 anamorphic scope → **반드시 LENS-01** (없으면 시네마틱이 깨짐)
- 4:5 / 3:2 표준 → LENS-02, LENS-03, LENS-05 자유 선택
- 1:1 정사각 → LENS-02, LENS-04 추천
- 9:16 세로 → LENS-03, LENS-05

### Step C — Cross-blend 검토 (의도적 부조화 1회 권장)

각 컷에서 **1개 정도는 호환표를 의도적으로 어겨** 클리셰를 깨라:
- 시네마 디지털(Alexa) + 빈티지 글래스(Helios) → 모던하지만 회화적
- 35mm 필름 + 모던 빛(beauty dish) → 빈티지 패션
- Hasselblad 광고 + bleach bypass → 럭셔리 다큐

단, **단순 충돌은 금지**. 의도가 설명 가능해야 한다.

### Step D — AUX 보조 모듈 1-3개 선택

핵심 4셋(CAM/LENS/GRADE/LIGHT) 위에 AUX 1-3개 얹기:
- 시네마틱 인물 → AUX-DIFFUSION-PROMIST + AUX-GRAIN-OVERLAY + AUX-SPLIT-TONE 거의 항상
- 광고 깨끗 → AUX-DIFFUSION 빼기, AUX-NEGFILL 만 유지
- 노스탤지어 → AUX-HALATION + AUX-VIGNETTE + AUX-GRAIN-OVERLAY

### Step E — 프롬프트 본문에 "선택된 조합" 명시

생성된 프롬프트 §1 (Camera, Lens & Exposure) 또는 JSON Args 헤더에 **이번 컷에 선택한 셋 ID 와 cross-blend 의도**를 명시한다. 후속 refine 요청 시 어떤 셋을 바꿀지 빠르게 판단 가능.

예:
```
selected_sets: CAM-01 (Alexa) + LENS-01 (Cooke Anamorphic) + GRADE-01 (Vision3 500T +1) + LIGHT-01 (Low-key Chiaroscuro)
aux: AUX-DIFFUSION-PROMIST, AUX-FLARE-ANAMORPHIC, AUX-GRAIN-OVERLAY, AUX-SPLIT-TONE, AUX-NEGFILL
cross_blend: none (canonical Korean indie cinema combo)
```

---

## 8. 사용자 명시 override

사용자가 "Hasselblad 로 찍어줘", "Helios 빈티지 보케", "필름 그레인 빼줘" 식으로 직접 셋을 지정하면 결정 트리를 무시하고 사용자 지정을 우선한다. Decision tree 는 **자동 모드의 디폴트 디렉팅**일 뿐, 사용자 권한이 항상 위.

---

## 9. 이 카탈로그의 진화 룰

- 새 셋 추가는 자유. 단 6 호환 매트릭스에 한 줄 등록.
- 같은 ID 재사용 금지 (CAM-01 은 영구히 Alexa Mini LF).
- 셋 자체는 **자연어 문장**으로 작성. 키워드 나열 금지 (`prompt-patterns.md §1-1`).
