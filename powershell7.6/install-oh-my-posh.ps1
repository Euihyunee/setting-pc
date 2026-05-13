<#
.SYNOPSIS
    이 리포의 커스텀 테마(thecyberden-custom)를 PowerShell 7.6 프로필에 등록합니다.

.DESCRIPTION
    Oh My Posh 공식 테마 폴더($env:POSH_THEMES_PATH)를 사용하지 않고,
    이 리포 안에 있는 .omp.json 파일을 직접 가리키도록 $PROFILE을 구성합니다.

    장점:
      - 테마 수정 내역이 git으로 버전 관리됨
      - 새 PC에서도 리포만 clone 하면 동일 프롬프트 재현 가능
      - Oh My Posh 업데이트 시 공식 테마가 덮어써져도 영향 없음

    동작:
      1) oh-my-posh 바이너리 설치 여부 확인 (없으면 winget으로 설치)
      2) $PROFILE이 없으면 생성
      3) 기존 oh-my-posh init 라인이 있으면 교체, 없으면 추가
      4) -ThemePath 파라미터로 사용할 테마 파일 지정 (기본: 이 스크립트와 같은 폴더의 thecyberden-custom.omp.json)

.PARAMETER ThemePath
    적용할 .omp.json 파일의 절대 경로. 기본값은 스크립트 폴더 내 thecyberden-custom.omp.json.

.EXAMPLE
    ./install-oh-my-posh.ps1
    같은 폴더의 thecyberden-custom.omp.json 적용

.EXAMPLE
    ./install-oh-my-posh.ps1 -ThemePath "D:\git\setting-pc\powershell7.6\my-theme.omp.json"
    지정 경로의 테마 적용
#>

[CmdletBinding()]
param(
    [string]$ThemePath = (Join-Path $PSScriptRoot 'thecyberden-custom.omp.json')
)

$ErrorActionPreference = 'Stop'

# 1) 테마 파일 존재 확인
if (-not (Test-Path $ThemePath)) {
    throw "테마 파일을 찾을 수 없습니다: $ThemePath"
}
$ThemePath = (Resolve-Path $ThemePath).Path
Write-Host "==> 사용할 테마: $ThemePath" -ForegroundColor Cyan

# 2) oh-my-posh 바이너리 확인
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host '==> Oh My Posh 바이너리 미설치 — winget으로 설치합니다.' -ForegroundColor Cyan
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
    # 새 PATH 즉시 반영
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
} else {
    Write-Host '==> Oh My Posh 이미 설치됨 (skip)' -ForegroundColor DarkGray
}

# 3) $PROFILE 준비
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Host "==> 새 프로필 생성: $PROFILE" -ForegroundColor Green
} else {
    Write-Host "==> 기존 프로필: $PROFILE" -ForegroundColor DarkGray
}

# 4) init 라인 갱신 (기존이 있으면 교체)
$bellScript = Join-Path $PSScriptRoot 'tab-completion-bell.ps1'
$newLine = "oh-my-posh init pwsh --config `"$ThemePath`" | Invoke-Expression`n. `"$bellScript`""
$lines = Get-Content $PROFILE
$initPattern = '^\s*oh-my-posh\s+init\b.*$'
$bellPattern = '^\s*\.\s+"[^"]*tab-completion-bell\.ps1"\s*$'
$replaced = $false
$updated = foreach ($line in $lines) {
    if ($line -match $initPattern) {
        $replaced = $true
        $newLine
    } elseif ($line -match $bellPattern) {
        # 기존 dot-source 라인은 새 $newLine에 이미 포함되어 있으므로 제거
        continue
    } else {
        $line
    }
}

if ($replaced) {
    Set-Content -Path $PROFILE -Value $updated -Encoding UTF8
    Write-Host '==> 기존 oh-my-posh init 라인을 새 경로로 교체했습니다.' -ForegroundColor Green
} else {
    Add-Content -Path $PROFILE -Value "`n# Oh My Posh prompt (custom theme from setting-pc repo)`n$newLine`n" -Encoding UTF8
    Write-Host '==> $PROFILE 끝에 oh-my-posh init 라인을 추가했습니다.' -ForegroundColor Green
}

Write-Host ''
Write-Host '설치/등록 완료!' -ForegroundColor Green
Write-Host '아래 명령으로 즉시 적용하거나 새 PowerShell 창을 여세요:' -ForegroundColor Yellow
Write-Host '  . $PROFILE' -ForegroundColor Yellow
Write-Host ''
Write-Host '아이콘이 깨져 보이면 Windows Terminal 폰트를 Nerd Font로 변경하세요.' -ForegroundColor Yellow
Write-Host '자세한 내용: ./terminal-profile.md' -ForegroundColor Yellow
