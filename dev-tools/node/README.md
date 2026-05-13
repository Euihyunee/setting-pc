# Node.js (npm 포함)

Node.js LTS 버전 설치. npm은 Node.js 패키지에 포함되어 함께 설치됩니다.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-node.ps1`](./install-node.ps1) | Node.js LTS 설치 + PATH 검증 + npm 글로벌 경로 확인 |

## 설치

```powershell
./install-node.ps1
```

## 검증 / 직접 설치

```powershell
# 수동 설치 (LTS)
winget install OpenJS.NodeJS.LTS

# 최신 (Current) 버전이 필요하면
winget install OpenJS.NodeJS

# 버전 확인
node --version
npm --version
```

## PATH 안내

설치 시 자동으로 추가되는 PATH:
- `C:\Program Files\nodejs\` — `node`, `npm` 명령
- `%APPDATA%\npm` — npm으로 글로벌 설치한 패키지(`npm install -g foo`)의 실행 파일

`npm install -g`로 설치한 CLI(예: `typescript`, `pm2`)가 실행되지 않으면 두 번째 경로(`%APPDATA%\npm`)가 PATH에 없는 경우입니다.

### 글로벌 PATH 추가 (영구)
```powershell
$npmGlobal = "$env:APPDATA\npm"
$user = [Environment]::GetEnvironmentVariable('Path', 'User')
[Environment]::SetEnvironmentVariable('Path', "$user;$npmGlobal", 'User')
```
이후 새 터미널을 열면 반영됩니다.

## 자주 쓰는 npm 명령

```powershell
npm init -y                 # package.json 생성
npm install <pkg>           # 의존성 추가
npm install -g <pkg>        # 글로벌 설치 (예: typescript)
npm run <script>            # package.json scripts 실행
npm outdated                # 오래된 패키지 확인
npm update                  # 업데이트
```
