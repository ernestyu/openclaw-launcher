#!/usr/bin/env bash
set -euo pipefail

REPO_BASE="https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/openclaw-launcher/main"
COMPOSE_URL="${REPO_BASE}/assets/compose.yaml"
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
  mkdir -p "$INSTALL_DIR/ssh"

  info "Downloading compose.yaml"
  download_file "$COMPOSE_URL" "$INSTALL_DIR/compose.yaml"

  info "Downloading .env.example"
  download_file "$ENV_EXAMPLE_URL" "$INSTALL_DIR/.env.example"

  if [[ ! -f "$INSTALL_DIR/.env" ]]; then
    cp "$INSTALL_DIR/.env.example" "$INSTALL_DIR/.env"
    info "Created .env from .env.example"
  else
    info ".env already exists, keeping existing file"
  fi
}

maybe_copy_ssh() {
  printf "Copy your ~/.ssh into %s/ssh now? [y/N]: " "$INSTALL_DIR"
  read -r reply
  case "$reply" in
    [yY][eE][sS]|[yY])
      if [[ -d "$HOME/.ssh" ]]; then
        cp -a "$HOME/.ssh/." "$INSTALL_DIR/ssh/"
        chmod 700 "$INSTALL_DIR/ssh" || true
        info "Copied ~/.ssh"
      else
        warn "~/.ssh not found, skipping"
      fi
      ;;
    *)
      info "Skipping SSH copy"
      ;;
  esac
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
  docker compose -f "$INSTALL_DIR/compose.yaml" pull

  info "Starting OpenClaw"
  docker compose -f "$INSTALL_DIR/compose.yaml" up -d
}

show_summary() {
  printf '\n'
  info "Install complete."
  printf 'Install directory: %s\n' "$INSTALL_DIR"
  printf 'Useful commands:\n'
  printf '  docker compose -f "%s/compose.yaml" ps\n' "$INSTALL_DIR"
  printf '  docker compose -f "%s/compose.yaml" logs -f\n' "$INSTALL_DIR"
  printf '  docker compose -f "%s/compose.yaml" up -d\n' "$INSTALL_DIR"
  printf '  docker compose -f "%s/compose.yaml" down\n' "$INSTALL_DIR"
}

main() {
  check_docker
  ask_install_dir
  prepare_files
  maybe_copy_ssh
  maybe_edit_env
  start_service
  show_summary
}

main "$@"