#!/usr/bin/env bash
set -euo pipefail

# Defaults
: "${PUBLIC_IP:=}"
: "${SIGNAL_PORT:=49100}"
: "${STREAM_PORT:=47998}"
: "${WIDTH:=2560}"
: "${HEIGHT:=1440}"
: "${TARGET_FPS:=60}"

# GPU 디바이스 준비 대기 (컨테이너 기동 직후 일시적으로 없을 수 있음)
for i in {1..30}; do
  [[ -e /dev/nvidia0 ]] && break
  echo "Waiting for /dev/nvidia0... ($i/30)"
  sleep 1
done
if [[ ! -e /dev/nvidia0 ]]; then
  echo "ERROR: /dev/nvidia0 not found. Check NVIDIA Container Toolkit and --gpus." >&2
  exit 1
fi

cd /isaac-sim

# 렌더 해상도(실제 그리는 크기) + 스트림 해상도 둘 다 맞춰야 1080/뭉개짐 방지
args=(
  "--/renderer/activeGpu=0"
  "--/app/renderer/resolution/width=${WIDTH}"
  "--/app/renderer/resolution/height=${HEIGHT}"
  "--/exts/omni.kit.livestream.app/primaryStream/signalPort=${SIGNAL_PORT}"
  "--/exts/omni.kit.livestream.app/primaryStream/streamPort=${STREAM_PORT}"
  "--/exts/omni.kit.livestream.app/primaryStream/width=${WIDTH}"
  "--/exts/omni.kit.livestream.app/primaryStream/height=${HEIGHT}"
  "--/exts/omni.kit.livestream.app/primaryStream/targetFps=${TARGET_FPS}"
)

if [[ -n "${PUBLIC_IP}" ]]; then
  args+=("--/exts/omni.kit.livestream.app/primaryStream/publicIp=${PUBLIC_IP}")
fi

exec ./runheadless.sh "${args[@]}"
