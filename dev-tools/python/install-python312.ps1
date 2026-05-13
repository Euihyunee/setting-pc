<#
.SYNOPSIS
    Python 3.12 설치 + PATH 및 pip 검증.

.DESCRIPTION
    - winget으로 Python.Python.3.12 설치 (이미 있으면 skip)
    - python --version 으로 3.12.x 인지 확인
    - pip 동작 확인
    - py launcher 가 있으면 py -3.12 동작 안내

.EXAMPLE
    ./install-python312.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 없습니다. Microsoft Store의 'App Installer'를 먼저 설치하세요."
}

# 설치
$py312Found = $false
if (Get-Command python -ErrorAction SilentlyContinue) {
    $pyv = (python --version 2>&1) | Out-String
    if ($pyv -match 'Python 3\.12\.') {
        Write-Host '==> Python 3.12 이미 설치됨 (skip)' -ForegroundColor DarkGray
        $py312Found = $true
    } else {
        Write-Host "==> 다른 버전 발견: $($pyv.Trim()) — Python 3.12 추가 설치 진행..." -ForegroundColor Yellow
    }
}

if (-not $py312Found) {
    Write-Host '==> Python 3.12 설치 중...' -ForegroundColor Cyan
    winget install Python.Python.3.12 -s winget --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pyv = (python --version 2>&1) | Out-String
    if ($pyv -match 'Python 3\.12\.') {
        Write-Host "[OK] python: $($pyv.Trim())" -ForegroundColor Green
    } else {
        Write-Host "[!!] python 명령은 있으나 3.12가 아님: $($pyv.Trim())" -ForegroundColor Red
        Write-Host '       → py launcher로 명시적 호출: py -3.12 --version' -ForegroundColor Yellow
        Write-Host '       → PATH 순서를 바꾸려면 시스템 환경변수에서 3.12 경로를 위로 이동' -ForegroundColor Yellow
    }
} else {
    Write-Host '[!!] python 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 새 PowerShell 창에서 다시 시도하세요.' -ForegroundColor Yellow
    Write-Host '       → 설치 시 "Add Python to PATH" 가 체크되었는지 확인 필요.' -ForegroundColor Yellow
}

if (Get-Command pip -ErrorAction SilentlyContinue) {
    Write-Host "[OK] pip: $(pip --version)" -ForegroundColor Green
} else {
    Write-Host '[!!] pip 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 다음으로 복구 시도: python -m ensurepip --upgrade' -ForegroundColor Yellow
}

# py launcher 안내
if (Get-Command py -ErrorAction SilentlyContinue) {
    Write-Host ''
    Write-Host '참고: py launcher 사용 가능' -ForegroundColor DarkGray
    Write-Host '  py -3.12          # 3.12 인터프리터 실행' -ForegroundColor DarkGray
    Write-Host '  py -0             # 설치된 Python 버전 목록' -ForegroundColor DarkGray
}
