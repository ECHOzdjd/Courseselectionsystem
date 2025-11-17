# Docker 虚拟机部署 - 快速开始

## 最简单的 3 步部署

### 1️⃣ 上传项目到虚拟机

```bash
# 方式 A: 使用 Git（推荐）
git clone https://github.com/your-username/Courseselectionsystem.git
cd Courseselectionsystem

# 方式 B: 使用 SCP 从 Windows 上传
# 在 Windows PowerShell 中执行：
scp -r D:\Courseselectionsystem user@vm-ip:/home/user/
```

### 2️⃣ 运行部署脚本

```bash
# 进入项目目录
cd /path/to/Courseselectionsystem

# 赋予脚本执行权限
chmod +x scripts/deploy-vm.sh

# 运行部署脚本（会自动完成所有步骤）
./scripts/deploy-vm.sh
```

### 3️⃣ 访问应用

```bash
# 在虚拟机内测试
curl http://localhost:8080/health

# 从 Windows 主机访问（假设虚拟机 IP 是 192.168.56.101）
# 在浏览器中打开: http://192.168.56.101:8080/api/courses
```

## 手动部署（如果自动脚本失败）

```bash
# 1. 检查 Docker
docker --version
docker compose version

# 2. 构建镜像
docker compose build

# 3. 启动服务
docker compose up -d

# 4. 查看状态
docker compose ps

# 5. 查看日志
docker compose logs -f app
```

## 常见问题快速解决

### 问题：Docker 权限错误
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### 问题：端口已占用
```bash
# 查看占用 8080 端口的进程
sudo lsof -i :8080
# 或
sudo netstat -tlnp | grep 8080

# 停止占用端口的进程
sudo kill -9 <PID>
```

### 问题：服务无法访问
```bash
# 检查防火墙
sudo ufw allow 8080/tcp

# 查看容器日志
docker compose logs app
docker compose logs mysql
```

## 完整文档

详细部署指南请查看: [DOCKER_VM_DEPLOYMENT.md](DOCKER_VM_DEPLOYMENT.md)

---

**提示**: 首次部署镜像构建可能需要 5-10 分钟，请耐心等待。
