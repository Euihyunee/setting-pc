<#
.SYNOPSIS
    Claude Code CLI를 npm 글로벌로 설치하고 자동 업데이트가 동작하도록 PATH/권한을 검증합니다.

.DESCRIPTION
    Claude Code (claude CLI)는 npm 글로벌 패키지로 배포되며, 내장된 auto-update를 사용해
    자체적으로 최신 버전을 받아옵니다. 따라서:
      1) Node.js + npm 이 먼저 설치되어 있어야 함
      2) %APPDATA%\npm 이 PATH에 있어야 'claude' 명령이 인식됨
      3) Claude가 자기 자신을 업데이트하려면 npm 글로벌 prefix 폴더에 쓰기 권한이 필요
         → npm 글로벌 기본 위치(%APPDATA%\npm)는 사용자 폴더라 보통 OK
         → 만약 'sudo'/관리자 권한이 요구되면 prefix를 사용자 영역으로 옮기면 됨

.EXAMPLE
    ./install-claude-cli.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# 1) node + npm 선행 확인
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host '[!!] npm이 없습니다. 먼저 Node.js를 설치하세요.' -ForegroundColor Red
    Write-Host '       → ../node/install-node.ps1 실행' -ForegroundColor Yellow
    Write-Host '       → 또는 winget install OpenJS.NodeJS.LTS' -ForegroundColor Yellow
    return
}
Write-Host "==> npm 확인: $(npm --version)" -ForegroundColor DarkGray

# 2) npm 글로벌 prefix 확인
$npmPrefix = (npm config get prefix) 2>$null
Write-Host "==> npm 글로벌 prefix: $npmPrefix" -ForegroundColor DarkGray

# 3) prefix가 Program Files 같은 시스템 영역이면 자동 업데이트 시 권한 문제 발생 가능
if ($npmPrefix -match 'Program Files|ProgramData') {
    Write-Host '[!!] npm prefix가 시스템 영역에 있어 auto-update 시 권한 오류가 날 수 있습니다.' -ForegroundColor Yellow
    Write-Host '       → 사용자 영역으로 옮기는 것을 권장:' -ForegroundColor Yellow
    Write-Host "         npm config set prefix `"`$env:APPDATA\npm`"" -ForegroundColor Yellow
    Write-Host '       → 그 후 PATH에 %APPDATA%\npm 추가 후 새 터미널 사용' -ForegroundColor Yellow
}

# 4) %APPDATA%\npm 이 PATH에 있는지
$npmBin = "$env:APPDATA\npm"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$inPath = ($userPath -split ';') -contains $npmBin
if (-not $inPath) {
    Write-Host "[!!] PATH에 npm 글로벌 경로($npmBin)가 없습니다." -ForegroundColor Yellow
    Write-Host '       → 사용자 PATH에 자동 추가:' -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$npmBin", 'User')
    $env:Path += ";$npmBin"
    Write-Host "[OK] PATH에 추가 완료: $npmBin" -ForegroundColor Green
} else {
    Write-Host "==> PATH 확인 OK: $npmBin" -ForegroundColor DarkGray
}

# 5) Claude CLI 설치
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host '==> claude CLI 이미 설치됨 — 최신으로 업데이트' -ForegroundColor Cyan
    npm update -g @anthropic-ai/claude-code
} else {
    Write-Host '==> Claude Code CLI 글로벌 설치 중...' -ForegroundColor Cyan
    npm install -g @anthropic-ai/claude-code
}

# 6) 검증
Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan
if (Get-Command claude -ErrorAction SilentlyContinue) {
    $cv = (claude --version 2>&1) | Out-String
    Write-Host "[OK] claude: $($cv.Trim())" -ForegroundColor Green
    Write-Host ''
    Write-Host '시작:' -ForegroundColor Yellow
    Write-Host '  claude           # 대화형 시작' -ForegroundColor Yellow
    Write-Host '  claude --help    # 옵션' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '자동 업데이트:' -ForegroundColor Yellow
    Write-Host '  - claude는 실행 시 백그라운드에서 새 버전 체크 후 자동 적용' -ForegroundColor Yellow
    Write-Host '  - 권한 오류로 실패하면 수동 업데이트:' -ForegroundColor Yellow
    Write-Host '    npm update -g @anthropic-ai/claude-code' -ForegroundColor Yellow
} else {
    Write-Host '[!!] claude 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 새 PowerShell 창을 열어 PATH 반영 후 재시도.' -ForegroundColor Yellow
    Write-Host "       → 설치 위치 확인: npm root -g" -ForegroundColor Yellow
}
