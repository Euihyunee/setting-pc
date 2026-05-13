<#
.SYNOPSIS
    명령 실행이 일정 시간 이상 걸리면 BEL(\a)을 출력해 Windows Terminal 탭에
    완료 인디케이터(작은 종 아이콘)를 띄웁니다.

.DESCRIPTION
    동작 원리:
      - 매 프롬프트 렌더링 시 직전 실행 명령의 duration을 검사
      - $BellThresholdSeconds(기본 2초) 초과면 출력 끝에 `\a` 부착
      - Windows Terminal은 BEL 수신 시 비활성 탭에 종 아이콘 표시 (활성 탭은 변화 X)
      - settings.json에서 "bellStyle": ["taskbar","window"] 면 시각 알림만, 소리 X

    이 스크립트는 oh-my-posh init 라인 *이후* 에 dot-source 해야 합니다
    (oh-my-posh이 정의한 prompt 함수를 한 번 더 감싸기 때문).

.PARAMETER BellThresholdSeconds
    이 값(초) 보다 오래 걸린 명령에 대해서만 BEL 출력. 기본 2.

.EXAMPLE
    . "D:\git\setting-pc\powershell7.6\tab-completion-bell.ps1"
#>

param(
    [double]$BellThresholdSeconds = 2
)

$Global:__SettingPcBellThreshold = $BellThresholdSeconds
$Global:__SettingPcLastCmdId = 0
$Global:__SettingPcPoshPrompt = (Get-Item function:prompt).ScriptBlock

function global:prompt {
    $output = & $Global:__SettingPcPoshPrompt
    $last = Get-History -Count 1
    if ($last -and $last.Id -ne $Global:__SettingPcLastCmdId) {
        $Global:__SettingPcLastCmdId = $last.Id
        $duration = $last.EndExecutionTime - $last.StartExecutionTime
        if ($duration.TotalSeconds -gt $Global:__SettingPcBellThreshold) {
            return "$output`a"
        }
    }
    return $output
}
