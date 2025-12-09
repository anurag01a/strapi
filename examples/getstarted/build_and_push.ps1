# PowerShell script to build and push the Strapi Docker image

$ErrorActionPreference = "Stop"

Write-Host "--- Strapi Docker Build & Push Helper ---" -ForegroundColor Cyan

# 1. Get Docker Hub Username
$DockerUser = Read-Host "Enter your Docker Hub username"
if ([string]::IsNullOrWhiteSpace($DockerUser)) {
    Write-Error "Username cannot be empty."
    exit 1
}

$ImageName = "$DockerUser/strapi-app"
$Tag = "latest"
$FullImageName = "$ImageName:$Tag"

# 2. Check if Docker is running
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH."
    exit 1
}

# 3. Build the Image
Write-Host "`nBuilding image: $FullImageName..." -ForegroundColor Yellow
# We must build from the root of the monorepo (../../)
# The Dockerfile is at ./Dockerfile.prod relative to this script's location (if run from getstarted dir)
# But we need to be careful about where this script is run from.
# Let's assume the user runs this script from the 'strapi/examples/getstarted' directory.

$ScriptPath = $PSScriptRoot
$RootPath = Resolve-Path "$ScriptPath/../../.."

Write-Host "Build Context: $RootPath"
Write-Host "Dockerfile: $ScriptPath/Dockerfile.prod"

docker build -f "$ScriptPath/Dockerfile.prod" -t $FullImageName "$RootPath"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed."
    exit 1
}

# 4. Push the Image
Write-Host "`nPushing image to Docker Hub..." -ForegroundColor Yellow
Write-Host "Make sure you are logged in (docker login)!"

docker push $FullImageName

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker push failed. Are you logged in?"
    exit 1
}

Write-Host "`nSuccess! Image pushed to $FullImageName" -ForegroundColor Green
Write-Host "You can now use this image in your Terraform configuration:"
Write-Host "docker_image = `"$FullImageName`"" -ForegroundColor Cyan
