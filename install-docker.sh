#!/bin/bash

# Docker & Docker Compose 一键安装脚本
# 支持：Ubuntu, Debian, CentOS, RHEL, Fedora

set -e

echo "🚀 开始安装 Docker 和 Docker Compose..."

# 检测 root 权限
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ 请使用 sudo 或以 root 用户运行此脚本"
    exit 1
fi

# 检测系统类型
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "❌ 无法检测操作系统类型"
    exit 1
fi

# 函数：安装 Docker
install_docker() {
    echo "📦 安装 Docker..."
    
    # 卸载旧版本
    echo "🧹 清理旧版本..."
    sudo apt-get remove docker docker-engine docker.io containerd runc 2>/dev/null || true
    sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true

    # 安装依赖
    echo "📋 安装依赖包..."
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        apt-get update
        apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        yum install -y yum-utils
    elif [[ "$OS" == *"Fedora"* ]]; then
        dnf install -y dnf-plugins-core
    fi

    # 添加 Docker GPG 密钥
    echo "🔑 添加 Docker GPG 密钥..."
    mkdir -p /etc/apt/keyrings 2>/dev/null || true
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || \
    curl -fsSL https://download.docker.com/linux/centos/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || \
    curl -fsSL https://download.docker.com/linux/fedora/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null

    # 添加 Docker 仓库
    echo "📦 添加 Docker 仓库..."
    if [[ "$OS" == *"Ubuntu"* ]]; then
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    elif [[ "$OS" == *"Debian"* ]]; then
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    elif [[ "$OS" == *"Fedora"* ]]; then
        dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    fi

    # 安装 Docker
    echo "⬇️ 安装 Docker 引擎..."
    if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Fedora"* ]]; then
        yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin || \
        dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

    # 启动并设置开机自启
    echo "🔧 启动 Docker 服务..."
    systemctl start docker
    systemctl enable docker
}

# 函数：安装 Docker Compose (独立版本)
install_docker_compose() {
    echo "📦 安装 Docker Compose..."
    
    # 获取最新版本
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # 下载并安装
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # 创建符号链接（可选）
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose 2>/dev/null || true
}

# 函数：配置用户组
configure_user_group() {
    echo "👥 配置用户组..."
    # 将当前用户加入 docker 组
    if [ ! -z "$SUDO_USER" ]; then
        usermod -aG docker $SUDO_USER
    else
        usermod -aG docker $(whoami)
    fi
}

# 函数：验证安装
verify_installation() {
    echo "✅ 验证安装..."
    
    # 检查 Docker
    if command -v docker &> /dev/null; then
        docker --version
    else
        echo "❌ Docker 安装失败"
        exit 1
    fi
    
    # 检查 Docker Compose
    if command -v docker-compose &> /dev/null; then
        docker-compose --version
    elif command -v docker compose &> /dev/null; then
        docker compose version
    else
        echo "❌ Docker Compose 安装失败"
        exit 1
    fi
}

# 执行安装
install_docker

# 安装独立版 Docker Compose（如果需要）
if ! command -v docker-compose &> /dev/null && ! command -v docker compose &> /dev/null; then
    install_docker_compose
fi

configure_user_group
verify_installation

echo "🎉 安装完成！"
echo "📋 请重新登录或运行 'newgrp docker' 使组变更生效"
echo "🔧 测试命令: docker ps && docker-compose --version"
