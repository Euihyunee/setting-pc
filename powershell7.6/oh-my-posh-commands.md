# Oh My Posh 명령어 모음

PowerShell 7.6 환경 기준. 모든 명령은 `pwsh` 에서 실행합니다.

## 1. 설치 / 업데이트 / 제거

```powershell
# 설치 (winget 권장)
winget install JanDeDobbeleer.OhMyPosh -s winget

# 업데이트
winget upgrade JanDeDobbeleer.OhMyPosh

# 제거
winget uninstall JanDeDobbeleer.OhMyPosh

# 버전 확인
oh-my-posh --version
```

> winget이 PATH를 반영하지 못해 `oh-my-posh` 명령을 못 찾는 경우 새 터미널을 열면 됩니다.

## 2. 프로필 등록

Oh My Posh는 PowerShell 프로필에 한 줄을 등록해 매 셸 시작 시 자동 초기화합니다.

```powershell
# 프로필 경로 확인
$PROFILE

# 프로필 파일이 없으면 생성
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }

# 프로필 열기 (notepad 또는 code)
notepad $PROFILE
```

프로필에 추가할 라인 — **이 리포의 커스텀 테마 사용 (권장)**:

```powershell
oh-my-posh init pwsh --config "D:\git\setting-pc\powershell7.6\thecyberden-custom.omp.json" | Invoke-Expression
```

또는 공식 테마 폴더 사용:

```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/thecyberden.omp.json" | Invoke-Expression
```

- `$env:POSH_THEMES_PATH` — 설치 시 등록되는 공식 테마 폴더 경로 (수정 내역 git 추적 X)
- **로컬 절대 경로** — 리포 안의 `.omp.json`을 직접 지정. 수정이 git으로 버전 관리됨 (이 리포의 기본 방식)

## 3. 테마 관리

```powershell
# 모든 공식 테마 미리보기 (스크롤하며 확인)
Get-PoshThemes

# 테마 폴더 직접 확인
ls $env:POSH_THEMES_PATH

# 특정 테마 한 번만 적용 (프로필 영구 변경 X — 현재 세션만)
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/night-owl.omp.json" | Invoke-Expression
```

테마를 영구 변경하려면 `$PROFILE` 안의 `--config` 경로를 수정하고 `. $PROFILE` 로 리로드.

## 4. 커스텀 테마 만들기

```powershell
# 기존 테마를 복사해서 시작
Copy-Item "$env:POSH_THEMES_PATH/thecyberden.omp.json" "$HOME\my-theme.omp.json"

# 편집
code $HOME\my-theme.omp.json

# 적용
oh-my-posh init pwsh --config "$HOME\my-theme.omp.json" | Invoke-Expression
```

세그먼트 템플릿 문법은 [공식 문서](https://ohmyposh.dev/docs/configuration/templates) 참조.
git 세그먼트에서 repo 이름을 표시하려면 `{{ .RepoName }}` 사용.

## 5. 디버깅

```powershell
# 프롬프트 렌더링 디버그 정보 출력
oh-my-posh debug

# 현재 사용 중인 설정 파일 확인
oh-my-posh config get

# 설정 파일 유효성 검사
oh-my-posh config validate --config "$env:POSH_THEMES_PATH/thecyberden.omp.json"

# 폰트 (Nerd Font) 설치 도우미 — 대화형 메뉴
oh-my-posh font install
```

## 6. 자주 겪는 문제

| 증상 | 원인 / 해결 |
|---|---|
| 아이콘이 `□` 또는 `?` 로 보임 | 터미널 폰트가 Nerd Font가 아님 → [terminal-profile.md](./terminal-profile.md) 참고 |
| 프롬프트가 변하지 않음 | `$PROFILE` 에 init 라인 없음 또는 `. $PROFILE` 미실행 |
| `oh-my-posh: command not found` | 설치 후 새 터미널 미오픈 또는 PATH 누락 |
| 색이 이상함 | Windows Terminal의 색 구성표(scheme)와 충돌 — `settings.json`에서 scheme 변경 |
