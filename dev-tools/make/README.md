# GNU Make

Windows에서 `make` 명령어를 사용할 수 있게 설치.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-make.ps1`](./install-make.ps1) | ezwinports.make 설치 + PATH 검증 |

## 설치

```powershell
./install-make.ps1
```

## 직접 설치

```powershell
winget install ezwinports.make

# 버전 확인
make --version
```

## 다른 설치 옵션

| 패키지 | 특징 |
|---|---|
| `ezwinports.make` (이 리포의 기본) | 최신 단일 바이너리, winget으로 깔끔 |
| `GnuWin32.Make` | 오래되었지만 안정적, GnuWin32 다른 도구들과 호환 |
| Chocolatey `make` | choco 사용 시 권장 |
| WSL Ubuntu의 `make` | 가장 정통, GNU 환경 그대로 사용 가능 (`apt install make`) |

## 환경변수 (PATH)

winget 설치는 자동으로 PATH에 `make.exe`를 등록합니다.
보통 경로는 `%LOCALAPPDATA%\Microsoft\WinGet\Links` (winget이 만든 shim).

`make`가 새 터미널에서도 인식 안 되면:
```powershell
# 현재 사용자 PATH 확인
[Environment]::GetEnvironmentVariable('Path','User') -split ';'

# WinGet Links 경로 추가
$wingetLinks = "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
$user = [Environment]::GetEnvironmentVariable('Path','User')
if ($user -notmatch [regex]::Escape($wingetLinks)) {
    [Environment]::SetEnvironmentVariable('Path', "$user;$wingetLinks", 'User')
}
```

## 자주 쓰는 패턴

```makefile
# Makefile 예시
.PHONY: help install test build clean

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## 의존성 설치
	npm install

test: ## 테스트 실행
	npm test

build: ## 빌드
	npm run build

clean: ## 빌드 산출물 제거
	rm -rf dist
```

```powershell
make help        # 타겟 목록
make install
make test
```

## 주의: 탭 vs 스페이스

Makefile의 명령 라인은 **반드시 탭 문자**로 들여써야 합니다. VS Code에서 Makefile 편집 시 자동으로 탭으로 들어가는지 확인하세요.

## Windows에서 make 쓸 때 흔한 함정

- 쉘 명령이 POSIX 기준 (`rm -rf`, `cp`, `mv`) — Git Bash가 PATH에 있어야 동작. 또는 `del`/`copy` 같은 cmd 명령으로 작성.
- `$$` (달러 두 개) 로 환경변수 escape 가능 (`$$PATH`)
- 줄 끝 CRLF 문제 — `.gitattributes`로 Makefile은 LF로 강제 권장
