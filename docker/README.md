# Docker 설치

Windows에서 Docker + `docker compose` v2 사용 환경을 셋업합니다.

## 파일 구성

| 파일 | 설명 |
|---|---|
| [`install-docker-desktop.ps1`](./install-docker-desktop.ps1) | Docker Desktop 설치 (winget) + WSL2 확인 + 검증 |
| [`docker-commands.md`](./docker-commands.md) | docker / docker compose 자주 쓰는 명령어 모음 |

## 설치 방식 선택

| 방식 | 장단점 | 추천 대상 |
|---|---|---|
| **Docker Desktop (이 리포의 기본)** | GUI 포함, WSL2 / 볼륨 / 네트워크 자동 통합, 업데이트 쉬움. 단, 상용 사용 시 라이선스 확인 필요(개인/소규모 무료) | 개인 개발자, 학습 |
| WSL2 안에 Docker Engine 직접 설치 | GUI 없음, 라이선스 자유, 더 가벼움 | Docker Desktop 라이선스 회피 / 서버 환경 시뮬레이션 |

> 이 리포는 Docker Desktop으로 셋업합니다. WSL Engine 방식 스크립트가 필요하면 별도 추가 요청.

## 빠른 시작

```powershell
# 1) 사전 — WSL2 활성화 (이미 되어 있으면 skip)
wsl --install                     # WSL + Ubuntu 자동 설치, 재부팅 필요
wsl --set-default-version 2       # 기본 버전 2로

# 2) 설치 스크립트
cd D:\git\setting-pc\docker
./install-docker-desktop.ps1
```

스크립트 동작 요약:
1. `winget` 확인
2. WSL2 상태 점검 (없으면 안내)
3. Docker Desktop 설치 (이미 있으면 skip)
4. 재부팅 / 최초 실행 안내
5. 가능하면 `docker --version`, `docker compose version` 즉시 점검

## 설치 후 첫 실행

1. **Windows 재부팅** — 가상화 활성화가 부팅 시 반영됨
2. 시작 메뉴 → **Docker Desktop** 실행
3. 라이선스 동의 → **WSL2 backend** 선택 (기본값)
4. Docker Desktop 아이콘이 **Running** 상태가 되면 새 PowerShell에서:
   ```powershell
   ./install-docker-desktop.ps1 -VerifyOnly
   ```
   `docker` / `docker compose` 모두 정상 출력되면 완료.

## docker compose 가 동작하지 않을 때

`docker compose` (v2, 공백) 는 Docker Desktop에 내장된 플러그인입니다.
- ✅ `docker compose up` — v2 (권장)
- ❌ `docker-compose up` — v1, EOL (사용 X)

만약 `docker compose: unknown command` 가 나오면:
- Docker Desktop이 너무 구버전 → `winget upgrade Docker.DockerDesktop`
- Docker Desktop 미실행 → 시작 메뉴에서 실행

자세한 명령어는 [`docker-commands.md`](./docker-commands.md) 참고.

## 옵션

```powershell
# WSL2 검사 건너뛰기
./install-docker-desktop.ps1 -SkipWslCheck

# 설치 안 하고 상태만 확인
./install-docker-desktop.ps1 -VerifyOnly
```
