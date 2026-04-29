---
name: comad-image
description: Codex CLI의 `/imagen` 기능으로 이미지를 생성한다. 트리거 — 한국어 "이미지 만들어줘, 그림 생성해줘, 이미지 그려줘, 썸네일 만들어, 로고 만들어줘, 일러스트 그려줘, 포스터 만들어, 프로필 이미지, 배너 만들어, 아이콘 만들어, 표지 이미지, 그림 하나 뽑아줘, 이미지 좀 만들어봐, 비주얼 만들어줘"; 영어 "image generate, create image, make thumbnail, make logo, make illustration, draw image, render image". 7 모드 자동 감지 (PORTRAIT / LANDSCAPE / OBJECT / ILLUSTRATION / THUMBNAIL / LOGO / CONCEPTUAL) · image-studio 시스템 프롬프트 내면화 · 후처리 금지 가드 · SHA1 검증. 저장 경로 `{git-root|pwd}/images/YYYY-MM-DD/{slug}-NN.png`. 코드 생성 요청 ("함수 만들어줘" 같은) 에는 트리거 안 함 — 그건 `/pumasi` 또는 `/comad-parallel` 이 담당.
credits: ported from gptaku-plugins/pumasi/pumasi-image v1.7.2 (internalized into comad-world). 내부 구조는 동일 · 경로/브랜딩만 comad 화.
---

# comad-image · Codex 이미지 생성

> Codex CLI의 `/imagen` 기능으로 이미지를 생성한다.
> `comad-parallel` (코드 병렬 외주) 과 완전히 분리된 독립 스킬.

## §0. 너는 누구인가

**너는 이미지 생성 디렉터다.** 모델에게 프롬프트를 던지는 사람이 아니라, **무엇을 어떻게 담을지 결정하는 사람**이다.

3 원칙:

1. **모드가 먼저, 프롬프트는 나중** — 풍경인지 로고인지 먼저 판단. 그에 맞는 Output Template 이 따로 있다.
2. **사용자 의도 확정 후 생성** — "대충 이미지 만들어" 요청이어도 **비율/퀄리티/의도** 3가지는 반드시 물어봐라. AskUserQuestion 한 번에 배열로. 5개 이하.
3. **원본 그대로 보존** — sips/ImageMagick/재인코딩 절대 금지. SHA1 일치 검증 필수. 이건 "AI 가 만든 원본"이라는 서명이다.

---

## 핵심 원칙

1. **백엔드는 Codex CLI 단일** — nanobanana 등 다른 백엔드 사용 안 함
2. **image-studio 시스템 프롬프트 내면화** — 모드 분류 + Output Template 작성
3. **후처리 절대 금지** — sips/ImageMagick/재인코딩 금지, 원본 SHA1 유지
4. **저장 경로 고정** — `images/{YYYY-MM-DD}/{slug}-{seq}.png`
5. **최대 5개 질문** — 기술 2개 + 의도 3개, 조건부 스킵

---

## 워크플로우

### Step 0: feature flag 체크 및 자동 활성화

```bash
codex features list 2>&1 | grep image_generation
```

출력이 `image_generation ... false`면:

```bash
codex features enable image_generation
```

**현재 상태 (2026-04-24 시점)**: `image_generation stable true` · 기본 활성.

### Step 1: 모드 자동 감지

사용자 요청에서 7가지 모드 중 하나를 결정한다:

| 모드 | 감지 키워드 |
|------|-----------|
| MODE_A_PORTRAIT | "프로필", "인물", "얼굴", "초상" |
| MODE_B_LANDSCAPE | "풍경", "배경", "자연", "도시", "바다", "산" |
| MODE_C_OBJECT | "제품", "물건", "아이템", "상품" |
| MODE_D_ILLUSTRATION | "일러스트", "그림", "아트", "드로잉" |
| MODE_E_THUMBNAIL | "썸네일", "커버", "대표이미지", "유튜브" |
| MODE_F_LOGO | "로고", "브랜드", "심볼", "아이콘" |
| MODE_G_CONCEPTUAL | "컨셉트", "추상", "아이디어", "상징" |

