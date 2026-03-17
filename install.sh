#!/usr/bin/env bash
set -euo pipefail

REPO_BASE="https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main"
COMPOSE_WEBUI_URL="${REPO_BASE}/assets/compose-webui.yaml"
COMPOSE_HEADLESS_URL="${REPO_BASE}/assets/compose-headless.yaml"
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

read_input() {
  local prompt="$1"
  local reply=""

  if [[ -t 0 ]]; then
    read -r -p "$prompt" reply
  elif [[ -r /dev/tty ]]; then
    read -r -p "$prompt" reply </dev/tty
  else
    reply=""
  fi

  printf '%s' "$reply"
}

is_yes() {
  case "$1" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
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
  local default_dir="${OPENCLAW_DIR:-$HOME/openclaw}"
  local input

  input="$(read_input "Install directory [$default_dir]: ")"
  if [[ -z "$input" ]]; then
    INSTALL_DIR="$default_dir"
  else
    INSTALL_DIR="${input/#\~/$HOME}"
  fi

  export INSTALL_DIR
}

choose_mode() {
  local mode="${OPENCLAW_MODE:-}"
  local reply

  if [[ -n "$mode" ]]; then
    mode="$(printf '%s' "$mode" | tr '[:upper:]' '[:lower:]')"
    case "$mode" in
      webui|headless) reply="$mode" ;;
      *)
        warn "Invalid OPENCLAW_MODE '$mode'. Using webui."
        reply="webui"
        ;;
    esac
  else
    reply="$(read_input "Install Web UI? [Y/n]: ")"
    if [[ -z "$reply" ]]; then
      reply="yes"
    fi
  fi
  reply="$(printf '%s' "$reply" | tr '[:upper:]' '[:lower:]')"

  if is_yes "$reply" || [[ "$reply" == "webui" ]]; then
    COMPOSE_URL="$COMPOSE_WEBUI_URL"
    WEBUI_ENABLED="true"
  else
    COMPOSE_URL="$COMPOSE_HEADLESS_URL"
    WEBUI_ENABLED="false"
  fi
}

prepare_files() {
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR/data"

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

maybe_edit_env() {
  local reply

  if [[ "${OPENCLAW_NO_EDIT:-}" == "1" ]]; then
    info "Skipping .env editing (OPENCLAW_NO_EDIT=1)"
    return
  fi

  if [[ ! -t 0 && ! -r /dev/tty ]]; then
    info "Skipping .env editing (non-interactive)"
    return
  fi

  reply="$(read_input "Open .env for editing now? [y/N]: ")"
  if is_yes "$reply"; then
    if command_exists nano; then
      nano "$INSTALL_DIR/.env"
    elif command_exists vi; then
      vi "$INSTALL_DIR/.env"
    else
      warn "No editor found. Please edit manually: $INSTALL_DIR/.env"
    fi
  else
    info "Skipping .env editing"
  fi
}

start_service() {
  info "Pulling image"
  docker compose -f "$INSTALL_DIR/compose.yaml" --project-directory "$INSTALL_DIR" pull

  info "Starting OpenClaw"
  docker compose -f "$INSTALL_DIR/compose.yaml" --project-directory "$INSTALL_DIR" up -d
}

show_summary() {
  printf '\n'
  info "Install complete."
  printf 'Install directory: %s\n' "$INSTALL_DIR"

  if [[ "$WEBUI_ENABLED" == "true" ]]; then
    printf 'Web UI: http://localhost:3060\n'
  fi

  printf '\nUseful commands:\n'
  printf '  cd "%s"\n' "$INSTALL_DIR"
  printf '  docker compose ps\n'
  printf '  docker compose logs -f\n'
  printf '  docker compose up -d\n'
  printf '  docker compose down\n'
}

main() {
  check_docker
  ask_install_dir
  choose_mode
  prepare_files
  maybe_edit_env
  start_service
  show_summary
}

main "$@"
