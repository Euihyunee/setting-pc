# Java 21 (Eclipse Temurin OpenJDK)

Java 21 LTS 설치 + `JAVA_HOME` 환경변수 검증/등록.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-java21.ps1`](./install-java21.ps1) | Temurin JDK 21 설치 + JAVA_HOME 검증 (`-AutoSetJavaHome`으로 자동 등록) |

## 설치

```powershell
# 기본: 설치 + JAVA_HOME 안내
./install-java21.ps1

# JAVA_HOME 자동 등록까지
./install-java21.ps1 -AutoSetJavaHome
```

## 직접 설치

```powershell
winget install EclipseAdoptium.Temurin.21.JDK

# 버전 확인
java -version
javac -version
```

## JAVA_HOME 환경변수

Java 빌드 도구(Maven, Gradle, IntelliJ 등) 다수가 `JAVA_HOME`을 참조하므로 반드시 설정해야 합니다.

### 자동 (스크립트 사용)
```powershell
./install-java21.ps1 -AutoSetJavaHome
```

### 수동 (PowerShell)
```powershell
# 설치 경로 예시 (실제 폴더명은 버전에 따라 다름)
$jdk = "C:\Program Files\Eclipse Adoptium\jdk-21.0.5.11-hotspot"
[Environment]::SetEnvironmentVariable('JAVA_HOME', $jdk, 'User')
```

### 수동 (GUI)
1. Win + R → `sysdm.cpl` → 고급 → 환경 변수
2. 사용자 변수 → 새로 만들기 → 이름 `JAVA_HOME`, 값 `C:\Program Files\Eclipse Adoptium\jdk-21.x.x-hotspot`

설정 후 **새 터미널**을 열어야 반영됩니다.

## 검증

```powershell
echo $env:JAVA_HOME              # 경로 출력
java -version                    # openjdk version "21.x.x"
javac -version                   # javac 21.x.x
```

## 여러 JDK 버전 전환

`JAVA_HOME`만 바꾸면 됩니다. 또는 SDKMAN (WSL) / [Jabba](https://github.com/shyiko/jabba) 같은 도구를 사용.

```powershell
# 현재 세션만 임시 변경
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.x"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```
