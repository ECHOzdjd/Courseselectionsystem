# Docker 虚拟机部署指南

本指南说明如何在安装了 Docker 的虚拟机上部署校园选课系统。

## 前置条件

### 虚拟机要求
- **操作系统**: Ubuntu 20.04+ / CentOS 7+ / Debian 10+
- **内存**: 至少 2GB RAM（推荐 4GB）
- **磁盘**: 至少 10GB 可用空间
- **网络**: 可访问互联网（用于拉取镜像）

### 已安装软件
- Docker 20.10+
- Docker Compose 2.0+
- Git（用于克隆项目）

### 检查 Docker 安装

```bash
# 检查 Docker 版本
docker --version

# 检查 Docker Compose 版本
docker compose version

# 测试 Docker 是否正常工作
docker run hello-world
```

## 部署步骤

### 步骤 1：将项目传输到虚拟机

有三种方式将项目传输到虚拟机：

#### 方式 1：使用 Git（推荐）

在虚拟机上执行：
```bash
# 克隆项目
git clone <你的仓库地址>
cd Courseselectionsystem

# 或者如果已经推送到 GitHub
git clone https://github.com/your-username/Courseselectionsystem.git
cd Courseselectionsystem
```

#### 方式 2：使用 SCP/SFTP

在 Windows 主机上执行：
```powershell
# 使用 SCP 传输项目
scp -r D:\Courseselectionsystem user@vm-ip:/home/user/

# 或使用 WinSCP、FileZilla 等图形工具上传
```

#### 方式 3：使用共享文件夹

##### VMware 共享文件夹（推荐）

**在 VMware 中设置共享文件夹**：
1. 虚拟机 → 设置 → 选项 → 共享文件夹
2. 启用共享文件夹
3. 添加共享路径：`D:\` 或 `D:\Courseselectionsystem`
4. 设置名称：例如 `workspace`

**在虚拟机中访问**：
```bash
# 安装 VMware Tools（如果未安装）
# Ubuntu/Debian
sudo apt-get install open-vm-tools

# CentOS/RHEL
sudo yum install open-vm-tools

# 挂载共享文件夹
sudo mkdir -p /mnt/hgfs
sudo mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other

# 或者使用 vmhgfs-fuse（较新版本）
sudo /usr/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other

# 查看共享文件夹
ls /mnt/hgfs/

# 复制项目到本地
cp -r /mnt/hgfs/workspace/Courseselectionsystem /home/user/
cd /home/user/Courseselectionsystem

# 或者直接在共享文件夹中工作（不推荐，性能较差）
cd /mnt/hgfs/workspace/Courseselectionsystem
```

**设置自动挂载（可选）**：
```bash
# 编辑 /etc/fstab
sudo nano /etc/fstab

# 添加以下行
.host:/ /mnt/hgfs fuse.vmhgfs-fuse allow_other 0 0

# 测试挂载
sudo mount -a
```

##### VirtualBox 共享文件夹

```bash
# 在虚拟机中挂载共享文件夹
sudo mount -t vboxsf shared_folder /mnt/shared

# 复制项目
cp -r /mnt/shared/Courseselectionsystem /home/user/
cd /home/user/Courseselectionsystem
```

### 步骤 2：验证项目文件

确保以下关键文件存在：
```bash
ls -la
# 应该看到：
# - Dockerfile
# - docker-compose.yml
# - .dockerignore
# - pom.xml
# - src/
```

### 步骤 3：配置防火墙（如果需要）

```bash
# Ubuntu/Debian
sudo ufw allow 8080/tcp
sudo ufw allow 3306/tcp

# CentOS/RHEL
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp
sudo firewall-cmd --reload
```

### 步骤 4：构建镜像

```bash
# 确保在项目根目录
cd /path/to/Courseselectionsystem

# 构建镜像（首次构建可能需要 5-10 分钟）
docker compose build

# 查看构建的镜像
docker images | grep coursehub
```

**预期输出**：
```
REPOSITORY          TAG       IMAGE ID       CREATED          SIZE
coursehub          latest    xxxxxxxxxxxxx  2 minutes ago    180MB
```

### 步骤 5：启动服务

```bash
# 启动所有服务（后台运行）
docker compose up -d

# 查看服务状态
docker compose ps

# 查看启动日志
docker compose logs -f
```

**预期输出**：
```
NAME                IMAGE             STATUS              PORTS
coursehub-app       coursehub:latest  Up (healthy)        0.0.0.0:8080->8080/tcp
coursehub-mysql     mysql:8           Up (healthy)        0.0.0.0:3306->3306/tcp
```

### 步骤 6：等待服务就绪

MySQL 和应用启动需要时间：
```bash
# 持续监控日志，直到看到 "Started CourseApplication"
docker compose logs -f app

