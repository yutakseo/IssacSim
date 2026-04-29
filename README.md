# Isaac Sim + ROS 2

NVIDIA Isaac Sim(헤드리스 스트리밍)과 ROS 2 Jazzy를 Docker Compose로 실행합니다.

**지원 OS:** Linux, macOS, Windows (동일한 `docker compose` 명령으로 실행)

Isaac Sim 컨테이너는 [공식 설치 가이드](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_container.html)와 동일하게 동작합니다. 컨테이너 데이터는 각 모듈 디렉터리 바로 아래에 바인드합니다.

---

## 요구 사항

- Docker, Docker Compose
- NVIDIA GPU + 드라이버 + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## 사용법

```bash
# 저장소 클론 후
cd <프로젝트 디렉터리>

# 전체 기동 (Isaac Sim + ROS 2) — Linux/Windows + NVIDIA GPU
docker compose up -d

# macOS 또는 GPU 없을 때: ROS 2만 기동
docker compose up -d ros2

# 상태 확인
docker compose ps

# 로그 보기
docker compose logs -f

# ROS 2 셸 접속
docker compose exec ros2 bash
```

---

## 디렉터리 구조

```
├── docker-compose.yaml   # 서비스 정의
├── up-wsl.ps1            # WSL2에서 docker compose 실행 (Windows)
├── isaac-sim/
│   ├── Dockerfile        # (선택) 커스텀 이미지 빌드용. 현재 compose는 공식 이미지 직접 사용
│   ├── documents/        # /root/Documents
│   ├── logs/             # /root/.nvidia-omniverse/logs
│   ├── config/           # /root/.config
│   └── assets/           # /root/.local/share/ov/data
└── ros2/
    ├── Dockerfile
    └── src/              # /ros2_ws/src
```

---

## 환경 변수 (선택)

`docker-compose.yaml`의 `isaac-sim` 서비스에서:

- `PUBLIC_IP`: 스트리밍 접속용 공인 IP (NAT/다중 NIC 시 설정 권장)
- `SIGNAL_PORT`, `STREAM_PORT`, `WIDTH`, `HEIGHT`, `TARGET_FPS`: 스트림 포트·해상도·FPS

---

## ROS 2 연동

Isaac Sim은 기동 시 **ROS 2 브리지 확장**이 켜진 상태로 올라갑니다. ROS 2 Jazzy와 같은 도메인(`ROS_DOMAIN_ID=0`)·같은 RMW(`rmw_fastrtps_cpp`)를 쓰므로, **같은 호스트**에서 두 컨테이너가 떠 있으면 토픽으로 통신할 수 있습니다.

- **Isaac Sim**: 내장 Jazzy 라이브러리 사용, `--/isaac/startup/ros_bridge_extension=isaacsim.ros2.bridge` 로 브리지 활성화
- **ros2**: `docker compose up -d ros2` 로 기동 후 `docker compose exec ros2 bash` 로 들어가서 `ros2 topic list` 등으로 토픽 확인

시뮬레이션에서 퍼블리시하는 토픽(예: 시뮬레이션 타임, 센서 데이터)은 [Isaac Sim ROS 2 튜토리얼](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/ros2_tutorials/ros2_reference_architecture.html)을 참고해 씬·OmniGraph 노드 또는 Python 스크립트로 설정합니다.

---

## GPU / 트러블슈팅

- **컨테이너에 GPU가 안 보일 때**  
  `docker info`에 `Runtimes: ... nvidia` 확인 → 없으면 [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) 설치.  
  로그에 `[isaac-sim] /dev/nvidia*`·`nvidia-smi`가 비어 있으면 GPU가 전달되지 않은 것.

- **`Waiting for /dev/nvidia0...` 만 반복 (Docker Desktop Windows)**  
  **우선 시도:** PowerShell에서(Compose 우회로 Isaac Sim만 직접 실행)

  ```powershell
  cd C:\path\to\isaac-sim-project   # 실제 경로에 맞게 수정
  docker rm -f isaac-sim 2>$null
  docker run --rm -d `
    --name isaac-sim `
    --network host `
    --shm-size 32g `
    -e ACCEPT_EULA=Y `
    -e PRIVACY_CONSENT=Y `
    -e NVIDIA_VISIBLE_DEVICES=all `
    -e ROS_DOMAIN_ID=0 `
    -e ROS_DISTRO=jazzy `
    -e RMW_IMPLEMENTATION=rmw_fastrtps_cpp `
    -e SIGNAL_PORT=49100 `
    -e STREAM_PORT=47998 `
    -e WIDTH=2560 `
    -e HEIGHT=1440 `
    -e TARGET_FPS=60 `
    -v "${PWD}\isaac-sim\logs:/isaac-sim/.nvidia-omniverse/logs" `
    -u 1234:1234 `
    --gpus all `
    nvcr.io/nvidia/isaac-sim:5.1.0
  docker logs -f isaac-sim
  ```

  그래도 실패하면 WSL2에 **Ubuntu** 설치 후 Ubuntu 터미널에서(Compose 우회로 Isaac Sim만 직접 실행):

  ```bash
  cd /mnt/c/___workspace___/isaac-sim-project   # 실제 경로에 맞게 수정
  docker rm -f isaac-sim 2>/dev/null || true
  docker run --rm -d \
    --name isaac-sim \
    --network host \
    --shm-size 32g \
    -e ACCEPT_EULA=Y \
    -e PRIVACY_CONSENT=Y \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e ROS_DOMAIN_ID=0 \
    -e ROS_DISTRO=jazzy \
    -e RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    -e SIGNAL_PORT=49100 \
    -e STREAM_PORT=47998 \
    -e WIDTH=2560 \
    -e HEIGHT=1440 \
    -e TARGET_FPS=60 \
    -v "$(pwd)/isaac-sim/logs:/isaac-sim/.nvidia-omniverse/logs" \
    -u 1234:1234 \
    --gpus all \
    nvcr.io/nvidia/isaac-sim:5.1.0
  docker logs -f isaac-sim
  ```
  ROS 2만 쓰려면 `docker compose up -d ros2`.

- **Isaac Sim만 경고/크래시**  
  `--/renderer/activeGpu=0` 적용됨. Vulkan/RTX 경고는 무시 가능. 크래시 시 `isaac-sim/logs` 확인.

- **Vulkan ERROR_INCOMPATIBLE_DRIVER (RTX 50 시리즈 등)**  
  매우 최신 GPU·드라이버에서 Vulkan 1.1 호환 오류가 날 수 있음. 필요 시 `docker-compose.yaml`의 `isaac-sim` 서비스 `command`에 관련 실행 인자를 추가하거나, Isaac Sim 권장 드라이버 버전 확인.

---

## 참고

- 셸 스크립트·YAML 등은 **LF** 줄바꿈으로 저장됩니다 (`.gitattributes`, `.editorconfig`). Windows에서 클론해도 컨테이너 내부에서 정상 동작합니다.
- Compose v1 사용 시: `docker-compose` 로 실행해도 됩니다 (v2는 `docker compose`).
