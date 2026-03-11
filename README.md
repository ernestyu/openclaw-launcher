
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

### Requirement

Docker must already be installed and running.

For most users, the easiest option is Docker Desktop.

If Docker is not installed, the installer will stop and ask you to install Docker first.

---

### Quick install

#### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.sh | bash
````

#### Windows PowerShell

```powershell
iwr https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.ps1 -useb | iex
```

---

### What the installer does

The installer will:

1. Check that Docker is installed and running
2. Ask for an install directory
3. Download a Compose file (`compose-headless.yaml` on Linux/macOS, `compose-webui.yaml` on Windows)
4. Download `.env.example`
5. Create `.env`
6. Create `data/`
7. Pull the image
8. Start OpenClaw

---

### Project files

This repository contains only a few files:

* `assets/compose-headless.yaml` (used by the Linux/macOS installer)
* `assets/compose-webui.yaml` (used by the Windows installer)
* `assets/.env.example`
* `install.sh`
* `install.ps1`
* `README.md`

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

* `compose.yaml`
* `.env`
* `data/`
* `ssh/`

You do not need a separate uninstall script.

---

### Notes

* The launcher uses the public image `ernestyu/openclaw-patched:latest`
* The image is multi-platform, so Docker automatically selects the correct architecture
* Persistent data is stored in `./data`
* Optional SSH files are stored in `./ssh`
* The launcher is intentionally kept small and simple

---


