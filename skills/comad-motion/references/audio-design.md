# Audio Design · SFX + BGM 듀얼 트랙 규칙

> 영상 오디오 설계 가이드. `scripts/add-music.sh` 의 파라미터 근거 문서.

## 철칙 · 듀얼 트랙

영상 오디오는 **두 층 독립 설계** 필수. 한 층만 하면 반쪽.

| 층 | 역할 | 시간 스케일 | 시각 동기 | 주파수 점유 |
|---|---|---|---|---|
| **SFX (비트 층)** | 시각 beat 마킹 | 0.2–2초 짧음 | **프레임 단위 강동기** | **고역 800Hz+** |
| **BGM (분위기 바닥)** | 정서 깔기 · 사운드스케이프 | 연속 20-60초 | 약동기 (섹션 단위) | **중저역 <4kHz** |

> "BGM 만 있는 영상 = 관객이 '그림은 움직이는데 소리 반응이 없다' 고 무의식 감지 → 싸구려 느낌의 근원." 반드시 SFX 도 붙여야 한다.

## 볼륨 · 황금 비율

| 파라미터 | 값 | 이유 |
|---|---|---|
| BGM 음량 | `0.40` ~ `0.50` | 1.0 만점 기준 |
| SFX 음량 | `1.00` | 기준 |
| 응량차 | BGM 이 SFX peak 보다 **-6 ~ -8 dB 낮게** | 절대 음량이 아니라 **차이**로 SFX 를 두드러지게 |
| amix normalize | `0` | **절대 1 쓰지 말 것**. 다이내믹 레인지 평탄화됨 |

## 주파수 분리 (핵심 비법)

SFX 를 BGM 위에 뚜렷이 올리는 열쇠는 음량이 아니라 **주파수 분리**.

```bash
[bgm_raw]lowpass=f=4000[bgm]        # BGM 은 <4kHz 로 제한 (중저역)
[sfx_raw]highpass=f=800[sfx]        # SFX 는 800Hz+ 로 밀어올림 (중고역)
[bgm][sfx]amix=inputs=2:duration=first:normalize=0[a]
```

**왜 효과적인가**: 인간 귀는 2-5kHz (presence 대역) 에 가장 민감. SFX 가 이 대역에 있는데 BGM 도 전 주파수 깔리면 **SFX 가 BGM 고역에 묻힘**. highpass 로 SFX 를 위로 / lowpass 로 BGM 을 아래로 → 스펙트럼에서 각자 영역 확보 → SFX 선명도 급상승.

## Fade

| 위치 | 공식 |
|---|---|
| BGM 입 | `afade=in:st=0:d=0.3` (0.3초 · 하드컷 방지) |
| BGM 출 | `afade=out:st=N-1.5:d=1.5` (N = 영상 길이. 1.5초 긴 꼬리로 수렴감) |
| SFX | envelope 가 파일 자체에 있음 → 추가 fade 불필요 |

## SFX Cue 밀도

실측 데이터 기준 3 단계:

| 영상 성격 | 10초당 SFX 개수 | 언제 |
|---|---|---|
| 冷静 · 집중 | 0-3 개 | 개발 도구 몰입 · 명상형 · 긴 설명 |
| 균형 · 생산성 | 4 개 | 사무 툴 · 튜토리얼 · 생산성 앱 |
| 활기 · 정보 많음 | 6-9 개 | 복잡 도구 데모 · 신제품 런치 · 기능 쇼케이스 |

**경험칙**: **cue 를 30-50% 줄여라**. 남은 cue 가 더 극적으로 느껴짐. 매 시각 beat 에 SFX 붙이면 흔한 광고 느낌.

## SFX Cue 우선순위

| 우선순위 | 상황 | 생략 시 |
|---|---|---|
| **P0 (필수)** | 타이핑 (터미널/입력) · 클릭/선택 (사용자 결정) · 포커스 전환 (주역 이동) · Logo reveal (브랜드 수렴) | 위화감 확실 |
| **P1 (권장)** | 요소 입장/퇴장 (modal/card) · 성공 반응 · AI 생성 시작/종료 · Scene 전환 | 심심함 |
| **P2 (선택)** | hover/focus-in · 진행 tick · 장식 ambient | 많으면 혼탁 |

## 타임스탬프 정밀도

| 시각 beat | 오프셋 |
|---|---|
| 클릭 / 포커스 전환 / Logo 착지 | **동프레임** (0ms) |
| 빠른 whoosh (예측 주는 유입) | **-1~2 프레임** (-33 ~ -67ms) |
| 물체 낙하 · impact | **+1~2 프레임** (+33 ~ +67ms, 물리 현실감) |

## BGM 선택 결정 트리

```
이 영상의 성격은?
├─ 신제품 런치 / 기술 데모   → bgm-tech           (minimal synth + piano)
├─ 광고 · 홍보              → bgm-ad             (upbeat, marketing)
├─ 튜토리얼 · 도구 사용       → bgm-tutorial      (warm, instructional)
├─ 교육 · 원리 설명          → bgm-educational   (curious, thoughtful)
├─ 대안 (위의 변형 필요)     → *-alt              (tech-alt, tutorial-alt)
```

## 검증 체크

영상 완성 전 필수 확인:
```bash
ffprobe -v error -select_streams a -show_entries stream=codec_type,duration motion.mp4
```
- `codec_type=audio` 한 줄 이상 있어야 함 — 없으면 오디오 누락, 전달 금지
- `duration` 이 영상 duration 과 ±0.5초 이내 일치

## 실수 방지 체크리스트

- [ ] BGM + SFX 둘 다 있는가 (한 층만은 금지)
- [ ] BGM 0.40-0.50, SFX 1.00 비율 적용
- [ ] `amix normalize=0` 옵션 (기본값 아님 · 명시 필요)
- [ ] `lowpass=4000` BGM + `highpass=800` SFX 주파수 분리
- [ ] BGM 출 `afade` 로 1.5초 페이드아웃
- [ ] SFX 밀도 상황 맞는 레시피 선택 (과밀 주의)
- [ ] P0 cue 전부 배치 (타이핑/클릭/포커스/logo)
- [ ] ffprobe 로 audio stream 존재 확인
