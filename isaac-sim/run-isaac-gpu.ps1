# Compose로 GPU가 안 들어갈 때: docker run --gpus all 로 Isaac Sim만 실행
# 사용법: 프로젝트 루트에서 .\isaac-sim\run-isaac-gpu.ps1
# 참고: Docker Desktop에서 GPU가 안 넘어가면 WSL2에 Ubuntu 등 설치 후, 해당 배포에서 docker run --gpus all 실행해 보세요.
$ErrorActionPreference = "Stop"
$projectRoot = (Split-Path $PSScriptRoot -Parent)

Push-Location $projectRoot
try {
  Write-Host "Isaac Sim (GPU 명시 실행)" -ForegroundColor Cyan
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
    -v "${projectRoot}/isaac-sim/volumes/logs:/isaac-sim/.nvidia-omniverse/logs" `
    -u 1234:1234 `
    --gpus all `
    isaac-sim-stream:5.1.0

  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  Write-Host "`n로그: docker logs -f isaac-sim" -ForegroundColor Green
} finally {
  Pop-Location
}
