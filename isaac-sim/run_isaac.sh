#!/usr/bin/env bash
set -euo pipefail

# Defaults
: "${PUBLIC_IP:=}"
: "${SIGNAL_PORT:=49100}"
: "${STREAM_PORT:=47998}"
: "${WEBRTC_HTTP_PORT:=8211}"
: "${WIDTH:=2560}"
: "${HEIGHT:=1440}"
: "${TARGET_FPS:=60}"

# NVIDIA 런타임이 디바이스를 지연 주입하는 경우를 위해 GPU 접근을 한 번 트리거
nvidia-smi >/dev/null 2>&1 || true
sleep 2

# GPU 디바이스 준비 대기 (SKIP_GPU_WAIT=1이면 엔트리포인트에서 이미 확인했으므로 생략)
if [[ -z "${SKIP_GPU_WAIT:-}" ]]; then
  for i in {1..30}; do
    [[ -e /dev/nvidia0 ]] && break
    echo "Waiting for /dev/nvidia0... ($i/30)"
    sleep 1
  done
  if [[ ! -e /dev/nvidia0 ]]; then
    echo "ERROR: /dev/nvidia0 not found. Check NVIDIA Container Toolkit and --gpus." >&2
    exit 1
  fi
fi

# 진단: 엔트리포인트 프로세스가 보는 GPU 환경 (로그로 확인용)
echo "[isaac-sim] /dev/nvidia* devices:"
ls -la /dev/nvidia* 2>/dev/null || true
echo "[isaac-sim] nvidia-smi (at entrypoint):"
nvidia-smi 2>/dev/null || true

cd /isaac-sim

# 렌더 해상도(실제 그리는 크기) + 스트림 해상도 둘 다 맞춰야 1080/뭉개짐 방지
# ROS2 브리지: 내장 Jazzy 라이브러리 사용, ros2 컨테이너와 동일 도메인(ROS_DOMAIN_ID) 필요
args=(
  "--/renderer/activeGpu=0"
  "--/rtx/verifyDriverVersion/enabled=false"
  "--/isaac/startup/ros_bridge_extension=isaacsim.ros2.bridge"
  "--/app/livestream/port=${SIGNAL_PORT}"
  "--/app/renderer/resolution/width=${WIDTH}"
  "--/app/renderer/resolution/height=${HEIGHT}"
  "--/exts/omni.services.transport.server.http/port=${WEBRTC_HTTP_PORT}"
  "--/exts/omni.kit.livestream.app/primaryStream/signalPort=${SIGNAL_PORT}"
  "--/exts/omni.kit.livestream.app/primaryStream/streamPort=${STREAM_PORT}"
  "--/exts/omni.kit.livestream.app/primaryStream/width=${WIDTH}"
  "--/exts/omni.kit.livestream.app/primaryStream/height=${HEIGHT}"
  "--/exts/omni.kit.livestream.app/primaryStream/targetFps=${TARGET_FPS}"
)

if [[ -n "${PUBLIC_IP}" ]]; then
  # 인터넷에서 접속할 때는 공식 문서의 publicEndpointAddress 설정을 사용한다.
  args+=("--/app/livestream/publicEndpointAddress=${PUBLIC_IP}")
fi

exec ./runheadless.sh "${args[@]}"