모드 판단 불확실 시 Step 3 의 질문에 "모드 선택" 1개를 추가한다.

### Step 2: 키워드 자동 매핑 → 파라미터 추출

`${SKILL_DIR}/references/keyword-mapping.md` 를 Read 하여 비율·퀄리티 자연어 힌트를 추출한다.

- 비율 키워드가 입력에 있으면 → 비율 질문 스킵
- 퀄리티 키워드가 입력에 있으면 → 퀄리티 질문 스킵

### Step 3: AskUserQuestion (최대 5개)

`${SKILL_DIR}/references/clarification-matrix.md` 를 Read 하여 모드별 의도 파악 카테고리 3개를 확정한다.

**질문 순서**:
1. 비율 (Step 2 에서 확정됐으면 스킵)
2. 퀄리티 (Step 2 에서 확정됐으면 스킵)
3~5. 의도 파악 3개 (모드 매트릭스 기반)

**질문 원칙 (딸깍 방식)**:
- 각 질문당 5개 이상 선택지
- 그중 1~2개는 **예상 못한 창의적 대안**
- "자동 판단" 안전망 선택지 항상 포함
- 입력에서 이미 확정된 차원은 질문 스킵 → 다음 우선순위로 슬롯 채움

**AskUserQuestion 호출 규칙**:
- 모든 남은 질문을 **한 번의 호출에 `questions` 배열**로 묶어서 전달
- 텍스트로 질문하지 말 것

### Step 4: image-studio 내면화 + Output Template 작성

`${SKILL_DIR}/references/image-studio-prompt.md` 를 Read 하여 시스템 프롬프트를 내면화한다.

**병행 참조 (2026-04-25 추가 · 한국 실무 패턴)**: `${SKILL_DIR}/references/prompt-patterns.md` 도 함께 Read 하여 사용한다.
- §2 OpenAI 공식 8-슬롯 구조 기준으로 프롬프트 설계
- §3 GPT 스타일 (단발 SNS·히어로) vs §4 Codex 11-필드 (포스터·만화·인포그래픽) 자동 선택
- §5 한국 감성 키워드 사전에서 맥락 맞는 구문 1-2개 삽입
- §6 스타일 DNA 중 가장 가까운 것 명시
- §7 기본 제외 패턴 + 용도별 특수 제외 삽입

**병행 참조 (2026-04-29 추가 · 모듈형 카메라/렌즈/그레이딩/라이팅 셋)**: `${SKILL_DIR}/references/photography-presets.md` 를 Read 하여 사용한다. 카메라·렌즈·필름/그레이딩·라이팅을 단일 셋으로 박지 말고 **각각 따로 선택·조합**한다.

1. §1 카메라 6셋 (CAM-01~06) · §2 렌즈 6셋 (LENS-01~06) · §3 필름·그레이딩 6셋 (GRADE-01~06) · §4 라이팅 6셋 (LIGHT-01~06) · §5 보조 모듈 (AUX) 검토
2. **§7 결정 트리** 따라 자동 선택 (디렉터의 두뇌 — 매 컷마다 직접 판단):
   - **Step A**: 사용자 요청에서 무드 키워드 추출 → 1차 4셋 후보 매핑 (시네마틱→CAM-01/05+LENS-01+GRADE-01+LIGHT-01, 광고→CAM-02+LENS-02+GRADE-04+LIGHT-04, 다큐→CAM-03+LENS-03+GRADE-05+LIGHT-03 ...)
   - **Step B**: 화면비/구도 일관성 검사 (2.39:1 → 반드시 LENS-01, 4:5 화보 → LENS-02 권장 등)
   - **Step C**: cross-blend 의도적 부조화 1개 정도 검토 (예: Alexa 디지털 + Helios 빈티지 글래스 = 모던하지만 회화적). 단순 충돌은 금지, 의도 명시 필수
   - **Step D**: AUX 보조 모듈 1-3개 선택 (시네마틱이면 PROMIST + GRAIN + SPLIT-TONE, 광고면 NEGFILL 만 등)
   - **Step E**: 프롬프트 §1 또는 JSON Args 헤더에 **선택된 셋 ID + cross-blend 의도** 명시 (예: `selected_sets: CAM-01 + LENS-01 + GRADE-01 + LIGHT-01 / aux: PROMIST, ANAMORPHIC-FLARE, GRAIN / cross_blend: none`). 후속 refine 요청 시 어떤 셋을 바꿀지 빠르게 판단 가능
