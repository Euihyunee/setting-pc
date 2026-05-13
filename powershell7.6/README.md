# PowerShell 7.6 설정

PowerShell 7.6 환경에서 Oh My Posh와 Windows Terminal을 함께 사용하기 위한 설정 모음.

## 파일 구성

| 파일 | 설명 |
|---|---|
| [`thecyberden-custom.omp.json`](./thecyberden-custom.omp.json) | 커스텀 Oh My Posh 테마 (thecyberden 기반, git repo 이름 표시 추가) |
| [`mac-pro-scheme.jsonc`](./mac-pro-scheme.jsonc) | Mac Terminal.app "Pro" 색 구성표 (Windows Terminal용) |
| [`tab-completion-bell.ps1`](./tab-completion-bell.ps1) | 명령 완료 시 비활성 탭에 종 아이콘 표시 (긴 작업용) |
| [`install-oh-my-posh.ps1`](./install-oh-my-posh.ps1) | 테마와 bell 스크립트를 `$PROFILE`에 등록하는 설치 스크립트 |
| [`oh-my-posh-commands.md`](./oh-my-posh-commands.md) | Oh My Posh 주요 명령어와 테마 적용 방법 |
| [`terminal-profile.md`](./terminal-profile.md) | Windows Terminal `settings.json` 설정 가이드 |

## 빠른 시작

1. PowerShell 7.6 설치 — `winget install Microsoft.PowerShell`
2. Nerd Font 설치 — [terminal-profile.md](./terminal-profile.md#1-nerd-font-설치-필수) 참고
3. 이 리포를 클론 (또는 이미 클론된 상태)
   ```powershell
   git clone https://github.com/Euihyunee/setting-pc.git D:\git\setting-pc
   ```
4. 설치 스크립트 실행:
   ```powershell
   cd D:\git\setting-pc\powershell7.6
   ./install-oh-my-posh.ps1
   ```
5. Windows Terminal 폰트를 Nerd Font로 변경 — [terminal-profile.md](./terminal-profile.md) 참고
6. 새 터미널 창을 열어 프롬프트 확인

## 왜 "공식 테마 폴더" 대신 리포에 테마 파일을 둘까

Oh My Posh 공식 테마는 `$env:POSH_THEMES_PATH` 안에 설치됩니다.
하지만 이 리포는 그 폴더를 사용하지 않고, **리포 내 `.omp.json` 파일을 `$PROFILE`이 직접 가리키도록** 구성합니다.

| 방식 | 장점 | 단점 |
|---|---|---|
| `$env:POSH_THEMES_PATH` 사용 | 설치하면 끝, 경로 신경 X | 테마 수정 시 git 추적 불가, OMP 업데이트 시 덮어쓰기 위험 |
| **리포 로컬 경로 사용 (이 방식)** | 수정 내역이 git 버전 관리됨, 새 PC에서 클론만 하면 동일 환경 | `$PROFILE`이 절대 경로 의존 |

## 커스텀 내용 (thecyberden → thecyberden-custom)

원본 `thecyberden` 테마의 git 세그먼트를 다음과 같이 수정했습니다:

| 항목 | 원본 | 커스텀 |
|---|---|---|
| 표시 | 브랜치 + 상태 | **git 아이콘 + repo 이름 + 브랜치 아이콘** + 브랜치 + 상태 |
| 추가된 글리프 | — | `` (git 로고), `` (브랜치 아이콘) |

git 세그먼트 템플릿:
```
  {{ .RepoName }}  {{ .UpstreamIcon }}{{ .HEAD }}...
```

- `` — Git 로고 (Nerd Font)
- `{{ .RepoName }}` — 현재 리포 이름 (예: `setting-pc`)
- `` — 브랜치 아이콘

## 동작 원리 요약

- **Oh My Posh 바이너리** — 프롬프트 렌더러. PowerShell이 매 입력마다 호출해 출력을 프롬프트로 표시
- **PowerShell 프로필 (`$PROFILE`)** — 셸 시작 시 자동 실행되는 스크립트. 여기서 `oh-my-posh init pwsh --config <테마경로> | Invoke-Expression` 으로 초기화
- **Nerd Font** — 프롬프트의 아이콘(``, `` 등)을 렌더링하기 위한 글리프 확장 폰트. 터미널 폰트로 지정해야 아이콘이 보임

## 탭 이름 / 완료 인디케이터

이 리포의 기본 설정은 Windows Terminal 탭에 두 가지 동작을 추가합니다.

### 탭 이름이 세션(현재 폴더)을 따라감
- `thecyberden-custom.omp.json` 의 `console_title_template`: `"{{ .Folder }}"`
- 단, Windows Terminal `settings.json` 에서 **`"suppressApplicationTitle": false`** 가 되어 있어야 적용됨

### 명령 완료 시 비활성 탭에 종 아이콘
- `tab-completion-bell.ps1` 이 prompt 함수를 감싸서, 2초 이상 걸린 명령 후에 BEL(`\a`)을 출력
- Windows Terminal `settings.json` 에서 **`"bellStyle": ["taskbar", "window"]`** 로 설정
  - `taskbar` — 작업 표시줄 아이콘에 표시
  - `window` — 탭에 종 아이콘 표시
  - `audible` 은 일부러 제외 (소리 X)
- 활성 탭은 시각 변화 없음. 다른 탭으로 전환했을 때 작업 완료 알 수 있음

임계값 변경: `tab-completion-bell.ps1`을 dot-source 할 때 파라미터 전달
```powershell
. "D:\git\setting-pc\powershell7.6\tab-completion-bell.ps1" -BellThresholdSeconds 5
```
