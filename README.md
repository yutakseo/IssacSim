# Isaac Sim + ROS2

NVIDIA Isaac Sim(헤드리스 스트리밍)과 ROS2 Jazzy를 Docker Compose로 실행합니다.

**지원 OS:** Linux, macOS, Windows (동일한 `docker compose` 명령으로 실행)

---

## 요구 사항

| 항목 | Linux | macOS | Windows |
|------|--------|--------|---------|
| Docker + Compose | [Docker Engine](https://docs.docker.com/engine/install/) + [Compose plugin](https://docs.docker.com/compose/install/linux/) | [Docker Desktop](https://docs.docker.com/desktop/install/mac-install/) | [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/) (WSL2 권장) |
| Isaac Sim (GPU) | NVIDIA GPU + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) | ❌ Apple Silicon에는 NVIDIA 미지원 → **ROS2만 사용** | NVIDIA GPU + [WSL2 GPU 지원](https://docs.nvidia.com/cuda/wsl-user-guide/index.html) |

- **Isaac Sim**은 NVIDIA GPU가 있는 **Linux / Windows**에서만 동작합니다.
- **macOS**(특히 Apple Silicon)에서는 **ROS2 컨테이너만** 사용하세요.

---

## 사용법

```bash
# 저장소 클론 후
cd <프로젝트 디렉터리>

# 전체 기동 (Isaac Sim + ROS2) — Linux/Windows + NVIDIA GPU
docker compose up -d

# macOS 또는 GPU 없을 때: ROS2만 기동
docker compose up -d ros2

# 상태 확인
docker compose ps

# 로그 보기
docker compose logs -f

# ROS2 셸 접속
docker compose exec ros2 bash
```

---

## OS별 한 줄 요약

| OS | 권장 명령 |
|----|-----------|
| **Linux** (NVIDIA GPU 있음) | `docker compose up -d` |
| **Linux** (GPU 없음) | `docker compose up -d ros2` |
| **macOS** | `docker compose up -d ros2` |
| **Windows** (NVIDIA GPU 있음) | `docker compose up -d` |
| **Windows** (GPU 없음) | `docker compose up -d ros2` |

---

## 디렉터리 구조

```
├── docker-compose.yaml   # 서비스 정의
├── isaac-sim/            # Isaac Sim 이미지 빌드 및 볼륨
│   ├── Dockerfile
│   ├── run_isaac.sh
│   └── volumes/          # 캐시·로그·데이터 (바인드 마운트)
└── ros2/                 # ROS2 Jazzy 이미지 빌드 및 볼륨
    ├── Dockerfile
    └── volumes/          # ros2_ws 마운트용
```

---

## 환경 변수 (선택)

`docker-compose.yaml`의 `isaac-sim` 서비스에서:

- `PUBLIC_IP`: 스트리밍 접속용 공인 IP (NAT/다중 NIC 시 설정 권장)
- `SIGNAL_PORT`, `STREAM_PORT`, `WIDTH`, `HEIGHT`, `TARGET_FPS`: 스트림 포트·해상도·FPS

---

## 참고

- 셸 스크립트·YAML 등은 **LF** 줄바꿈으로 저장됩니다 (`.gitattributes`, `.editorconfig`). Windows에서 클론해도 컨테이너 내부에서 정상 동작합니다.
- Compose v1 사용 시: `docker-compose` 로 실행해도 됩니다 (v2는 `docker compose`).
