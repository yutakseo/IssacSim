$ErrorActionPreference = "Stop"
$winPath = (Get-Location).Path -replace '\\', '/'
$wslPath = ($winPath -replace '^([A-Za-z]):', '/mnt/$1').ToLower()
$distro = $env:WSL_DISTRO_NAME
if (-not $distro) { $distro = "Ubuntu" }
Write-Host "WSL2 ($distro) 에서 실행: $wslPath" -ForegroundColor Cyan
wsl -d $distro -e bash -c "cd '$wslPath' && docker compose up -d"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "`n로그 확인: docker compose logs isaac-sim --tail 30" -ForegroundColor Green