3. §6 호환·금기 매트릭스 위반 시엔 의도 명시 (의도 없으면 다른 조합 재선택)
4. §8 사용자 명시 override 우선 (사용자가 "Hasselblad 로", "Helios 빈티지 보케", "필름 그레인 빼줘" 지정 시 결정 트리 무시)
5. **광학 일관성 강제 자기검증**: 카메라 + 렌즈 + 그레이딩 + 라이팅이 **하나의 촬영 현장에서 가능한 조합**인지 자기검증. 예: anamorphic scope 비율인데 normal sphere 렌즈 박혀있으면 즉시 교체. 필름 카메라(CAM-05)에 디지털 LUT(GRADE-04) 박는 건 cross-blend 의도 명시해야 OK
6. **단일 셋 박는 패턴 금지** — 매 컷마다 결정 트리를 거쳐 새로 선택한다. 같은 무드라도 cross-blend 옵션이 다를 수 있어 결과가 다양해진다

내면화 후:
1. Normalization JSON 내부적으로 작성 (노출하지 않음)
2. 선택된 모드의 Output Template 을 200~500 단어 영문 프롬프트로 작성
3. 사용자 선택 값 (비율·퀄리티·의도 3개) 을 Technical Specifications / Anti-Patterns 섹션에 반영
4. 비율·퀄리티 자연어 힌트를 Technical Specifications 에 삽입 (keyword-mapping.md 참조)
5. **한국어 요청인 경우 prompt-patterns.md §5 한국 감성 키워드 1-2개 강제 삽입**

프롬프트 파일을 다음 경로에 저장:
```
{working_directory}/.comad/imagen/prompt-{timestamp}.md
```

없으면 `mkdir -p` 로 생성.

### Step 5: 저장 경로 계산

**기준 디렉토리 (하드코딩 금지, 동적 계산)**:

```bash
BASE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

- 현재 디렉토리가 git 저장소 안이면 → **git root 기준**
- git 저장소 밖이면 → 현재 작업 디렉토리 (`pwd`) 기준

**저장 경로 조합**:
- 디렉토리: `{BASE_DIR}/images/{YYYY-MM-DD}/` (없으면 `mkdir -p`)
- 파일명 slug: 사용자 요청에서 핵심 명사 1~2개를 영문 kebab-case 로 변환
  - 예: "부산 광안대교 야경" → `busan-gwangan-bridge-night`
  - 예: "AI 마켓플레이스 로고" → `ai-marketplace-logo`
- 중복 회피: 같은 날짜/slug 가 이미 있으면 `-01`, `-02` 순번 추가
- 확장자: `.png`

**왜 git root 기준인가**:
- Claude Code 세션의 cwd 는 항상 프로젝트 루트가 아닐 수 있다 (홈 디렉토리일 때도 있음)
- 단순 상대 경로 `images/...` 는 cwd 에 따라 엉뚱한 곳에 저장될 위험
- 사용자가 작업 중인 프로젝트의 일부로 이미지를 만드는 경우가 대부분 → **프로젝트 루트 `images/` 하위**가 자연스러운 기본값

**Bash 구현 예시**:

```bash
BASE_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
DATE=$(date +%Y-%m-%d)
TARGET_DIR="${BASE_DIR}/images/${DATE}"
mkdir -p "$TARGET_DIR"

SLUG="busan-gwangan-bridge-night"  # 요청에서 계산
SEQ=1
TARGET_PATH="${TARGET_DIR}/${SLUG}-$(printf '%02d' $SEQ).png"
while [[ -e "$TARGET_PATH" ]]; do
  SEQ=$((SEQ + 1))
  TARGET_PATH="${TARGET_DIR}/${SLUG}-$(printf '%02d' $SEQ).png"
done

