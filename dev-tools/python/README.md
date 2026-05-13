# Python 3.12

Python 3.12 설치 + pip 및 PATH 검증.

## 파일

| 파일 | 설명 |
|---|---|
| [`install-python312.ps1`](./install-python312.ps1) | Python 3.12 설치 + 버전/pip/PATH 검증 |

## 설치

```powershell
./install-python312.ps1
```

## 직접 설치

```powershell
winget install Python.Python.3.12

# 버전 확인
python --version
pip --version
```

## PATH 안내

winget으로 설치하면 자동으로 다음이 PATH에 추가됩니다:
- `%LOCALAPPDATA%\Programs\Python\Python312\` — `python.exe`
- `%LOCALAPPDATA%\Programs\Python\Python312\Scripts\` — `pip.exe` 및 글로벌 설치된 CLI

만약 `python`이 인식 안 되면:
1. **새 PowerShell 창** 열기 (PATH 반영)
2. 설치 시 "Add Python to PATH" 체크가 꺼져있던 경우, 재설치하거나 GUI로 PATH 추가

## py launcher

Windows의 Python 설치는 `py` launcher를 함께 제공해, 여러 버전 간 전환이 쉽습니다.

```powershell
py -0                  # 설치된 모든 Python 버전 목록
py -3.12               # 3.12 실행 (PATH의 python이 다른 버전이어도 OK)
py -3.12 -m venv .venv # 3.12로 가상환경 생성
py -3.11 script.py     # 3.11로 스크립트 실행
```

## 가상환경 (venv) 자주 쓰는 흐름

```powershell
# 생성
python -m venv .venv

# 활성화 (PowerShell)
.\.venv\Scripts\Activate.ps1

# (PowerShell 실행 정책 오류 시)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# 비활성화
deactivate

# 의존성 저장 / 복원
pip freeze > requirements.txt
pip install -r requirements.txt
```

## pip 복구

`pip` 명령이 안 될 때:
```powershell
python -m ensurepip --upgrade
python -m pip install --upgrade pip
```
