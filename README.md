## 📝 使用方法

### 1. 下载并运行脚本

```bash
# 下载脚本
curl -O https://raw.githubusercontent.com/your-repo/install-docker.sh

# 或者直接运行
bash <(curl -sSL https://raw.githubusercontent.com/lgdglgc/Docker-Docker-compose/install-docker.sh)

# 或者直接运行
bash <(curl -sSL https://raw.githubusercontent.com/your-repo/install-docker.sh)

# 或者本地保存后运行
chmod +x install-docker.sh
sudo ./install-docker.sh
```

## 🔍 安装后验证

```bash
# 验证 Docker 安装
docker --version
docker ps

# 验证 Docker Compose 安装
docker-compose --version
# 或者（新版本）
docker compose version

# 运行测试容器
docker run hello-world
```

## ⚠️ 注意事项

1. **权限问题**：安装后需要重新登录或运行 `newgrp docker` 来使组权限生效
2. **网络问题**：如果服务器在国内，可以考虑使用国内镜像源加速下载
3. **版本兼容**：脚本会自动安装最新稳定版，确保与你的系统兼容

## 🚀 国内用户加速版

对于国内服务器，可以使用以下加速安装：

```bash
# 使用国内镜像源安装
curl -sSL https://get.daocloud.io/docker | sh
sudo systemctl start docker
sudo systemctl enable docker

# 安装 Docker Compose
sudo curl -L "https://get.daocloud.io/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

选择适合你需求的脚本运行即可完成一键安装！
