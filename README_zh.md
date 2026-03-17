# OpenClaw Launcher

[English](README.md) | [中文](#中文)

---

## 中文

### 这个仓库是做什么的

这个仓库提供一个非常轻量的跨平台启动器，用来启动公开版的 OpenClaw Docker 镜像。

目标是让普通用户尽量简单地安装：

- 不需要下载 zip
- 不需要手动解压
- 不需要自己写 compose 文件

这个启动器使用的公开镜像是：

`ernestyu/openclaw-patched:latest`

这个镜像是多平台镜像，Docker 会自动拉取对应平台的版本，例如：

- `linux/amd64`
- `linux/arm64`

因此，这个启动器可以同时用于：

- Windows
- macOS
- Linux

---

### 前提条件

你的电脑上必须已经安装并启动 Docker。

对大多数普通用户来说，最简单的方式是安装 Docker Desktop。

如果 Docker 没有安装，安装脚本会停止，并提示你先安装 Docker。

---

### 快速安装

#### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.sh | bash
```

#### Windows PowerShell

```powershell
iwr https://raw.githubusercontent.com/ernestyu/openclaw-launcher/main/install.ps1 -useb | iex
```

---

### 无交互安装

可以通过环境变量完全脚本化安装流程：

- `OPENCLAW_DIR` 设置安装目录
- `OPENCLAW_MODE` 取值 `webui` 或 `headless`
- `OPENCLAW_NO_EDIT=1` 跳过 `.env` 编辑提示

示例：

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

### 安装脚本会做什么

安装脚本会自动完成这些事情：

1. 检查 Docker 是否已经安装并运行
2. 询问安装目录
3. 询问安装 Web UI 模式还是 Headless 模式
4. 下载 `compose.yaml` 模板
5. 下载 `.env.example`
6. 创建 `.env`（如果不存在）
7. 创建 `data/`
8. 拉取镜像
9. 启动 OpenClaw

---

### 仓库里有哪些文件

这个仓库刻意保持得很简单，只包含少量文件：

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

安装时，脚本会把需要的文件下载到你本地选择的安装目录中。

---

### 以后如何更新

进入你的安装目录后，直接执行：

```bash
docker compose up -d
```

因为 `compose.yaml` 里已经写了：

```yaml
pull_policy: daily
```

所以如果距离上一次拉取镜像已经超过 24 小时，Docker Compose 会自动检查远端是否有更新；如果有更新，就会先拉取最新镜像，再启动容器。

因此，这个项目不需要额外的更新脚本。

---

### 如何停止

进入安装目录后执行：

```bash
docker compose down
```

---

### 如何查看日志

进入安装目录后执行：

```bash
docker compose logs -f
```

---

### 如何卸载

进入安装目录后，先执行：

```bash
docker compose down
```

然后直接删除整个安装目录即可。

因为这个启动器会把相关内容都放在这个本地目录里，包括：

- `compose.yaml`
- `.env`
- `data/`

---

### 说明

- 启动器使用的公开镜像是 `ernestyu/openclaw-patched:latest`
- Web UI 模式会绑定 `http://localhost:3060`
- Headless 模式不暴露端口
- 持久化数据保存在 `./data`
- 整个启动器保持轻量、简单、易理解

---

### 许可证

MIT，见 `LICENSE`。

---

### 贡献

提交 PR 前请先阅读 `CONTRIBUTING.md`。

---

### 安全

报告安全问题前请先阅读 `SECURITY.md`。
