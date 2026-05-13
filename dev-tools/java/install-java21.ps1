<#
.SYNOPSIS
    OpenJDK 21 (Eclipse Temurin) 설치 및 JAVA_HOME 설정 검증.

.DESCRIPTION
    - winget으로 EclipseAdoptium.Temurin.21.JDK 설치 (이미 있으면 skip)
    - 설치 후 java -version 으로 21 인지 검증
    - JAVA_HOME 환경변수가 설정되어 있는지 확인
    - 없으면 자동 탐색해서 설정 제안 (-AutoSetJavaHome 스위치로 자동 설정 가능)

.PARAMETER AutoSetJavaHome
    JAVA_HOME이 미설정이고 표준 경로에서 JDK 21을 찾을 수 있을 때
    사용자 환경변수에 자동으로 등록합니다. 기본은 안내만 출력.

.EXAMPLE
    ./install-java21.ps1

.EXAMPLE
    ./install-java21.ps1 -AutoSetJavaHome
#>

[CmdletBinding()]
param(
    [switch]$AutoSetJavaHome
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 없습니다. Microsoft Store의 'App Installer'를 먼저 설치하세요."
}

# 1) 설치
$javaOk = $false
if (Get-Command java -ErrorAction SilentlyContinue) {
    $jv = (java -version 2>&1) | Out-String
    if ($jv -match '"21\.' -or $jv -match 'version "21') {
        Write-Host '==> Java 21 이미 설치됨 (skip)' -ForegroundColor DarkGray
        $javaOk = $true
    } else {
        Write-Host '==> 다른 버전의 Java가 PATH에 있습니다. Java 21 설치 진행...' -ForegroundColor Yellow
    }
}

if (-not $javaOk) {
    Write-Host '==> Eclipse Temurin OpenJDK 21 설치 중...' -ForegroundColor Cyan
    winget install EclipseAdoptium.Temurin.21.JDK -s winget --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

# 2) 검증
Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan

if (Get-Command java -ErrorAction SilentlyContinue) {
    $jv = (java -version 2>&1) | Out-String
    $jvLine = $jv.Trim().Split("`n")[0]
    if ($jv -match '"21\.' -or $jv -match 'version "21') {
        Write-Host "[OK] java: $jvLine" -ForegroundColor Green
    } else {
        Write-Host "[!!] java 명령은 있으나 21 버전이 아님: $jvLine" -ForegroundColor Red
        Write-Host '       → PATH에서 다른 JDK가 먼저 발견됨. 시스템 환경변수의 PATH 순서 확인 필요.' -ForegroundColor Yellow
    }
} else {
    Write-Host '[!!] java 명령을 찾을 수 없습니다. 새 PowerShell 창에서 다시 확인하세요.' -ForegroundColor Red
}

# 3) JAVA_HOME 확인
if ($env:JAVA_HOME -and (Test-Path $env:JAVA_HOME)) {
    Write-Host "[OK] JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
} else {
    # 자동 탐색
    $candidates = @(
        "$env:ProgramFiles\Eclipse Adoptium",
        "$env:ProgramFiles\Java",
        "${env:ProgramFiles(x86)}\Eclipse Adoptium"
    ) | Where-Object { Test-Path $_ }

    $jdk21 = $null
    foreach ($base in $candidates) {
        $found = Get-ChildItem -Path $base -Directory -ErrorAction SilentlyContinue |
                 Where-Object { $_.Name -match 'jdk-?21' } |
                 Select-Object -First 1
        if ($found) { $jdk21 = $found.FullName; break }
    }

    if ($jdk21) {
        Write-Host "[!!] JAVA_HOME 미설정 — 발견된 JDK 21 경로: $jdk21" -ForegroundColor Yellow
        if ($AutoSetJavaHome) {
            [Environment]::SetEnvironmentVariable('JAVA_HOME', $jdk21, 'User')
            Write-Host "[OK] JAVA_HOME을 사용자 환경변수에 등록했습니다: $jdk21" -ForegroundColor Green
            Write-Host '       → 새 PowerShell 창에서 echo `$env:JAVA_HOME 으로 확인' -ForegroundColor Yellow
        } else {
            Write-Host '       → 자동 등록하려면: ./install-java21.ps1 -AutoSetJavaHome' -ForegroundColor Yellow
            Write-Host '       → 수동 등록:' -ForegroundColor Yellow
            Write-Host "         [Environment]::SetEnvironmentVariable('JAVA_HOME', '$jdk21', 'User')" -ForegroundColor Yellow
        }
    } else {
        Write-Host '[!!] JAVA_HOME 미설정이고 JDK 21 경로 자동 탐색 실패.' -ForegroundColor Red
        Write-Host '       → 설치 완료 후 다시 실행하거나 수동으로 등록하세요:' -ForegroundColor Yellow
        Write-Host "         [Environment]::SetEnvironmentVariable('JAVA_HOME', '<JDK 경로>', 'User')" -ForegroundColor Yellow
    }
}
