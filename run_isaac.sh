#!/usr/bin/env bash
set -euo pipefail

# Defaults
: "${PUBLIC_IP:=}"
: "${SIGNAL_PORT:=49100}"
: "${STREAM_PORT:=47998}"
: "${WIDTH:=2560}"
: "${HEIGHT:=1440}"
: "${TARGET_FPS:=60}"

cd /isaac-sim

# 렌더 해상도(실제 그리는 크기) + 스트림 해상도 둘 다 맞춰야 1080/뭉개짐 방지
args=(
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