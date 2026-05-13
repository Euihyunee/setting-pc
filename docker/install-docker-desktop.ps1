<#
.SYNOPSIS
    Windows에 Docker Desktop을 설치하고 docker / docker compose 가 동작하는지 검증합니다.

.DESCRIPTION
    수행 단계:
      1) winget 존재 확인
      2) WSL2 활성화 확인 (Docker Desktop의 기본 backend)
      3) Docker Desktop 설치 (이미 있으면 skip) — winget Docker.DockerDesktop
      4) 사용자에게 재부팅 / 최초 실행 안내
      5) Docker Desktop 실행 후 docker, docker compose 버전 출력으로 검증

    Docker Desktop은 `docker compose` (v2, 플러그인) 를 기본 포함하므로 별도 설치 불필요.
    구버전 `docker-compose` (v1) 는 EOL — 사용 권장하지 않음.

.PARAMETER SkipWslCheck
    WSL2 활성화 검사를 건너뜁니다 (이미 활성화되어 있다고 확신할 때).

.PARAMETER VerifyOnly
    설치는 하지 않고 현재 docker / docker compose 상태만 점검합니다.

.EXAMPLE
    ./install-docker-desktop.ps1
    전체 설치 진행

.EXAMPLE
    ./install-docker-desktop.ps1 -VerifyOnly
    현재 설치 상태와 docker/docker compose 버전만 확인
#>

[CmdletBinding()]
param(
    [switch]$SkipWslCheck,
    [switch]$VerifyOnly
)

$ErrorActionPreference = 'Stop'

function Test-DockerStatus {
    Write-Host '==> docker / docker compose 상태 점검' -ForegroundColor Cyan
    $dockerOk = $false
    $composeOk = $false

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        try {
            $v = (docker --version) 2>&1
            Write-Host "    docker: $v" -ForegroundColor Green
            $dockerOk = $true
        } catch {
            Write-Host '    docker 명령은 있으나 데몬 연결 실패 (Docker Desktop이 실행 중인지 확인)' -ForegroundColor Yellow
        }
    } else {
        Write-Host '    docker 명령 없음' -ForegroundColor Yellow
    }

    if ($dockerOk) {
        try {
            $cv = (docker compose version) 2>&1
            Write-Host "    docker compose: $cv" -ForegroundColor Green
            $composeOk = $true
        } catch {
            Write-Host '    docker compose 동작 실패 (Docker Desktop 미실행 또는 미설치)' -ForegroundColor Yellow
        }
    }

    return [pscustomobject]@{ Docker = $dockerOk; Compose = $composeOk }
}

if ($VerifyOnly) {
    $r = Test-DockerStatus
    if ($r.Docker -and $r.Compose) {
        Write-Host ''
        Write-Host '정상 — docker와 docker compose 모두 사용 가능' -ForegroundColor Green
    } else {
        Write-Host ''
        Write-Host '미완료 — 위 메시지를 확인하고 install 옵션 없이 다시 실행하세요.' -ForegroundColor Yellow
    }
    return
}

# 1) winget 확인
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 없습니다. Microsoft Store의 'App Installer'를 먼저 설치하세요."
}

# 2) WSL2 확인
if (-not $SkipWslCheck) {
    Write-Host '==> WSL2 활성화 확인' -ForegroundColor Cyan
    try {
        $wsl = (wsl --status) 2>&1 | Out-String
        if ($wsl -notmatch 'Default Version:\s*2') {
            Write-Host '    WSL2가 기본이 아닙니다. 다음을 실행하세요:' -ForegroundColor Yellow
            Write-Host '      wsl --set-default-version 2' -ForegroundColor Yellow
        } else {
            Write-Host '    WSL2 OK' -ForegroundColor Green
        }
    } catch {
        Write-Host '    WSL 미설치 — 다음 명령으로 설치 후 재부팅하세요:' -ForegroundColor Yellow
        Write-Host '      wsl --install' -ForegroundColor Yellow
        Write-Host '    (Docker Desktop은 WSL2 backend가 권장입니다.)' -ForegroundColor Yellow
    }
}

# 3) Docker Desktop 설치
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host '==> Docker 이미 설치됨 (skip 설치 단계)' -ForegroundColor DarkGray
} else {
    Write-Host '==> Docker Desktop 설치 중... (수 분 소요)' -ForegroundColor Cyan
    winget install Docker.DockerDesktop -s winget --accept-source-agreements --accept-package-agreements
    # PATH 새로고침
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# 4) 안내
Write-Host ''
Write-Host '설치 절차 다음 단계:' -ForegroundColor Yellow
Write-Host '  1) Windows 재부팅 (최초 설치 시 권장)' -ForegroundColor Yellow
Write-Host '  2) 시작 메뉴에서 "Docker Desktop" 실행' -ForegroundColor Yellow
Write-Host '  3) 최초 실행 시 라이선스 동의 + WSL2 backend 선택' -ForegroundColor Yellow
Write-Host '  4) Docker Desktop 아이콘이 "Running" 상태가 되면 새 터미널에서:' -ForegroundColor Yellow
Write-Host '     ./install-docker-desktop.ps1 -VerifyOnly' -ForegroundColor Yellow
Write-Host '     로 docker / docker compose 동작 확인' -ForegroundColor Yellow
Write-Host ''

# 5) 즉시 점검 시도
Test-DockerStatus | Out-Null
