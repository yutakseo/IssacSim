#!/usr/bin/env bash
# Compose로 GPU가 안 들어갈 때: docker run --gpus all 로 Isaac Sim만 실행
# 사용법: 프로젝트 루트에서 ./isaac-sim/run-isaac-gpu.sh (WSL Ubuntu 또는 Linux)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

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
  -v "${PROJECT_ROOT}/isaac-sim/volumes/logs:/isaac-sim/.nvidia-omniverse/logs" \
  -u 1234:1234 \
  --gpus all \
  isaac-sim-stream:5.1.0

echo ""
echo "로그: docker logs -f isaac-sim"
