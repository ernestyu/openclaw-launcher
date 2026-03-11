#!/usr/bin/env bash
set -euo pipefail

REPO_BASE="https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/openclaw-launcher/main"
COMPOSE_URL="${REPO_BASE}/assets/compose-headless.yamll"
ENV_EXAMPLE_URL="${REPO_BASE}/assets/.env.example"

info() {
  printf '[INFO] %s\n' "$1"
}

warn() {
  printf '[WARN] %s\n' "$1"
}

error() {
  printf '[ERROR] %s\n' "$1" >&2
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

download_file() {
  local url="$1"
  local dest="$2"

  if command_exists curl; then
    curl -fsSL "$url" -o "$dest"
  elif command_exists wget; then
    wget -qO "$dest" "$url"
  else
    error "Neither curl nor wget is available."
    exit 1
  fi
}

check_docker() {
  if ! command_exists docker; then
    error "Docker is not installed."
    error "Please install Docker Desktop or Docker Engine + Compose plugin first."
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    error "Docker is installed but not running or not accessible."
    exit 1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    error "Docker Compose plugin is not available."
    exit 1
  fi
}

ask_install_dir() {
  local default_dir="$HOME/openclaw"
  printf "Install directory [%s]: " "$default_dir"
  read -r INSTALL_DIR
  INSTALL_DIR="${INSTALL_DIR:-$default_dir}"
  INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"
  export INSTALL_DIR
}

prepare_files() {
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR/data"

  info "Downloading compose-headless.yamll"
  download_file "$COMPOSE_URL" "$INSTALL_DIR/compose-headless.yamll"

  info "Downloading .env.example"
  download_file "$ENV_EXAMPLE_URL" "$INSTALL_DIR/.env.example"

  if [[ ! -f "$INSTALL_DIR/.env" ]]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    info "Created .env from .env.example"
  else
    info ".env already exists, keeping existing file"
  fi
}

maybe_edit_env() {
  printf "Open .env for editing now? [y/N]: "
  read -r reply
  case "$reply" in
    [yY][eE][sS]|[yY])
      if command_exists nano; then
        nano "$INSTALL_DIR/.env"
      elif command_exists vi; then
        vi "$INSTALL_DIR/.env"
      else
        warn "No editor found. Please edit manually: $INSTALL_DIR/.env"
      fi
      ;;
    *)
      info "Skipping .env editing"
      ;;
  esac
}

start_service() {
  info "Pulling image"
  docker compose -f "$INSTALL_DIR/compose-headless.yamll" pull

  info "Starting OpenClaw"
  docker compose -f "$INSTALL_DIR/compose-headless.yamll" up -d
}

show_summary {

    Write-Host ""
    Write-Host "----------------------------------------------------"
    Write-Host "OpenClaw installation completed."
    Write-Host "----------------------------------------------------"
    Write-Host ""

    Write-Host "Install directory:"
    Write-Host "  $InstallDir"
    Write-Host ""

    Write-Host "Web UI is available at:"
    Write-Host ""
    Write-Host "  http://localhost:3060"
    Write-Host ""

    Write-Host "You can open it in your browser."
    Write-Host ""

    Write-Host "Useful commands:"
    Write-Host ""
    Write-Host "Start:"
    Write-Host "  docker compose up -d"
    Write-Host ""
    Write-Host "Stop:"
    Write-Host "  docker compose down"
    Write-Host ""
    Write-Host "Logs:"
    Write-Host "  docker compose logs -f"
    Write-Host ""

    Write-Host "----------------------------------------------------"
    
    Write-Host ""
    Write-Host "Opening browser..."
    Write-Host ""
    Start-Process "http://localhost:3060"
}

main() {
  check_docker
  ask_install_dir
  prepare_files
  maybe_edit_env
  start_service
  show_summary
}

main "$@"