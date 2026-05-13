<#
.SYNOPSIS
    Node.js LTS (npm 포함) 설치 및 검증.

.DESCRIPTION
    - winget으로 OpenJS.NodeJS.LTS 설치 (이미 있으면 skip)
    - npm 글로벌 패키지 경로(%APPDATA%\npm)가 PATH에 있는지 확인
    - 누락 시 사용자에게 추가 방법 안내

.EXAMPLE
    ./install-node.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 없습니다. Microsoft Store의 'App Installer'를 먼저 설치하세요."
}

if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host '==> Node.js 이미 설치됨 (skip)' -ForegroundColor DarkGray
} else {
    Write-Host '==> Node.js LTS 설치 중...' -ForegroundColor Cyan
    winget install OpenJS.NodeJS.LTS -s winget --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan

$nodeOk = $false
if (Get-Command node -ErrorAction SilentlyContinue) {
    Write-Host "[OK] node: $(node --version)" -ForegroundColor Green
    $nodeOk = $true
} else {
    Write-Host '[!!] node 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 새 PowerShell 창을 열어 다시 시도하세요.' -ForegroundColor Yellow
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host "[OK] npm: $(npm --version)" -ForegroundColor Green
} elseif ($nodeOk) {
    Write-Host '[!!] npm 미인식 — 새 PowerShell 창에서 다시 확인하세요.' -ForegroundColor Yellow
}

# npm 글로벌 prefix 경로가 PATH에 있는지
$npmGlobal = "$env:APPDATA\npm"
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -split ';' | Where-Object { $_ -eq $npmGlobal }) {
    Write-Host "[OK] npm 글로벌 PATH 등록됨: $npmGlobal" -ForegroundColor Green
} else {
    Write-Host "[!!] npm 글로벌 패키지 경로가 PATH에 없습니다: $npmGlobal" -ForegroundColor Red
    Write-Host '       → 사용자 PATH에 추가하려면 PowerShell에서:' -ForegroundColor Yellow
    Write-Host "         [Environment]::SetEnvironmentVariable('Path', `"`$(`[Environment]::GetEnvironmentVariable('Path','User'))`;$npmGlobal`", 'User')" -ForegroundColor Yellow
    Write-Host '       → 또는 한 번만 임시 적용:' -ForegroundColor Yellow
    Write-Host "         `$env:PATH += `";$npmGlobal`"" -ForegroundColor Yellow
}
