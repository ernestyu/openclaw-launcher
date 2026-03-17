# OpenClaw Launcher

[English](#english) | [中文](README_zh.md)

---

## English

### What this repository is

This repository provides a very small cross-platform launcher for the public OpenClaw Docker image.

It is designed for ordinary users who want a simple install flow:

- no zip download
- no manual extraction
- no manual compose setup

The public image used by this launcher is:

`ernestyu/openclaw-patched:latest`

This image is multi-platform, so Docker automatically pulls the correct image for:

- `linux/amd64`
- `linux/arm64`

That means the same launcher works on:

- Windows
- macOS
- Linux

---

### Requirements

Docker must already be installed and running.

For most users, the easiest option is Docker Desktop.

If Docker is not installed, the installer will stop and ask you to install Docker first.

---

### Quick install

#### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.sh | bash
```

#### Windows PowerShell

```powershell
iwr https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.ps1 -useb | iex
```

---

### Non-interactive install

You can fully script the installer with environment variables:

- `OPENCLAW_DIR` sets the install directory
- `OPENCLAW_MODE` can be `webui` or `headless`
- `OPENCLAW_NO_EDIT=1` skips the `.env` editor prompt

Examples:

```bash
OPENCLAW_DIR="$HOME/openclaw" OPENCLAW_MODE=webui OPENCLAW_NO_EDIT=1 \
  curl -fsSL https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.sh | bash
```

```powershell
$env:OPENCLAW_DIR="$HOME\openclaw"
$env:OPENCLAW_MODE="webui"
$env:OPENCLAW_NO_EDIT="1"
iwr https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.ps1 -useb | iex
```

---

### What the installer does

The installer will:

1. Check that Docker is installed and running
2. Ask for an install directory
3. Ask whether to install Web UI mode or Headless mode
4. Download a `compose.yaml` template
5. Download `.env.example`
6. Create `.env` if it does not exist
7. Create `data/`
8. Pull the image
9. Start OpenClaw

---

### Project files

This repository contains only a few files:

- `assets/compose-webui.yaml`
- `assets/compose-headless.yaml`
- `assets/.env.example`
- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `install.sh`
- `install.ps1`
- `README.md`
- `README_zh.md`
- `SECURITY.md`
- `LICENSE`

The installer downloads the required files into your chosen local install directory.

---

### Update later

From your install directory, run:

```bash
docker compose up -d
```

The compose file uses:

```yaml
pull_policy: daily
```

So if the last pull was more than 24 hours ago, Docker Compose will check for a newer image and pull it automatically before starting.

You do not need a separate update script.

---

### Stop

From your install directory, run:

```bash
docker compose down
```

---

### Logs

From your install directory, run:

```bash
docker compose logs -f
```

---

### Uninstall

From your install directory, first stop the container:

```bash
docker compose down
```

Then simply delete the whole install directory.

That is enough, because this launcher keeps everything inside that local folder, including:

- `compose.yaml`
- `.env`
- `data/`

---

### Notes

- The launcher uses the public image `ernestyu/openclaw-patched:latest`
- Web UI mode binds to `http://localhost:3060` on your machine
- Headless mode does not expose any ports
- Persistent data is stored in `./data`
- The launcher is intentionally kept small and simple

---

### License

MIT. See `LICENSE`.

---

### Contributing

Please read `CONTRIBUTING.md` before opening pull requests.

---

### Security

Please read `SECURITY.md` before reporting security issues.
