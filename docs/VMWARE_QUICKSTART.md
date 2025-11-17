# VMware 虚拟机部署快速参考

## VMware 特定配置

### 网络配置（推荐桥接模式）

**配置步骤**：
1. 虚拟机 → 设置 → 网络适配器
2. 选择 **桥接模式**（直接连接到物理网络）
3. 点击确定
4. 启动虚拟机

**获取 IP 地址**：
```bash
# 在虚拟机中执行
ip addr show
# 或
hostname -I
# 记下 IP 地址，例如：192.168.1.100
```

**从 Windows 访问**：
```
http://192.168.1.100:8080/api/courses
```

### 共享文件夹配置

**1. 在 VMware 中设置**：
- 虚拟机 → 设置 → 选项 → 共享文件夹
- 启用共享文件夹
- 添加路径：`D:\Courseselectionsystem`
- 设置名称：`project`

**2. 安装 VMware Tools**（必需）：
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install open-vm-tools

# CentOS/RHEL
sudo yum install open-vm-tools
```

**3. 在虚拟机中访问**：
```bash
# 创建挂载点
sudo mkdir -p /mnt/hgfs

# 挂载共享文件夹
sudo /usr/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other

# 查看共享内容
ls /mnt/hgfs/

# 复制项目到本地
cp -r /mnt/hgfs/project /home/$(whoami)/Courseselectionsystem
cd /home/$(whoami)/Courseselectionsystem
```

**4. 设置自动挂载**（可选）：
```bash
# 编辑 fstab
sudo nano /etc/fstab

# 添加这行
.host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other,defaults 0 0

# 保存并测试
sudo mount -a
```

## 完整部署流程（VMware 桥接模式）

### 第 1 步：配置虚拟机网络
```
虚拟机设置 → 网络适配器 → 桥接模式 → 确定
```

### 第 2 步：传输项目文件
```bash
# 方式 A: 使用共享文件夹（见上方配置）
# 方式 B: 使用 SCP 从 Windows
scp -r D:\Courseselectionsystem user@虚拟机IP:/home/user/

# 方式 C: 使用 Git
git clone https://github.com/your-username/Courseselectionsystem.git
```

### 第 3 步：部署应用

#### 配置 Docker 镜像源（中国大陆用户必须）

```bash
# 创建或编辑 Docker 配置
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

添加以下内容：
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
```

重启 Docker：
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker

# 验证配置
docker info | grep -A 5 "Registry Mirrors"
```

#### 构建和启动服务

```bash
cd /home/user/Courseselectionsystem

# 方式 A: 使用标准 Dockerfile
docker compose build

# 方式 B: 如果上面失败，使用国内镜像版本
# docker compose -f docker-compose.yml build --build-arg DOCKERFILE=Dockerfile.cn

# 启动服务
docker compose up -d

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f app
```

### 第 4 步：在虚拟机中测试
```bash
# 等待服务启动（约30-60秒）
sleep 30

# 测试健康检查
curl http://localhost:8080/health

# 测试 API
curl http://localhost:8080/api/courses
```

### 第 5 步：从 Windows 访问
```powershell
# 获取虚拟机 IP（在虚拟机中执行）
hostname -I
# 假设得到：192.168.1.100

# 在 Windows 浏览器打开
http://192.168.1.100:8080/api/courses

# 或使用 PowerShell 测试
curl http://192.168.1.100:8080/health

# 使用 Postman 测试
# Base URL: http://192.168.1.100:8080
```

## 使用 NAT 模式（需要端口转发）

如果必须使用 NAT 模式：

**配置端口转发**：
1. 编辑 → 虚拟网络编辑器
2. 选择 VMnet8 (NAT)
3. 点击 "NAT 设置"
4. 添加端口转发：

| 类型 | 主机端口 | 虚拟机 IP | 虚拟机端口 |
|------|---------|----------|-----------|
| TCP  | 8080    | (虚拟机IP) | 8080    |
| TCP  | 3306    | (虚拟机IP) | 3306    |

5. 确定保存

**从 Windows 访问**：
```
http://localhost:8080/api/courses
```

## 常见问题

### 1. 找不到共享文件夹
```bash
# 确认 VMware Tools 已安装
vmware-toolbox-cmd -v

# 重新挂载
sudo /usr/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other

# 查看挂载状态
mount | grep hgfs
```

### 2. 无法从 Windows 访问虚拟机
```bash
# 检查虚拟机防火墙
sudo ufw status

# 如果防火墙开启，允许端口
sudo ufw allow 8080/tcp
sudo ufw allow 3306/tcp

# 检查服务是否运行
docker compose ps

# 检查虚拟机网络
ip addr show
ping 8.8.8.8  # 测试外网
```

### 3. Docker 权限问题
```bash
# 添加用户到 docker 组
sudo usermod -aG docker $USER

# 重新登录或执行
newgrp docker

# 验证
docker ps
```

### 4. 虚拟机性能慢
```bash
# 检查分配的资源
# VMware: 虚拟机 → 设置 → 硬件
# 推荐配置：
# - 处理器：2核
# - 内存：4GB
# - 磁盘：20GB

# 检查 Docker 资源使用
docker stats
```

### 5. Docker 镜像拉取失败（403 Forbidden）
```bash
# 问题：failed to resolve source metadata: 403 Forbidden
# 原因：Docker 镜像源不可用

# 解决方案：配置国内镜像源
sudo nano /etc/docker/daemon.json

# 添加以下内容：
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}

# 重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# 或使用国内镜像的 Dockerfile
# 项目中已提供 Dockerfile.cn（使用阿里云镜像）
```

## 快捷命令

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 查看日志
docker compose logs -f app

# 重启服务
docker compose restart

# 进入容器
docker exec -it coursehub-app bash

# 查看虚拟机 IP
hostname -I

# 测试连接
curl http://localhost:8080/health
```

## Postman 测试配置

**环境变量设置**：
```
变量名: baseUrl
初始值: http://虚拟机IP:8080
当前值: http://192.168.1.100:8080
```

**常用请求**：
- GET {{baseUrl}}/health
- GET {{baseUrl}}/health/db
- GET {{baseUrl}}/api/courses
- GET {{baseUrl}}/api/students
- GET {{baseUrl}}/api/enrollments

## 性能优化建议

1. **虚拟机资源分配**：
   - CPU: 2-4 核
   - 内存: 4-8 GB
   - 磁盘: 20-40 GB（精简分配）

2. **网络选择**：
   - 开发测试：桥接模式（性能最好）
   - 隔离环境：NAT 模式
   - 仅主机：Host-Only 模式

3. **磁盘优化**：
   - 使用 SSD 存储虚拟机
   - 定期清理 Docker：`docker system prune -a`

4. **关闭不必要的服务**：
   ```bash
   # 仅保留必要服务
   sudo systemctl disable bluetooth
   sudo systemctl disable cups
   ```

## 下一步

1. ✅ 配置网络（桥接模式）
2. ✅ 传输项目文件
3. ✅ 构建和启动服务
4. ✅ 从 Windows 访问测试
5. ✅ 运行 Postman 测试
6. ✅ 验证数据持久化

完整文档：[DOCKER_VM_DEPLOYMENT.md](DOCKER_VM_DEPLOYMENT.md)

---

**提示**：首次构建需要下载基础镜像和依赖，可能需要 5-10 分钟，请确保虚拟机有网络连接。