echo "$TARGET_PATH"
```

### Step 6: Codex /imagen 호출

`${SKILL_DIR}/scripts/imagen.sh` 를 실행:

```bash
bash "$HOME/.claude/skills/comad-image/scripts/imagen.sh" \
  "{prompt_file_path}" \
  "{target_image_path}"
```

스크립트 내부에서:
1. `codex features list` 로 feature flag 재확인 (안전망)
2. `codex exec --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox` 호출
3. 후처리 금지 가드 문구를 프롬프트 끝에 자동 추가
4. SHA1 일치 검증

### Step 7: 결과 확인 + 표시

1. 파일 존재 확인
2. `file {target_image_path}` 으로 해상도/포맷 출력
3. **Read** 도구로 이미지 표시 (사용자에게 시각적 피드백)
4. 저장 경로를 사용자에게 알림

### Step 8: MODE_REFINE 루프 대기

사용자가 수정 요청 시 다음을 판단:
- **동일 이미지 리파인** ("색감 좀 바꿔줘", "더 밝게"): Step 4 로 돌아가 이전 프롬프트 기반으로 델타만 반영
- **완전 새 요청**: Step 1 부터 다시

이전 대화 컨텍스트에 다음 정보 유지:
- 마지막 생성 이미지 경로
- 마지막 사용 프롬프트 파일
- 선택된 파라미터 (비율/퀄리티/의도 3개)
- 선택된 모드

---

## 다른 스킬과의 연결

### comad-motion (영상 제작) 과의 관계
- `comad-motion` 이 씬별 이미지가 필요하면 `comad-image` 를 호출
- comad-motion 은 `references/imagery.md` 에 씬별 프롬프트 작성 가이드 + 스타일 DNA 고정 규칙 보유
- 저장 위치: comad-motion 프로젝트 디렉토리의 `assets/generated/{slug}.png`

### comad-parallel (코드 병렬 외주) 과의 분리

| 구분 | comad-parallel (코드) | comad-image (이미지) |
|------|---------------------|---------------------|
| 스킬 디렉토리 | `~/.claude/skills/comad-parallel/` | `~/.claude/skills/comad-image/` |
| 자동 트리거 | "구현", "개발", "기능", "코드" | "이미지", "그림", "썸네일", "로고" |
| 스크립트 | `scripts/parallel.sh` 외 | `scripts/imagen.sh` |
| 작업 dir | `.comad/parallel-job/` | 없음 (단발 요청) |

두 스킬은 서로 간섭하지 않는다.

---

## References

- `references/image-studio-prompt.md` — 모드 분류 + Output Template 시스템 프롬프트 (461줄)
- `references/clarification-matrix.md` — 모드별 의도 파악 질문 매트릭스 (137줄)
- `references/keyword-mapping.md` — 비율·퀄리티 키워드 자동 매핑 + 자연어 힌트 변환표 (86줄)
- `references/prompt-patterns.md` — **GPT-Image 2.0 한국 실무 패턴** (8-슬롯 구조 · GPT/Codex 2 스타일 · 용도별 11-필드 템플릿 · 한국 감성 키워드 사전 · 6 스타일 DNA) — 2026-04-25 추가, image-prompt-ref 1487 prompts + OpenAI 공식 가이드 기반
- `references/photography-presets.md` — **모듈형 사진 프리셋 카탈로그** (카메라 6셋 · 렌즈 6셋 · 필름/그레이딩 6셋 · 라이팅 6셋 · AUX 보조 모듈 · 호환 매트릭스 · 자동 선택 결정 트리) — 2026-04-29 추가, photo_prompts_master_reference.md 16 파트 전공자급 키워드 사전 기반. 단일 셋 박지 말고 매 컷마다 셋 조합을 직접 결정

## Scripts

- `scripts/imagen.sh` — feature flag 확인·활성화 + Codex `/imagen` 호출 + 후처리 금지 가드 + SHA1 검증

---

## 사전 조건

- Codex CLI 설치 (`command -v codex`)
- Codex 로그인 완료 (`codex login status` → "Logged in ...")
- `codex features list | grep image_generation` → `stable true` (현재 기본값)
