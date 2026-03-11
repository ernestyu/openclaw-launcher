$ErrorActionPreference = "Stop"

$RepoBase = "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/openclaw-launcher/main"
$ComposeUrl = "$RepoBase/assets/compose.yaml"
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
    $inputDir = Read-Host "Install directory [$defaultDir]"
    if ([string]::IsNullOrWhiteSpace($inputDir)) {
        $script:InstallDir = $defaultDir
    } else {
        $script:InstallDir = $inputDir
    }
}

function Prepare-Files {
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $InstallDir "data") | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $InstallDir "ssh") | Out-Null

    Info "Downloading compose.yaml"
    Invoke-WebRequest -Uri $ComposeUrl -OutFile (Join-Path $InstallDir "compose.yaml")

    Info "Downloading .env.example"
    Invoke-WebRequest -Uri $EnvExampleUrl -OutFile (Join-Path $InstallDir ".env.example")

    $envFile = Join-Path $InstallDir ".env"
    $envExample = Join-Path $InstallDir ".env.example"

    if (-not (Test-Path $envFile)) {
        Copy-Item $envExample $envFile
        Info "Created .env from .env.example"
    } else {
        Info ".env already exists, keeping existing file"
    }
}

function Maybe-Copy-Ssh {
    $reply = Read-Host "Copy your ~/.ssh into $InstallDir\ssh now? [y/N]"
    if ($reply -match '^(y|yes)$') {
        $userSsh = Join-Path $HOME ".ssh"
        if (Test-Path $userSsh) {
            Copy-Item (Join-Path $userSsh "*") (Join-Path $InstallDir "ssh") -Recurse -Force -ErrorAction SilentlyContinue
            Info "Copied ~/.ssh"
        } else {
            Warn "~/.ssh not found, skipping"
        }
    } else {
        Info "Skipping SSH copy"
    }
}

function Maybe-Edit-Env {
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
    docker compose -f $composeFile pull

    Info "Starting OpenClaw"
    docker compose -f $composeFile up -d
}

function Show-Summary {
    Write-Host ""
    Info "Install complete."
    Write-Host "Install directory: $InstallDir"
    Write-Host "Useful commands:"
    Write-Host "  docker compose -f `"$InstallDir\compose.yaml`" ps"
    Write-Host "  docker compose -f `"$InstallDir\compose.yaml`" logs -f"
    Write-Host "  docker compose -f `"$InstallDir\compose.yaml`" up -d"
    Write-Host "  docker compose -f `"$InstallDir\compose.yaml`" down"
}

Check-Docker
Ask-InstallDir
Prepare-Files
Maybe-Copy-Ssh
Maybe-Edit-Env
Start-Service
Show-Summary