# Git

Windows에 Git for Windows 설치.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-git.ps1`](./install-git.ps1) | winget으로 Git 설치 + 검증 |

## 설치

```powershell
./install-git.ps1
```

## 검증 / 직접 설치

```powershell
# 수동 설치
winget install Git.Git

# 버전 확인
git --version
```

## 권장 초기 설정 (한 번만)

```powershell
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf true        # Windows에서 CRLF 자동 처리
git config --global core.editor "code --wait" # VS Code를 git 에디터로 (선택)
```

## PATH 안내

Git 설치 시 자동으로 PATH에 추가됩니다 (`C:\Program Files\Git\cmd`).
만약 새 터미널에서 `git` 명령이 인식되지 않으면:
1. PowerShell 창을 새로 열기 (PATH 반영)
2. 그래도 안 되면 시스템 PATH에 위 경로가 있는지 확인
