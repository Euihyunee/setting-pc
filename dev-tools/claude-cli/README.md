# Claude Code CLI

Anthropic의 Claude Code 터미널 CLI 설치 및 자동 업데이트 설정.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-claude-cli.ps1`](./install-claude-cli.ps1) | npm 글로벌 설치 + PATH/권한 검증 |

## 사전 요구사항

Claude Code CLI는 **npm 글로벌 패키지**로 배포되므로 **Node.js + npm**이 먼저 필요합니다.

```powershell
# Node.js 미설치 시 먼저 설치
../node/install-node.ps1
# 또는
winget install OpenJS.NodeJS.LTS
```

## 설치

```powershell
./install-claude-cli.ps1
```

스크립트가 자동으로 처리:
1. npm 존재 확인 (없으면 안내)
2. npm 글로벌 prefix가 사용자 영역인지 점검 (시스템 영역이면 권한 문제 안내)
3. `%APPDATA%\npm` 이 PATH에 있는지 확인 → 없으면 자동 추가
4. `npm install -g @anthropic-ai/claude-code` 실행
5. `claude --version` 으로 검증

## 직접 설치

```powershell
npm install -g @anthropic-ai/claude-code

# 버전 확인
claude --version

# 시작
claude
```

## 자동 업데이트 동작 방식

Claude Code CLI는 실행 시 백그라운드에서 새 버전을 확인하고, 발견되면 자동으로 받아 다음 실행 때 적용합니다.

**자동 업데이트가 성공하려면 npm 글로벌 prefix 폴더에 쓰기 권한이 필요합니다.**

### 권한 문제 (`EACCES`, `EPERM` 등) 해결

자동 업데이트가 실패하거나 `permission denied` 오류가 나면:

#### 방법 1: npm prefix를 사용자 영역으로 변경 (권장)
```powershell
# npm 글로벌 위치를 %APPDATA%\npm 으로 이동
npm config set prefix "$env:APPDATA\npm"

# PATH 확인 (이미 있으면 skip)
$npmBin = "$env:APPDATA\npm"
$user = [Environment]::GetEnvironmentVariable('Path','User')
if (($user -split ';') -notcontains $npmBin) {
    [Environment]::SetEnvironmentVariable('Path', "$user;$npmBin", 'User')
}

# 재설치
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

새 PowerShell 창을 열면 적용됩니다.

#### 방법 2: 수동 업데이트 (자동 실패 시)
```powershell
npm update -g @anthropic-ai/claude-code

# 또는 강제 재설치
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

#### 방법 3: 관리자 권한으로 실행 (비추천)
```powershell
# PowerShell을 "관리자 권한으로 실행" 후
npm update -g @anthropic-ai/claude-code
```
> 매번 관리자 권한 필요해서 번거롭고, 보안상 권장 X. 방법 1이 근본 해결.

## 현재 npm 글로벌 설정 확인

```powershell
npm config get prefix       # 글로벌 설치 위치
npm root -g                 # 글로벌 모듈 폴더
npm ls -g --depth=0         # 글로벌 설치 패키지 목록
```

이상적인 값:
- `prefix`: `C:\Users\<user>\AppData\Roaming\npm` (= `%APPDATA%\npm`)
- 사용자 PATH에 위 경로 포함

## 자주 쓰는 명령

```powershell
claude                       # 대화형 세션 시작 (현재 디렉토리에서)
claude --help                # 옵션
claude --print "질문"        # 한 번만 응답받고 종료 (스크립트용)
claude --version             # 버전
```

설정 파일 위치: `%USERPROFILE%\.claude\`
- `settings.json` — 사용자 설정 (권한 모드, 모델, hooks 등)
- `CLAUDE.md` — 글로벌 컨텍스트 (모든 프로젝트에 자동 로드)
- 프로젝트별 설정은 `<repo>/.claude/settings.json` 또는 `CLAUDE.md`

## 제거

```powershell
npm uninstall -g @anthropic-ai/claude-code
```