# 或使用健康检查
docker compose ps
# 等待 STATUS 列显示 "Up (healthy)"
```

### 步骤 7：测试应用

```bash
# 测试健康检查
curl http://localhost:8080/health

# 测试数据库连接
curl http://localhost:8080/health/db

# 测试 API
curl http://localhost:8080/api/courses
```

### 步骤 8：运行自动化测试

```bash
# 赋予脚本执行权限
chmod +x scripts/docker-test.sh

# 运行测试
./scripts/docker-test.sh
```

## 访问应用

### 在虚拟机内部访问
```bash
curl http://localhost:8080/api/courses
```

### 从主机访问虚拟机

1. **获取虚拟机 IP 地址**：
   ```bash
   # 在虚拟机中执行
   ip addr show
   # 或
   hostname -I
   ```

2. **从 Windows 主机访问**：
   ```powershell
   # 假设虚拟机 IP 是 192.168.56.101
   curl http://192.168.56.101:8080/health
   
   # 或在浏览器中打开
   # http://192.168.56.101:8080/api/courses
   ```

3. **配置网络模式**：
   
   **VMware 网络配置**：
   
   a) **NAT 模式**（默认）：
   - 虚拟机可以访问外网
   - 需要配置端口转发才能从主机访问
   
   配置 NAT 端口转发：
   ```bash
   # 方式1：使用 VMware 虚拟网络编辑器
   # 编辑 → 虚拟网络编辑器 → 选择 VMnet8 (NAT) → NAT 设置 → 添加
   # 主机端口：8080 → 虚拟机IP:8080
   # 主机端口：3306 → 虚拟机IP:3306
   ```
   然后在 Windows 访问：`http://localhost:8080`
   
   b) **桥接模式**（推荐用于开发）：
   - 虚拟机设置 → 网络适配器 → 桥接模式
   - 虚拟机获得与主机同网段的 IP
   - 可以直接访问，无需端口转发
   - 获取虚拟机 IP 后直接访问：`http://192.168.x.x:8080`
   
   c) **仅主机模式**（Host-Only）：
   - 虚拟机设置 → 网络适配器 → 仅主机模式 (VMnet1)
   - 虚拟机只能与主机通信
   - 默认网段：192.168.xxx.xxx
   - 直接使用虚拟机 IP 访问
   
   **VirtualBox 端口转发**：
   - 打开虚拟机设置 → 网络 → 高级 → 端口转发
   - 添加规则：
     - 名称：HTTP, 主机端口：8080, 子系统端口：8080
     - 名称：MySQL, 主机端口：3306, 子系统端口：3306

4. **测试连接**：
   ```powershell
   # 在 Windows 上测试
   # 使用 curl
   curl http://虚拟机IP:8080/health
   
   # 或使用浏览器
   # http://虚拟机IP:8080/api/courses
   
   # 测试端口连通性
   Test-NetConnection -ComputerName 虚拟机IP -Port 8080
   ```

## 常用管理命令

### 查看状态
```bash
# 查看所有容器
docker compose ps

# 查看镜像
docker images

# 查看网络
docker network ls

# 查看数据卷
docker volume ls
```

### 日志管理
```bash
# 查看应用日志
docker compose logs app

# 查看 MySQL 日志
docker compose logs mysql

# 实时跟踪日志
docker compose logs -f app

# 查看最近 100 行
docker compose logs --tail=100 app
```

### 服务管理
```bash
# 停止服务
docker compose stop

# 启动服务
docker compose start

# 重启服务
docker compose restart

# 停止并删除容器（保留数据）
docker compose down

# 停止并删除所有内容（包括数据）
docker compose down -v
```

### 进入容器
```bash
# 进入应用容器
docker exec -it coursehub-app bash

# 进入 MySQL 容器
docker exec -it coursehub-mysql bash

# 直接连接 MySQL
docker exec -it coursehub-mysql mysql -uroot -pwywywy678 course_db
```

## 数据持久化验证

测试数据是否在容器重启后保留：

```bash
# 1. 创建测试数据
curl -X POST http://localhost:8080/api/courses \
  -H "Content-Type: application/json" \
  -d '{
    "code":"TEST101",
    "title":"Test Course",
    "capacity":50,
    "instructor":{"id":"T001","name":"Test","department":"CS","email":"test@test.com"},
    "schedule":{"dayOfWeek":"MONDAY","startTime":"10:00","endTime":"12:00","location":"Room 101"}
  }'

# 2. 记录课程 ID
COURSE_ID=$(curl -s http://localhost:8080/api/courses | jq -r '.data[-1].id')
echo "Course ID: $COURSE_ID"

# 3. 停止容器
docker compose down

# 4. 重新启动
docker compose up -d

# 5. 等待服务就绪（约30秒）
sleep 30

# 6. 验证数据仍存在
curl http://localhost:8080/api/courses/$COURSE_ID
```

