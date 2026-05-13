# dev-tools

개별 개발 도구 설치 스크립트 모음. 폴더별로 도구 하나씩, 독립적으로 실행 가능합니다.

## 폴더 구성

| 폴더 | 도구 | 주요 패키지 |
|---|---|---|
| [`git/`](./git) | Git for Windows | `Git.Git` |
| [`node/`](./node) | Node.js LTS + npm | `OpenJS.NodeJS.LTS` |
| [`java/`](./java) | OpenJDK 21 + JAVA_HOME | `EclipseAdoptium.Temurin.21.JDK` |
| [`python/`](./python) | Python 3.12 + pip | `Python.Python.3.12` |
| [`make/`](./make) | GNU Make | `ezwinports.make` |
| [`aws-cli/`](./aws-cli) | AWS CLI v2 | `Amazon.AWSCLI` |
| [`docker/`](./docker) | Docker Desktop + compose v2 | `Docker.DockerDesktop` |
| [`claude-cli/`](./claude-cli) | Claude Code CLI (네이티브 설치, 자동 업데이트) | `irm https://claude.ai/install.ps1 \| iex` |

각 폴더 안의 `README.md`에 도구별 설치/검증/사용법이 있고, `install-*.ps1` 스크립트로 자동 설치가 가능합니다.

## 공통 설치 패턴

모든 설치 스크립트는 동일한 흐름을 따릅니다:
1. `winget` 존재 확인
2. 명령이 이미 PATH에 있으면 설치 skip
3. 없으면 `winget install <pkg-id>` 으로 설치
4. PATH 새로고침
5. 버전 및 환경변수 검증 + 누락 시 친절한 안내

## 일괄 실행

원하는 도구만 순서대로 실행하면 됩니다:

```powershell
cd D:\git\setting-pc\dev-tools

./git/install-git.ps1
./node/install-node.ps1                          # claude-cli의 사전 요구사항
./java/install-java21.ps1 -AutoSetJavaHome
./python/install-python312.ps1
./make/install-make.ps1
./aws-cli/install-aws-cli.ps1
./docker/install-docker-desktop.ps1
./claude-cli/install-claude-cli.ps1              # git 설치 후 실행
```

### 의존 순서
- `claude-cli` (네이티브) → **git이 먼저** 필요 (Claude Code가 내부적으로 Git Bash 사용).
- `claude-cli -UseNpm` (레거시) → **node도 필요**.
- 나머지는 독립적이므로 순서 무관.

각 스크립트는 멱등(idempotent)하므로 여러 번 실행해도 안전합니다.

## 사전 요구사항

- Windows 10 / 11
- **winget** (Microsoft Store의 "App Installer", 보통 기본 설치되어 있음)
- 관리자 권한 PowerShell (일부 winget 패키지는 시스템 PATH/레지스트리에 쓰기 필요)

## 환경변수 트러블슈팅

설치 직후 명령이 인식되지 않는 가장 흔한 원인:
- **PATH 미반영** — 새 PowerShell 창을 여세요. (기존 창의 `$env:Path`는 설치 전 스냅샷)
- **설치 시 "Add to PATH" 체크 해제** — 일부 GUI 설치 옵션을 따로 클릭해야 하는 경우. 재설치 권장.
- **JAVA_HOME 누락** — Java 설치는 `JAVA_HOME`을 자동 설정하지 않을 때가 많음. [`java/install-java21.ps1 -AutoSetJavaHome`](./java) 사용.

각 스크립트는 위 상황을 감지해 어떤 조치를 해야 하는지 출력합니다.
