<#
.SYNOPSIS
    Claude Code CLI 네이티브 설치 (irm | iex 방식) + PATH 및 의존성 검증.

.DESCRIPTION
    Anthropic의 공식 네이티브 설치 스크립트를 사용합니다:
        irm https://claude.ai/install.ps1 | iex

    네이티브 설치의 장점:
      - Node.js / npm 의존성 없음
      - 자동 업데이트 빌트인 (재실행 불필요)
      - 단일 바이너리

    설치 위치: %USERPROFILE%\.local\bin\claude.exe
    자동으로 사용자 PATH에 추가됩니다 (재시작 또는 새 터미널 필요).

    Claude Code 는 내부적으로 Git Bash를 사용하므로 Git for Windows가 필수입니다.

.PARAMETER UseNpm
    네이티브 설치 대신 레거시 npm 글로벌 설치 방식을 사용합니다.
    Node.js + npm 이 먼저 설치되어 있어야 합니다.

.EXAMPLE
    ./install-claude-cli.ps1
    네이티브 설치 (권장)

.EXAMPLE
    ./install-claude-cli.ps1 -UseNpm
    npm 글로벌 설치 (레거시)
#>

[CmdletBinding()]
param(
    [switch]$UseNpm
)

$ErrorActionPreference = 'Stop'

# 0) 사전 요구사항: Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host '[!!] Git for Windows가 필요합니다 (Claude Code가 내부적으로 Git Bash 사용).' -ForegroundColor Red
    Write-Host '       → ../git/install-git.ps1 실행 또는 winget install Git.Git' -ForegroundColor Yellow
    return
}
Write-Host "==> Git 확인: $(git --version)" -ForegroundColor DarkGray

if ($UseNpm) {
    # --- 레거시 npm 방식 ---
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host '[!!] npm이 없습니다. Node.js를 먼저 설치하세요.' -ForegroundColor Red
        Write-Host '       → ../node/install-node.ps1 또는 winget install OpenJS.NodeJS.LTS' -ForegroundColor Yellow
        return
    }

    # npm prefix 점검 (자동 업데이트 권한 문제 예방)
    $npmPrefix = (npm config get prefix) 2>$null
    if ($npmPrefix -match 'Program Files|ProgramData') {
        Write-Host "[!!] npm prefix가 시스템 영역에 있음: $npmPrefix" -ForegroundColor Yellow
        Write-Host '       → 사용자 영역으로 변경 권장:' -ForegroundColor Yellow
        Write-Host "         npm config set prefix `"`$env:APPDATA\npm`"" -ForegroundColor Yellow
    }

    $npmBin = "$env:APPDATA\npm"
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $npmBin) {
        Write-Host "==> 사용자 PATH에 $npmBin 추가" -ForegroundColor Cyan
        [Environment]::SetEnvironmentVariable('Path', "$userPath;$npmBin", 'User')
        $env:Path += ";$npmBin"
    }

    Write-Host '==> Claude Code CLI npm 글로벌 설치 중...' -ForegroundColor Cyan
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        npm update -g @anthropic-ai/claude-code
    } else {
        npm install -g @anthropic-ai/claude-code
    }
} else {
    # --- 네이티브 설치 (권장) ---
    Write-Host '==> Claude Code CLI 네이티브 설치 중 (irm | iex)...' -ForegroundColor Cyan
    Write-Host '    URL: https://claude.ai/install.ps1' -ForegroundColor DarkGray
    Invoke-RestMethod 'https://claude.ai/install.ps1' | Invoke-Expression

    # PATH 새로고침 — 네이티브 설치는 ~\.local\bin 을 사용자 PATH에 추가함
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# 검증
Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan

if (Get-Command claude -ErrorAction SilentlyContinue) {
    $cv = (claude --version 2>&1) | Out-String
    Write-Host "[OK] claude: $($cv.Trim())" -ForegroundColor Green
    $cmdPath = (Get-Command claude).Source
    Write-Host "       경로: $cmdPath" -ForegroundColor DarkGray
    Write-Host ''
    Write-Host '시작:' -ForegroundColor Yellow
    Write-Host '  claude           # 현재 디렉토리에서 대화형 시작' -ForegroundColor Yellow
    Write-Host '  claude --help    # 옵션' -ForegroundColor Yellow
    if (-not $UseNpm) {
        Write-Host ''
        Write-Host '자동 업데이트:' -ForegroundColor Yellow
        Write-Host '  - 네이티브 설치는 실행 시 백그라운드에서 자동 업데이트' -ForegroundColor Yellow
        Write-Host '  - 재설치 / 권한 작업 불필요' -ForegroundColor Yellow
    }
} else {
    Write-Host '[!!] claude 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 새 PowerShell 창을 열어 PATH 반영 후 재시도하세요.' -ForegroundColor Yellow
    if ($UseNpm) {
        Write-Host "       → npm 설치 위치 확인: npm root -g" -ForegroundColor Yellow
    } else {
        Write-Host '       → 네이티브 설치 위치: %USERPROFILE%\.local\bin\claude.exe' -ForegroundColor Yellow
        Write-Host '       → 위 경로가 사용자 PATH에 있는지 확인:' -ForegroundColor Yellow
        Write-Host "         [Environment]::GetEnvironmentVariable('Path','User') -split ';'" -ForegroundColor Yellow
        Write-Host '       → 없으면 수동 추가:' -ForegroundColor Yellow
        Write-Host "         `$localBin = `"`$env:USERPROFILE\.local\bin`"" -ForegroundColor Yellow
        Write-Host "         `$user = [Environment]::GetEnvironmentVariable('Path','User')" -ForegroundColor Yellow
        Write-Host "         [Environment]::SetEnvironmentVariable('Path', `"`$user;`$localBin`", 'User')" -ForegroundColor Yellow
    }
}
