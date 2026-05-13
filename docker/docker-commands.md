# Docker / Docker Compose 명령어 모음

Docker Desktop (Windows + WSL2 backend) 기준.
`docker compose` 는 Docker Desktop에 내장된 **v2 플러그인**입니다 (구버전 `docker-compose` 는 EOL).

## 1. 데몬 상태

```powershell
# 데몬 동작 확인 (Docker Desktop이 Running 상태여야 응답)
docker info

# 버전
docker --version
docker compose version

# 시스템 리소스 사용량
docker system df
```

## 2. 이미지 관리

```powershell
# 이미지 검색 / 받기 / 목록 / 삭제
docker search nginx
docker pull nginx:alpine
docker images
docker rmi nginx:alpine

# 사용 안 하는 이미지 일괄 삭제
docker image prune -a
```

## 3. 컨테이너 (단일)

```powershell
# 실행 — 백그라운드, 포트 매핑, 이름 지정
docker run -d --name web -p 8080:80 nginx:alpine

# 상태 확인
docker ps               # 실행 중
docker ps -a            # 전체 (종료된 것 포함)

# 로그 / 접속
docker logs -f web
docker exec -it web sh

# 중지 / 재시작 / 삭제
docker stop web
docker start web
docker rm -f web

# 멈춘 컨테이너 일괄 정리
docker container prune
```

## 4. Docker Compose (v2)

`docker-compose.yml` 또는 `compose.yaml` 파일이 있는 디렉토리에서 실행.

```powershell
# 백그라운드 기동 (이미지 없으면 자동 pull/build)
docker compose up -d

# 로그 (모든 서비스)
docker compose logs -f

# 특정 서비스 로그
docker compose logs -f web

# 서비스 상태
docker compose ps

# 재빌드 (Dockerfile 수정 시)
docker compose up -d --build

# 종료 + 네트워크 제거 (볼륨은 보존)
docker compose down

# 종료 + 볼륨까지 제거 (DB 데이터 날아감 주의)
docker compose down -v

# 특정 서비스만 재시작
docker compose restart web

# 서비스 내에서 명령 실행
docker compose exec web sh
docker compose exec db psql -U postgres
```

### compose 파일 예시
```yaml
# compose.yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - db-data:/var/lib/postgresql/data
volumes:
  db-data:
```

## 5. 볼륨 / 네트워크

```powershell
# 볼륨
docker volume ls
docker volume create mydata
docker volume rm mydata
docker volume prune

# 네트워크
docker network ls
docker network create my-net
docker network inspect bridge
```

## 6. 정리 (디스크 공간 확보)

```powershell
# 안 쓰는 모든 것(컨테이너/네트워크/이미지) 정리
docker system prune

# 볼륨까지 포함
docker system prune --volumes -a
```

> Docker Desktop은 WSL2 backend에서 디스크 이미지를 `%LOCALAPPDATA%\Docker\wsl\` 아래에 둡니다. 이미지가 많이 쌓이면 이 폴더가 큽니다.

## 7. WSL 연동

Docker Desktop의 WSL2 backend는 WSL 내부 Ubuntu에서도 동일한 `docker` 명령을 사용할 수 있게 해줍니다.

```powershell
# WSL 내 Ubuntu에서
wsl
$ docker ps
$ docker compose up -d
```

활성화 위치: **Docker Desktop → Settings → Resources → WSL Integration** 에서 사용 중인 배포판 토글.

## 8. 자주 겪는 문제

| 증상 | 원인 / 해결 |
|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop 미실행 — 시작 메뉴에서 실행 |
| `docker compose: unknown command` | 구버전 Docker (`docker-compose` 로 시도). Docker Desktop을 최신 버전으로 업데이트 |
| WSL Ubuntu에서 docker 명령 안 됨 | Settings → Resources → WSL Integration 에서 해당 배포판 enable |
| 디스크 가득 참 | `docker system prune --volumes -a` 또는 Docker Desktop → Troubleshoot → Clean / Purge data |
| 컨테이너 포트 접속 안 됨 | `-p HOST:CONTAINER` 순서 확인, Windows 방화벽 확인 |
