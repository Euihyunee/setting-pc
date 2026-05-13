# Windows Terminal 프로필 설정

PowerShell 7.6 + Oh My Posh 를 깔끔하게 보이게 하기 위한 Windows Terminal 설정.

## 1. Nerd Font 설치 (필수)

Oh My Posh 프롬프트의 아이콘(브랜치 ``, git 로고 `` 등)은 **Nerd Font** 가 없으면 깨져서 나옵니다.

```powershell
# Oh My Posh가 제공하는 폰트 설치 도우미 (대화형 메뉴)
oh-my-posh font install

# 또는 추천 폰트 바로 설치
oh-my-posh font install meslo      # MesloLGM Nerd Font (가장 무난, 권장)
oh-my-posh font install firacode   # FiraCode Nerd Font (ligature 지원)
oh-my-posh font install jetbrains  # JetBrainsMono Nerd Font
```

설치 후 Windows Terminal을 **재시작**해야 폰트 목록에 반영됩니다.

## 2. settings.json 열기

Windows Terminal → `Ctrl + ,` → 좌측 하단 **"JSON 파일 열기"** 클릭.
또는 직접 경로:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

## 3. PowerShell 7.6 프로필 설정

`profiles.list` 배열에서 PowerShell 7.6 항목을 찾아 다음과 같이 수정/추가합니다.

```jsonc
{
  "name": "PowerShell 7.6",
  "commandline": "pwsh.exe -NoLogo",
  "icon": "ms-appx:///ProfileIcons/{61c54bbd-c2c6-5271-96e7-009a87ff44bf}.png",
  "startingDirectory": "%USERPROFILE%",

  // 폰트 — Nerd Font로 변경
  "font": {
    "face": "MesloLGM Nerd Font",
    "size": 11,
    "weight": "normal"
  },

  // 색상 / 배경
  "colorScheme": "One Half Dark",
  "useAcrylic": true,
  "opacity": 85,

  // 커서
  "cursorShape": "filledBox",

  // 스크롤백
  "historySize": 10000
}
```

> **`commandline` 옵션 `-NoLogo`** — PowerShell 시작 시 뜨는 환영 메시지를 숨겨서 첫 화면을 깔끔하게 합니다.

## 4. 기본 프로필 지정

`settings.json` 최상단에 다음을 설정해 새 탭이 항상 PowerShell 7.6 로 열리도록 합니다.

```jsonc
{
  "defaultProfile": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",  // PowerShell 7의 guid (실제 GUID는 본인 환경에서 확인)
  // ...
}
```

각 프로필의 `guid` 는 `profiles.list` 안에 있고, 그 값을 위 `defaultProfile` 에 복사하면 됩니다.

## 5. 전역 권장 설정 (선택)

```jsonc
{
  "copyOnSelect": true,           // 드래그 선택만으로 클립보드 복사
  "copyFormatting": "none",       // 서식 없이 텍스트만 복사
  "wordDelimiters": " /\\()\"'-.,:;<>~!@#$%^&*|+=[]{}~?│",
  "tabWidthMode": "compact",
  "alwaysShowTabs": true,
  "showTerminalTitleInTitlebar": true,
  "theme": "dark"
}
```

## 6. 확인 체크리스트

- [ ] `pwsh --version` → 7.6.x 출력
- [ ] `oh-my-posh --version` → 정상 출력
- [ ] 새 탭 열었을 때 프롬프트에 아이콘이 깨지지 않음 (`?` 나 `□` 가 아님)
- [ ] git 리포 폴더로 `cd` 하면 브랜치 이름이 표시됨
- [ ] `$PROFILE` 파일에 `oh-my-posh init pwsh ...` 라인 존재

체크리스트 통과하면 설정 완료입니다.

## 참고

- [Windows Terminal 공식 문서](https://learn.microsoft.com/windows/terminal/)
- [Oh My Posh 폰트 가이드](https://ohmyposh.dev/docs/installation/fonts)
- [Nerd Fonts 공식 사이트](https://www.nerdfonts.com/)