## 故障排查

### 问题 1：Docker 命令权限错误

```bash
# 错误信息：permission denied while trying to connect to the Docker daemon socket
# 解决方案：将用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录或执行
newgrp docker

# 验证
docker ps
```

### 问题 2：端口已被占用

```bash
# 检查端口占用
sudo netstat -tlnp | grep 8080
sudo netstat -tlnp | grep 3306

# 或使用 lsof
sudo lsof -i :8080
sudo lsof -i :3306

# 停止占用端口的进程
sudo kill -9 <PID>
```

### 问题 3：磁盘空间不足

```bash
# 查看磁盘使用情况
df -h

# 清理 Docker 未使用的资源
docker system prune -a

# 清理数据卷
docker volume prune
```

### 问题 4：镜像拉取失败

```bash
# 配置 Docker 镜像加速（中国大陆用户）
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}
EOF

# 重启 Docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 问题 5：容器无法启动

```bash
# 查看详细错误日志
docker compose logs app
docker compose logs mysql

# 查看容器状态
docker compose ps -a

# 检查健康检查状态
docker inspect coursehub-app | grep -A 10 Health
docker inspect coursehub-mysql | grep -A 10 Health
```

### 问题 6：网络连接问题

```bash
# 测试容器间网络连通性
docker exec -it coursehub-app ping mysql

# 测试 DNS 解析
docker exec -it coursehub-app nslookup mysql

# 检查网络配置
docker network inspect coursehub-network
```

## 性能监控

### 查看资源使用情况
```bash
# 实时监控所有容器
docker stats

# 监控特定容器
docker stats coursehub-app coursehub-mysql
```

### 查看容器详细信息
```bash
# 应用容器信息
docker inspect coursehub-app

# MySQL 容器信息
docker inspect coursehub-mysql
```

## 备份与恢复

### 备份数据库
```bash
# 备份到文件
docker exec coursehub-mysql mysqldump -uroot -pwywywy678 course_db > backup_$(date +%Y%m%d).sql

# 备份到容器外
docker exec coursehub-mysql mysqldump -uroot -pwywywy678 course_db | gzip > backup_$(date +%Y%m%d).sql.gz
```

### 恢复数据库
```bash
# 从备份恢复
docker exec -i coursehub-mysql mysql -uroot -pwywywy678 course_db < backup.sql

# 从压缩备份恢复
gunzip < backup.sql.gz | docker exec -i coursehub-mysql mysql -uroot -pwywywy678 course_db
```

### 备份数据卷
```bash
# 备份数据卷到 tar 文件
docker run --rm \
  -v coursehub-mysql-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mysql-data-backup.tar.gz -C /data .
```

### 恢复数据卷
```bash
# 从 tar 文件恢复
docker run --rm \
  -v coursehub-mysql-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/mysql-data-backup.tar.gz -C /data
```

## 更新应用

### 更新代码并重新部署
```bash
# 1. 拉取最新代码
git pull origin main

# 2. 重新构建镜像
docker compose build --no-cache

# 3. 停止旧容器
docker compose down

# 4. 启动新容器
docker compose up -d

# 5. 验证更新
curl http://localhost:8080/health
```

## 卸载清理

### 完全清理所有资源
```bash
# 停止并删除容器
docker compose down

# 删除数据卷（⚠️ 会删除所有数据）
docker compose down -v

# 删除镜像
docker rmi coursehub:latest

# 删除网络
docker network rm coursehub-network

# 清理所有未使用的资源
docker system prune -a --volumes
```

## 安全建议

1. **修改默认密码**：
   编辑 `docker-compose.yml`，修改 MySQL 密码

2. **限制端口访问**：
   ```yaml
   ports:
     - "127.0.0.1:8080:8080"  # 只允许本地访问
   ```

3. **使用环境变量文件**：
   创建 `.env` 文件存储敏感信息：
   ```bash
   MYSQL_ROOT_PASSWORD=your_secure_password
   MYSQL_PASSWORD=your_secure_password
   ```

4. **定期更新镜像**：
   ```bash
   docker compose pull
   docker compose up -d
   ```

## 生产环境建议

1. **使用外部数据库**: 不要在生产环境使用容器化的 MySQL
2. **配置日志收集**: 使用 ELK 或其他日志系统
3. **添加监控**: 使用 Prometheus + Grafana
4. **配置 HTTPS**: 使用 Nginx 反向代理
5. **限制资源使用**: 在 docker-compose.yml 中设置资源限制

## 相关文档

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [项目 README](../README.md)
- [数据库配置指南](DATABASE_SETUP.md)

---

**最后更新**: 2025年11月16日
