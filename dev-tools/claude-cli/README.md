# Claude Code CLI

Anthropic의 Claude Code 터미널 CLI 설치 및 자동 업데이트 설정.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-claude-cli.ps1`](./install-claude-cli.ps1) | 네이티브 설치(`irm \| iex`) + PATH/Git 검증. `-UseNpm` 옵션으로 레거시 npm 설치도 지원 |

## 설치 방식

| 방식 | 명령 | 의존성 | 자동 업데이트 | 권장 |
|---|---|---|---|---|
| **네이티브 (이 리포의 기본)** | `irm https://claude.ai/install.ps1 \| iex` | Git for Windows | ✅ 빌트인 | ⭐ |
| Homebrew (macOS/Linux) | `brew install --cask claude-code` | brew | 수동 (`brew upgrade`) | macOS 사용자용 |
| **npm 글로벌 (레거시)** | `npm install -g @anthropic-ai/claude-code` | Node.js + npm | 빌트인 (권한 필요) | 사내 정책상 npm만 가능할 때 |

## 사전 요구사항

- **Git for Windows** — Claude Code가 내부적으로 Git Bash를 사용하므로 필수
  ```powershell
  # 없으면
  ../git/install-git.ps1
  # 또는
  winget install Git.Git
  ```
- `-UseNpm` 사용 시 추가로 **Node.js + npm** 필요

## 설치 (권장: 네이티브)

```powershell
./install-claude-cli.ps1
```

내부 동작:
```powershell
Invoke-RestMethod 'https://claude.ai/install.ps1' | Invoke-Expression
```
- 실행 파일: `%USERPROFILE%\.local\bin\claude.exe`
- 설치 스크립트가 자동으로 위 폴더를 사용자 PATH에 추가
- 새 PowerShell 창을 열면 `claude` 명령 사용 가능

## 레거시 설치 (npm 글로벌)

`npm`으로 설치해야만 하는 경우(예: 사내 정책으로 외부 스크립트 실행 차단):

```powershell
./install-claude-cli.ps1 -UseNpm
```

직접:
```powershell
npm install -g @anthropic-ai/claude-code
```

## 자동 업데이트

### 네이티브 설치
실행할 때마다 백그라운드에서 새 버전을 체크하고 다음 실행 시 자동 적용됩니다.
**권한 조작 불필요** — 사용자 폴더에 설치되어 있어서.

### npm 설치
같은 방식으로 자동 체크되지만, npm 글로벌 prefix 폴더에 쓰기 권한이 있어야 합니다.

#### npm 자동 업데이트 권한 오류(`EACCES`/`EPERM`) 해결

```powershell
# 방법 1 (권장): npm prefix를 사용자 영역으로 이동
npm config set prefix "$env:APPDATA\npm"

# PATH에 추가 (이미 있으면 skip)
$npmBin = "$env:APPDATA\npm"
$user = [Environment]::GetEnvironmentVariable('Path','User')
if (($user -split ';') -notcontains $npmBin) {
    [Environment]::SetEnvironmentVariable('Path', "$user;$npmBin", 'User')
}

# 재설치
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

```powershell
# 방법 2: 수동 업데이트 (자동 실패 시)
npm update -g @anthropic-ai/claude-code
```

```powershell
# 방법 3: 관리자 권한 PowerShell에서 업데이트 (비추천, 매번 번거로움)
npm update -g @anthropic-ai/claude-code
```

근본 해결은 방법 1 — prefix를 사용자 영역으로 이동하면 이후 모든 npm 글로벌 작업이 권한 없이 동작합니다.

## 검증

```powershell
claude --version

# 명령 위치 확인
(Get-Command claude).Source
# 네이티브: C:\Users\<user>\.local\bin\claude.exe
# npm:      C:\Users\<user>\AppData\Roaming\npm\claude.cmd
```

## PATH 트러블슈팅

`claude` 명령이 인식 안 될 때:

```powershell
# 사용자 PATH 확인
[Environment]::GetEnvironmentVariable('Path','User') -split ';'
```

네이티브 설치가 PATH 등록에 실패한 경우 수동 추가:
```powershell
$localBin = "$env:USERPROFILE\.local\bin"
$user = [Environment]::GetEnvironmentVariable('Path','User')
if (($user -split ';') -notcontains $localBin) {
    [Environment]::SetEnvironmentVariable('Path', "$user;$localBin", 'User')
}
# 새 PowerShell 창을 열면 반영
```

npm 설치인데 PATH에 없으면:
```powershell
$npmBin = "$env:APPDATA\npm"
$user = [Environment]::GetEnvironmentVariable('Path','User')
if (($user -split ';') -notcontains $npmBin) {
    [Environment]::SetEnvironmentVariable('Path', "$user;$npmBin", 'User')
}
```

## 자주 쓰는 명령

```powershell
claude                       # 대화형 시작 (현재 폴더에서)
claude --help                # 옵션
claude --print "질문"        # 응답 한 번 받고 종료 (스크립트용)
claude --version
```

설정 파일 위치: `%USERPROFILE%\.claude\`
- `settings.json` — 사용자 설정 (권한 모드, 모델, hooks 등)
- `CLAUDE.md` — 글로벌 컨텍스트 (모든 프로젝트에 자동 로드)
- 프로젝트별 설정은 `<repo>/.claude/settings.json` 또는 `CLAUDE.md`

## 제거

### 네이티브 설치
```powershell
Remove-Item "$env:USERPROFILE\.local\bin\claude.exe"
# 필요 시 ~\.claude\ 폴더도 제거
```

### npm 설치
```powershell
npm uninstall -g @anthropic-ai/claude-code
```
