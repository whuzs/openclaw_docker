FROM node:22-slim

# 安装依赖 + 配置Git + 安装OpenClaw + 安装Starship
RUN apt update && apt install -y git fish curl ca-certificates \
    && git config --global url."https://github.com/".insteadOf ssh://git@github.com/ \
    && git config --global url."https://github.com/".insteadOf git@github.com: \
    && npm install -g openclaw \
    && curl -sS https://starship.rs/install.sh | sh -s -- -y \
    && mkdir -p ~/.config \
    && echo 'add_newline = false' > ~/.config/starship.toml \
    # 配置Fish加载Starship
    && mkdir -p ~/.config/fish \
    && echo 'starship init fish | source' >> ~/.config/fish/config.fish \
    # 清理缓存
    && rm -rf /var/lib/apt/lists/*

SHELL ["/usr/bin/fish"]