<#
.SYNOPSIS
    GNU Make for Windows 설치 + PATH 검증.

.DESCRIPTION
    - winget으로 ezwinports.make 설치 (이미 있으면 skip)
    - 설치 경로가 PATH에 있는지 확인
    - make --version 동작 확인

    ezwinports.make는 GnuWin32 보다 더 최신 빌드이며 단일 바이너리로 동작합니다.

.EXAMPLE
    ./install-make.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 없습니다. Microsoft Store의 'App Installer'를 먼저 설치하세요."
}

if (Get-Command make -ErrorAction SilentlyContinue) {
    Write-Host '==> make 이미 설치됨 (skip)' -ForegroundColor DarkGray
} else {
    Write-Host '==> GNU Make (ezwinports.make) 설치 중...' -ForegroundColor Cyan
    winget install ezwinports.make -s winget --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan

if (Get-Command make -ErrorAction SilentlyContinue) {
    $mv = (make --version 2>&1) | Out-String
    $mvLine = $mv.Trim().Split("`n")[0]
    Write-Host "[OK] make: $mvLine" -ForegroundColor Green
    $makeExe = (Get-Command make).Source
    Write-Host "       경로: $makeExe" -ForegroundColor DarkGray
} else {
    Write-Host '[!!] make 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 새 PowerShell 창을 열어 다시 시도하세요 (PATH 미반영).' -ForegroundColor Yellow
    Write-Host '       → 기본 설치 경로 (ezwinports.make):' -ForegroundColor Yellow
    Write-Host '         %LOCALAPPDATA%\Microsoft\WinGet\Links 또는' -ForegroundColor Yellow
    Write-Host '         %LOCALAPPDATA%\Microsoft\WinGet\Packages\ezwinports.make_*\' -ForegroundColor Yellow
    Write-Host '       → 위 경로를 사용자 PATH에 추가:' -ForegroundColor Yellow
    Write-Host "         `$user = [Environment]::GetEnvironmentVariable('Path','User')" -ForegroundColor Yellow
    Write-Host "         [Environment]::SetEnvironmentVariable('Path', `"`$user;<make 경로>`", 'User')" -ForegroundColor Yellow
}
