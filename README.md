# OpenClaw Docker

本工程提供 [OpenClaw](https://www.npmjs.com/package/openclaw) 的容器化部署方案，基于 Docker 与 Docker Compose，开箱即用地在容器内运行 OpenClaw Gateway 服务，并附带 Fish Shell 与 Starship 终端，方便在容器内进行交互式操作。

## 目录结构

```
docker/
├── Dockerfile          # 镜像构建脚本：Node.js + OpenClaw + Fish + Starship
├── docker-compose.yml  # 容器编排：端口映射、卷挂载、环境变量等
└── README.md           # 本说明文档
```

## 工程作用

- **封装运行环境**：以 `node:22-slim` 为基础镜像，预装 `openclaw` CLI，避免在宿主机上污染 Node.js 环境。
- **一键启动 Gateway**：容器启动后自动运行 `openclaw gateway`，对外暴露 `18789` 端口供调用。
- **开启 Docker 沙箱**：通过挂载宿主机的 `/var/run/docker.sock`，允许 OpenClaw 在容器内再调起 Docker 作为任务沙箱（Docker-in-Docker 模式）。
- **持久化工作目录与配置**：将 `~/work/openclaw/workspace` 与 `~/work/openclaw/config` 挂载到容器内，升级或重建容器时数据不丢失。
- **友好交互 Shell**：内置 Fish + Starship，进入容器后即可获得美观、可补全的终端体验。
- **Git HTTPS 改写**：自动将 `ssh://git@github.com/`、`git@github.com:` 改写为 `https://github.com/`，避免在容器中配置 SSH Key。

## 前置要求

- 宿主机已安装 [Docker Engine](https://docs.docker.com/engine/install/) 与 [Docker Compose v2](https://docs.docker.com/compose/)。
- 宿主机存在以下目录（首次启动前请自行创建）：
  - `~/work/openclaw/workspace` — OpenClaw 工作目录
  - `~/work/openclaw/config`    — OpenClaw 配置目录
- 宿主机 `18789` 端口空闲。

```bash
mkdir -p ~/work/openclaw/workspace ~/work/openclaw/config
```

## 端口 / 卷 / 环境变量一览

| 类型 | 宿主机 | 容器内 | 说明 |
| --- | --- | --- | --- |
| 端口 | `18789` | `18789` | OpenClaw Gateway 服务端口 |
| 卷   | `~/work/openclaw/workspace` | `/workspace` | 工作目录持久化 |
| 卷   | `~/work/openclaw/config`    | `/root/.openclaw` | 配置目录持久化 |
| 卷   | `/var/run/docker.sock`      | `/var/run/docker.sock` | 容器内调用宿主 Docker |

| 环境变量 | 值 | 作用 |
| --- | --- | --- |
| `OPENCLAW_SANDBOX` | `docker` | 启用 Docker 沙箱 |
| `OPENCLAW_SANDBOX_ALLOW_NETWORK` | `true` | 允许沙箱访问网络 |

## 使用方法

### 1. 构建并启动容器

首次运行需要加 `--build` 让镜像中的 Fish / OpenClaw 等依赖被安装：

```bash
docker compose up -d --build
```

后续若仅修改 `docker-compose.yml`，使用即可：

```bash
docker compose up -d
```

### 2. 查看容器状态

```bash
docker compose ps
```

`STATUS` 为 `Up` 即表示容器运行正常。

### 3. 进入容器

容器使用 Fish 作为交互 Shell：

```bash
docker exec -it openclaw fish
```

### 4. 停止 / 清理

```bash
docker compose down          # 停止并移除容器（保留卷）
docker compose down -v       # 同时移除匿名卷（持久化目录为宿主机路径，不受影响）
```

## 常见问题

- **容器反复重启**：`command` 中已通过 `tail -f /dev/null` 保持主进程常驻，如仍重启请用 `docker logs openclaw` 查看日志。
- **端口冲突**：修改 `docker-compose.yml` 中 `ports` 的宿主机端口后执行 `docker compose up -d --force-recreate`。
- **Docker 沙箱无法调用**：确认宿主机 `/var/run/docker.sock` 存在且当前用户对其可读写。
