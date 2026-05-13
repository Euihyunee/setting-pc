<#
.SYNOPSIS
    새 Windows 10/11 PC에 이 리포의 터미널 환경을 통째로 재현합니다.

.DESCRIPTION
    수행 단계 (이미 설치된 항목은 자동 skip):
      1) PowerShell 7.x (pwsh) 설치 — winget
      2) Windows Terminal 설치 — winget
      3) Oh My Posh 설치 — winget
      4) Nerd Font (Meslo) 설치 — oh-my-posh font install
      5) Windows Terminal settings.json 백업 후 리포 버전으로 덮어쓰기
      6) install-oh-my-posh.ps1 실행 → $PROFILE 에 테마 + bell 스크립트 등록

    실행 후 새 Windows Terminal 창을 열면 모든 설정(Mac Pro 색상, MesloLGM Nerd Font,
    Oh My Posh 커스텀 테마, 탭 완료 인디케이터)이 적용된 상태로 시작됩니다.

.PARAMETER SkipFont
    Nerd Font 설치를 건너뜁니다 (이미 설치되어 있다고 확신할 때).

.PARAMETER SkipSettings
    Windows Terminal settings.json 덮어쓰기를 건너뜁니다 (기존 설정 유지하고 싶을 때).

.EXAMPLE
    ./bootstrap-new-pc.ps1
    전체 셋업 진행

.EXAMPLE
    ./bootstrap-new-pc.ps1 -SkipSettings
    settings.json은 손대지 않고 나머지만 설치
#>

[CmdletBinding()]
param(
    [switch]$SkipFont,
    [switch]$SkipSettings
)

$ErrorActionPreference = 'Stop'
$RepoDir = $PSScriptRoot

function Install-IfMissing {
    param(
        [string]$Command,
        [string]$WingetId,
        [string]$DisplayName
    )
    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        Write-Host "==> $DisplayName 이미 설치됨 (skip)" -ForegroundColor DarkGray
        return $false
    }
    Write-Host "==> $DisplayName 설치 중..." -ForegroundColor Cyan
    winget install $WingetId -s winget --accept-source-agreements --accept-package-agreements
    return $true
}

# 1) winget 자체 확인
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget이 설치되어 있지 않습니다. Microsoft Store에서 'App Installer'를 설치한 뒤 다시 실행하세요."
}

# 2) 핵심 패키지 설치
$pathRefreshed = $false
$pathRefreshed = (Install-IfMissing -Command 'pwsh' -WingetId 'Microsoft.PowerShell' -DisplayName 'PowerShell 7') -or $pathRefreshed
$pathRefreshed = (Install-IfMissing -Command 'wt' -WingetId 'Microsoft.WindowsTerminal' -DisplayName 'Windows Terminal') -or $pathRefreshed
$pathRefreshed = (Install-IfMissing -Command 'oh-my-posh' -WingetId 'JanDeDobbeleer.OhMyPosh' -DisplayName 'Oh My Posh') -or $pathRefreshed

if ($pathRefreshed) {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
    Write-Host '==> PATH 새로고침 완료' -ForegroundColor DarkGray
}

# 3) Nerd Font 설치
if ($SkipFont) {
    Write-Host '==> Nerd Font 설치 건너뜀 (-SkipFont)' -ForegroundColor DarkGray
} else {
    Write-Host '==> Nerd Font (Meslo) 설치 중...' -ForegroundColor Cyan
    Write-Host '    (대화형 메뉴가 뜨면 Meslo 선택 — 또는 미리 설치되어 있으면 그냥 닫아도 됨)' -ForegroundColor DarkGray
    oh-my-posh font install meslo
}

# 4) Windows Terminal settings.json 덮어쓰기
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$repoSettings = Join-Path $RepoDir 'windows-terminal-settings.json'

if ($SkipSettings) {
    Write-Host '==> Windows Terminal settings.json 덮어쓰기 건너뜀 (-SkipSettings)' -ForegroundColor DarkGray
} elseif (-not (Test-Path $repoSettings)) {
    Write-Host "==> 리포에 windows-terminal-settings.json 없음 — settings.json 단계 skip" -ForegroundColor Yellow
} elseif (-not (Test-Path $wtSettingsPath)) {
    Write-Host "==> Windows Terminal 폴더 미존재 — 먼저 Windows Terminal을 한 번 실행한 뒤 재실행하세요." -ForegroundColor Yellow
} else {
    $backupPath = "$wtSettingsPath.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $wtSettingsPath $backupPath -Force
    Write-Host "==> 기존 settings.json 백업: $backupPath" -ForegroundColor DarkGray
    Copy-Item $repoSettings $wtSettingsPath -Force
    Write-Host '==> 리포의 windows-terminal-settings.json 적용 완료' -ForegroundColor Green
}

# 5) Oh My Posh 테마 등록 ($PROFILE)
Write-Host '==> Oh My Posh 테마 + bell 스크립트 등록 ($PROFILE 갱신)' -ForegroundColor Cyan
& (Join-Path $RepoDir 'install-oh-my-posh.ps1')

Write-Host ''
Write-Host '셋업 완료!' -ForegroundColor Green
Write-Host '확인 사항:' -ForegroundColor Yellow
Write-Host '  1) 새 Windows Terminal 창을 엽니다.' -ForegroundColor Yellow
Write-Host '  2) 프롬프트가 Mac Pro 색상 + Nerd Font 아이콘으로 보이는지 확인.' -ForegroundColor Yellow
Write-Host '  3) `Start-Sleep 3` 후 다른 탭으로 전환하면 원래 탭에 종 아이콘이 떠야 합니다.' -ForegroundColor Yellow
