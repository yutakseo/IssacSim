#!/usr/bin/env bash
# nvidia-smi가 성공할 때까지 대기 후, 백그라운드로 유지하면서 run_isaac.sh 실행
# (Docker Desktop에서 GPU가 nvidia-smi 종료 시 제거되는 현상 대응)
set -euo pipefail
echo "[isaac-sim] Waiting for GPU..."
sleep 5
for i in {1..60}; do
  if nvidia-smi >/dev/null 2>&1; then
    echo "[isaac-sim] GPU ready. Keeping nvidia-smi in background."
    nvidia-smi -l 1 &
    sleep 2
    export SKIP_GPU_WAIT=1
    /isaac-sim/run_isaac_custom.sh "$@"
    exit
  fi
  sleep 1
done
echo "[isaac-sim] GPU not available after 60s, starting anyway..."
/isaac-sim/run_isaac_custom.sh "$@"
