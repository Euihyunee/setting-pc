# PowerShell 7.6 설정

PowerShell 7.6 환경에서 Oh My Posh와 Windows Terminal을 함께 사용하기 위한 설정 모음.

## 파일 구성

| 파일 | 설명 |
|---|---|
| [`bootstrap-new-pc.ps1`](./bootstrap-new-pc.ps1) | **새 PC 원클릭 셋업** — pwsh, Windows Terminal, OMP, Nerd Font 자동 설치 후 모든 설정 적용 |
| [`install-oh-my-posh.ps1`](./install-oh-my-posh.ps1) | 테마와 bell 스크립트를 `$PROFILE`에 등록 (bootstrap이 내부에서 호출) |
| [`atomic-custom.omp.json`](./atomic-custom.omp.json) | **기본 테마** — atomic 기반, git repo 이름 + 좁은 터미널 자동 숨김 |
| [`thecyberden-custom.omp.json`](./thecyberden-custom.omp.json) | 대체 테마 — thecyberden 기반 (참고용) |
| [`mac-pro-scheme.jsonc`](./mac-pro-scheme.jsonc) | Mac Terminal.app "Pro" 색 구성표 (Windows Terminal용 — 참조용 단독 파일) |
| [`tab-completion-bell.ps1`](./tab-completion-bell.ps1) | 명령 완료 시 비활성 탭에 종 아이콘 표시 (긴 작업용) |
| [`windows-terminal-settings.json`](./windows-terminal-settings.json) | 현재 Windows Terminal 전체 설정 백업 (Mac Pro + Nerd Font + bellStyle 포함) |
| [`oh-my-posh-commands.md`](./oh-my-posh-commands.md) | Oh My Posh 주요 명령어와 테마 적용 방법 |
| [`terminal-profile.md`](./terminal-profile.md) | Windows Terminal `settings.json` 설정 가이드 |

## 빠른 시작 (새 PC)

### 사전 준비
- Windows 10 / 11
- `winget` (Windows 10이면 Microsoft Store의 "App Installer" 필요 — 보통 기본 설치되어 있음)
- `git` (없으면 `winget install Git.Git`)

### 실행
```powershell
# 1) 리포 클론
git clone https://github.com/Euihyunee/setting-pc.git D:\git\setting-pc

# 2) Windows Terminal이 없으면 먼저 설치 (bootstrap이 settings.json 폴더를 찾기 위함)
winget install Microsoft.WindowsTerminal
# 그 후 Windows Terminal을 한 번 실행했다가 닫기 (settings.json 폴더 생성)

# 3) 원클릭 셋업
cd D:\git\setting-pc\powershell7.6
./bootstrap-new-pc.ps1
```

`bootstrap-new-pc.ps1`이 자동으로 처리하는 것:
- PowerShell 7.x, Windows Terminal, Oh My Posh 설치 (미설치 시)
- Nerd Font (Meslo) 설치
- Windows Terminal `settings.json` 을 리포 버전으로 교체 (기존 설정은 `.bak.<timestamp>`로 백업)
- `$PROFILE` 에 oh-my-posh 테마 + tab-completion-bell 등록

### 부분 적용
이미 일부 환경이 있는 경우:
```powershell
# settings.json은 그대로 두고 나머지만
./bootstrap-new-pc.ps1 -SkipSettings

# 폰트 설치는 건너뛰기
./bootstrap-new-pc.ps1 -SkipFont

# OMP/프로필 설정만 다시 적용
./install-oh-my-posh.ps1
```

## 왜 "공식 테마 폴더" 대신 리포에 테마 파일을 둘까

Oh My Posh 공식 테마는 `$env:POSH_THEMES_PATH` 안에 설치됩니다.
하지만 이 리포는 그 폴더를 사용하지 않고, **리포 내 `.omp.json` 파일을 `$PROFILE`이 직접 가리키도록** 구성합니다.

| 방식 | 장점 | 단점 |
|---|---|---|
| `$env:POSH_THEMES_PATH` 사용 | 설치하면 끝, 경로 신경 X | 테마 수정 시 git 추적 불가, OMP 업데이트 시 덮어쓰기 위험 |
| **리포 로컬 경로 사용 (이 방식)** | 수정 내역이 git 버전 관리됨, 새 PC에서 클론만 하면 동일 환경 | `$PROFILE`이 절대 경로 의존 |

## 커스텀 내용 (atomic → atomic-custom)

기본 테마는 공식 `atomic` 을 베이스로 다음을 커스터마이징했습니다:

| 항목 | 원본 atomic | atomic-custom |
|---|---|---|
| Git 세그먼트 | 브랜치 + 상태 | **git 아이콘 + repo 이름 +** 브랜치 + 상태 |
| Path 세그먼트 | 항상 표시 | 터미널 폭 < 100 cols 면 숨김 (`min_width: 100`) |
| Time 세그먼트 (우측) | 항상 표시 | 터미널 폭 < 100 cols 면 숨김 (`min_width: 100`) |
| 탭 타이틀 (`console_title_template`) | 없음 | `"{{ .Folder }}"` — 현재 폴더명을 탭에 표시 |

atomic 테마는 원래 컨텍스트에 따라 풍부한 세그먼트가 자동 표시됩니다:
- **좌측**: shell, root, path, git, `executiontime` (직전 명령 실행 시간)
- **우측**: `node / python / java / dotnet / go / rust / aws / kubectl / battery / time` 등
  → 해당 도구의 프로젝트 폴더에 있을 때만 자동 표시 (e.g. `package.json` 있으면 node 버전)

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
- `atomic-custom.omp.json` 의 `console_title_template`: `"{{ .Folder }}"`
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
