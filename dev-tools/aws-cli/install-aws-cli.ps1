<#
.SYNOPSIS
    AWS CLI v2 설치 + 검증.

.DESCRIPTION
    - winget으로 Amazon.AWSCLI 설치 (이미 있으면 skip)
    - aws --version 출력 확인
    - 자격 증명 설정 안내

.EXAMPLE
    ./install-aws-cli.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 없습니다. Microsoft Store의 'App Installer'를 먼저 설치하세요."
}

if (Get-Command aws -ErrorAction SilentlyContinue) {
    Write-Host '==> AWS CLI 이미 설치됨 (skip)' -ForegroundColor DarkGray
} else {
    Write-Host '==> AWS CLI v2 설치 중...' -ForegroundColor Cyan
    winget install Amazon.AWSCLI -s winget --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}

Write-Host ''
Write-Host '=== 검증 ===' -ForegroundColor Cyan

if (Get-Command aws -ErrorAction SilentlyContinue) {
    Write-Host "[OK] aws: $(aws --version)" -ForegroundColor Green
} else {
    Write-Host '[!!] aws 명령을 찾을 수 없습니다.' -ForegroundColor Red
    Write-Host '       → 새 PowerShell 창을 열어 다시 시도하세요 (PATH 미반영).' -ForegroundColor Yellow
    Write-Host '       → 기본 설치 경로: C:\Program Files\Amazon\AWSCLIV2\' -ForegroundColor Yellow
    return
}

# 자격 증명 점검
$awsDir = Join-Path $env:USERPROFILE '.aws'
$hasCreds = Test-Path (Join-Path $awsDir 'credentials')
$hasConfig = Test-Path (Join-Path $awsDir 'config')

Write-Host ''
if ($hasCreds -or $hasConfig) {
    Write-Host "[OK] AWS 설정 파일 발견: $awsDir" -ForegroundColor Green
    Write-Host '       프로필 목록 확인: aws configure list-profiles' -ForegroundColor DarkGray
} else {
    Write-Host '[!!] AWS 자격 증명 미설정.' -ForegroundColor Yellow
    Write-Host '       → 다음 명령으로 설정:' -ForegroundColor Yellow
    Write-Host '         aws configure' -ForegroundColor Yellow
    Write-Host '         (Access Key, Secret Key, region, output format 입력)' -ForegroundColor Yellow
    Write-Host '       → 또는 SSO 사용 시:' -ForegroundColor Yellow
    Write-Host '         aws configure sso' -ForegroundColor Yellow
}
