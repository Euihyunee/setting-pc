<#
.SYNOPSIS
    Git for Windows를 설치하고 PATH/버전을 검증합니다.

.DESCRIPTION
    - winget으로 Git.Git 설치 (이미 있으면 skip)
    - 설치 후 PATH 새로고침
    - git --version 호출되면 OK
    - 안 되면 친절한 안내 메시지

.EXAMPLE
    ./install-git.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 없습니다. Microsoft Store의 'App Installer'를 먼저 설치하세요."
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host '==> Git 이미 설치됨 (skip)' -ForegroundColor DarkGray
} else {
    Write-Host '==> Git 설치 중...' -ForegroundColor Cyan
    winget install Git.Git -s winget --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "[OK] git: $(git --version)" -ForegroundColor Green
    Write-Host ''
    Write-Host '권장 초기 설정 (한 번만):' -ForegroundColor Yellow
    Write-Host '  git config --global user.name "Your Name"' -ForegroundColor Yellow
    Write-Host '  git config --global user.email "you@example.com"' -ForegroundColor Yellow
    Write-Host '  git config --global init.defaultBranch main' -ForegroundColor Yellow
    Write-Host '  git config --global core.autocrlf true     # Windows CRLF 자동 처리' -ForegroundColor Yellow
} else {
    Write-Host '[!!] git 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 새 PowerShell 창을 열어 다시 시도하세요 (PATH 미반영).' -ForegroundColor Yellow
    Write-Host '       → 그래도 안 되면 시스템 환경변수에 Git 설치 경로 추가 필요:' -ForegroundColor Yellow
    Write-Host '         C:\Program Files\Git\cmd' -ForegroundColor Yellow
}
