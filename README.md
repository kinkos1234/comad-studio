# comad-studio

코마드월드(`~/.claude/`) 위에 얹는 **산출물 생성 스튜디오**. Codex CLI 와 ffmpeg/Playwright/pptxgenjs 를 활용해서 한 문장 트리거로 이미지·영상·슬라이드·인포그래픽·앱 프로토타입을 뽑아낸다.

설치하면 다음 5종 스킬이 붙는다.

| 스킬 | 출력 | 핵심 의존성 |
|---|---|---|
| `comad-image` | PNG (7 모드: portrait·landscape·object·illustration·thumbnail·logo·conceptual) | Codex CLI (`codex /imagen`) |
| `comad-motion` | MP4 / GIF (10–60s, 25fps + 60fps minterpolate, BGM+SFX 믹싱) | ffmpeg, Playwright, Node.js |
| `comad-pptx` | PPTX (LAYOUT_WIDE 13.333×7.5", 슬라이드별 Codex /imagen) | Codex CLI, Node.js (pptxgenjs) |
| `comad-infographic` | HTML + PNG / PDF (4 패턴: metric hero · before/after · timeline · flow) | Playwright |
| `comad-app-prototype` | HTML (iOS · Android · macOS · Browser 프레임 4종, flow + overview 듀얼) | Playwright |

> "산출물 스튜디오" 가 컨셉. 능동적 생성기 (사용자/Claude 가 명시적 호출).
> "조용한 가드" 계열은 자매 레포 [comad-world-extensions](https://github.com/kinkos1234/comad-world-extensions) 참고.

## 설치

```bash
git clone https://github.com/kinkos1234/comad-studio ~/Programmer/01-comad/comad-studio
cd ~/Programmer/01-comad/comad-studio
./install.sh
```

`install.sh` 가 5종 스킬을 `~/.claude/skills/` 로 복사한다 (기존 파일은 `.bak-<UTC>` 백업 후 덮어쓰기). 재실행 안전.

설치 후 `./doctor.sh` 로 의존성 상태 점검 권장.

## 의존성 매트릭스

| 의존성 | image | motion | pptx | infographic | app-prototype |
|---|---|---|---|---|---|
| Codex CLI | ● | | ● | | |
| Node.js (≥18) | | ● | ● | | ● |
| Playwright | | ● | | ● | ● |
| ffmpeg | | ● | | | |
| Python 3 | | | | | |

`./doctor.sh` 가 위 매트릭스대로 진단해서 부족한 의존성 + 설치 명령을 알려준다.

## 트리거 (자동 발화)

각 스킬은 자연어 트리거로 자동 발화. 한국어/영어 모두 지원.

| 스킬 | 한국어 트리거 | 영어 트리거 |
|---|---|---|
| `comad-image` | "이미지 만들어줘", "썸네일 만들어", "로고 만들어줘", "포스터 만들어" | "create image", "make thumbnail", "make logo", "render image" |
| `comad-motion` | "영상 만들어", "GIF 로 뽑아줘", "릴리스 영상", "스킬 소개 영상" | "motion design", "make video", "export MP4", "render GIF" |
| `comad-pptx` | "PPT 만들어줘", "발표자료", "프리젠테이션", "deck 만들어줘" | "create pptx", "make slides", "pitch deck" |
| `comad-infographic` | "인포그래픽 만들어줘", "수치 시각화", "before/after 시각화" | "infographic", "data visualization", "stats graphic" |
| `comad-app-prototype` | "앱 프로토타입", "iPhone 화면", "Android 화면", "데스크톱 앱 UI" | "app prototype", "iPhone mockup", "browser mockup" |

## 출력 위치

스킬마다 다르지만 공통 규칙: `{git-root|pwd}/{images|videos|slides|infographics|prototypes}/YYYY-MM-DD/{slug}-NN.{ext}` 형태.

## 라이선스

- 소스 코드 (스킬 SKILL.md, scripts, references): **MIT**
- `comad-motion/assets/bgm/*.mp3` (6 트랙): **CC-BY 4.0** by Kevin MacLeod (incompetech.com) — `assets/bgm/LICENSES.md` 참고
- `comad-motion/assets/sfx/*.mp3` (16 트랙): 각 파일별 라이선스 — `assets/sfx/LICENSES.md` 참고

상용 사용 시 BGM/SFX attribution 문구 (각 LICENSES.md 의 "Attribution 문구" 섹션) 를 반드시 영상 크레딧/README 에 포함.

## 자매 레포

| 레포 | 성격 | 설치 |
|---|---|---|
| [comad-world](https://github.com/kinkos1234/comad-world) | 8개 핵심 모듈 (brain·browse·ear·eye·photo·sleep·voice + create-comad) | `./install.sh` |
| [comad-world-extensions](https://github.com/kinkos1234/comad-world-extensions) | 9 hooks + 5 skills (자가진화/QA/메모리/병렬 외주) | `./install.sh` |
| **comad-studio** (이 레포) | 5 visual/media 생성 스킬 | `./install.sh` |

세 레포 독립적, 어느 것만 깔아도 작동. 모두 깔면 가장 풍부한 워크플로우.
