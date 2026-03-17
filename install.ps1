$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$RepoBase = "https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main"
$ComposeWebUiUrl = "$RepoBase/assets/compose-webui.yaml"
$ComposeHeadlessUrl = "$RepoBase/assets/compose-headless.yaml"
$EnvExampleUrl = "$RepoBase/assets/.env.example"

function Info($Message) {
    Write-Host "[INFO] $Message"
}

function Warn($Message) {
    Write-Host "[WARN] $Message"
}

function Fail($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

function Test-Command($Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Check-Docker {
    if (-not (Test-Command "docker")) {
        Fail "Docker is not installed. Please install Docker Desktop first."
    }

    try {
        docker info | Out-Null
    } catch {
        Fail "Docker is installed but not running or not accessible."
    }

    try {
        docker compose version | Out-Null
    } catch {
        Fail "Docker Compose plugin is not available."
    }
}

function Ask-InstallDir {
    $defaultDir = Join-Path $HOME "openclaw"
    $envDir = $env:OPENCLAW_DIR

    if (-not [string]::IsNullOrWhiteSpace($envDir)) {
        $script:InstallDir = $envDir
        return
    }

    $inputDir = Read-Host "Install directory [$defaultDir]"
    if ([string]::IsNullOrWhiteSpace($inputDir)) {
        $script:InstallDir = $defaultDir
    } else {
        $script:InstallDir = $inputDir
    }
}

function Select-Mode {
    $envMode = $env:OPENCLAW_MODE

    if (-not [string]::IsNullOrWhiteSpace($envMode)) {
        $mode = $envMode.ToLowerInvariant()
    } else {
        $mode = Read-Host "Install Web UI? [Y/n]"
    }

    if ([string]::IsNullOrWhiteSpace($mode) -or $mode -match '^(y|yes|webui)$') {
        $script:ComposeUrl = $ComposeWebUiUrl
        $script:WebUiEnabled = $true
        return
    }

    if ($mode -match '^(n|no|headless)$') {
        $script:ComposeUrl = $ComposeHeadlessUrl
        $script:WebUiEnabled = $false
        return
    }

    Warn "Invalid OPENCLAW_MODE '$mode'. Using webui."
    $script:ComposeUrl = $ComposeWebUiUrl
    $script:WebUiEnabled = $true
}

function Prepare-Files {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $InstallDir "data") | Out-Null

    $composeFile = Join-Path $InstallDir "compose.yaml"

    Info "Downloading compose.yaml"
    try {
        Invoke-WebRequest -Uri $ComposeUrl -OutFile $composeFile -UseBasicParsing
    } catch {
        Fail "Failed to download compose file."
    }

    Info "Downloading .env.example"
    try {
        Invoke-WebRequest -Uri $EnvExampleUrl -OutFile (Join-Path $InstallDir ".env.example") -UseBasicParsing
    } catch {
        Fail "Failed to download .env.example."
    }

    $envFile = Join-Path $InstallDir ".env"
    $envExample = Join-Path $InstallDir ".env.example"

    if (-not (Test-Path $envFile)) {
        Copy-Item $envExample $envFile
        Info "Created .env from .env.example"
    } else {
        Info ".env already exists, keeping existing file"
    }
}

function Maybe-Edit-Env {
    if ($env:OPENCLAW_NO_EDIT -eq "1") {
        Info "Skipping .env editing (OPENCLAW_NO_EDIT=1)"
        return
    }

    $reply = Read-Host "Open .env for editing now? [y/N]"
    if ($reply -match '^(y|yes)$') {
        $envFile = Join-Path $InstallDir ".env"
        Start-Process notepad $envFile -Wait
    } else {
        Info "Skipping .env editing"
    }
}

function Start-Service {
    $composeFile = Join-Path $InstallDir "compose.yaml"

    Info "Pulling image"
    docker compose -f $composeFile --project-directory $InstallDir pull

    Info "Starting OpenClaw"
    docker compose -f $composeFile --project-directory $InstallDir up -d
}

function Show-Summary {
    Write-Host ""
    Info "Install complete."
    Write-Host "Install directory: $InstallDir"

    if ($WebUiEnabled) {
        Write-Host "Web UI: http://localhost:3060"
    }

    Write-Host ""
    Write-Host "Useful commands:"
    Write-Host "  cd `"$InstallDir`""
    Write-Host "  docker compose ps"
    Write-Host "  docker compose logs -f"
    Write-Host "  docker compose up -d"
    Write-Host "  docker compose down"
}

Check-Docker
Ask-InstallDir
Select-Mode
Prepare-Files
Maybe-Edit-Env
Start-Service
Show-Summary
