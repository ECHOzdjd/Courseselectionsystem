# 数据库配置与初始化指南

## 数据库环境说明

本项目支持两种数据库环境：

- **开发环境 (dev)**：使用 H2 内存数据库，无需额外安装
- **生产环境 (prod)**：使用 MySQL 8.0+，需要预先安装配置

## 环境切换

### 方式一：修改配置文件

编辑 `src/main/resources/application.yml`，修改 `spring.profiles.active` 值：

```yaml
spring:
  profiles:
    active: dev  # 开发环境使用 H2
    # active: prod  # 生产环境使用 MySQL
```

### 方式二：启动参数

使用 Maven 启动时指定环境：

```bash
# 开发环境
mvn spring-boot:run -Dspring-boot.run.profiles=dev

# 生产环境
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

使用 JAR 包启动时指定环境：

```bash
# 开发环境
java -jar target/wy-1.1.0.jar --spring.profiles.active=dev

# 生产环境
java -jar target/wy-1.1.0.jar --spring.profiles.active=prod
```

### 方式三：环境变量

Windows PowerShell：
```powershell
$env:SPRING_PROFILES_ACTIVE="dev"
java -jar target/wy-1.1.0.jar
```

Linux/Mac：
```bash
export SPRING_PROFILES_ACTIVE=prod
java -jar target/wy-1.1.0.jar
```

## 开发环境配置（H2）

### 特点
- 内存数据库，无需安装
- 自动创建表结构
- 提供 Web 控制台
- 重启后数据清空

### 访问 H2 控制台

启动应用后，访问：http://localhost:8080/h2-console

连接信息：
- **JDBC URL**: `jdbc:h2:mem:course_db`
- **User Name**: `sa`
- **Password**: (留空)

### 数据初始化

开发环境会自动执行以下脚本：
- `src/main/resources/db/schema.sql` - 创建表结构
- `src/main/resources/db/data.sql` - 插入初始数据

## 生产环境配置（MySQL）

### 前置要求

1. 安装 MySQL 8.0 或更高版本
2. 确保 MySQL 服务正在运行

### 步骤一：创建数据库和用户

登录 MySQL：
```bash
mysql -u root -p
```

执行初始化脚本：
```sql
-- 执行项目提供的初始化脚本
source src/main/resources/db/init-mysql.sql
```

或者手动创建：
```sql
-- 创建数据库
CREATE DATABASE course_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户并授权（可选）
CREATE USER 'course_user'@'localhost' IDENTIFIED BY 'course_password';
GRANT ALL PRIVILEGES ON course_db.* TO 'course_user'@'localhost';
FLUSH PRIVILEGES;
```

### 步骤二：配置连接信息

编辑 `src/main/resources/application-prod.yml`，修改数据库连接信息：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/course_db?useSSL=false&serverTimezone=Asia/Shanghai
    username: root  # 修改为实际用户名
    password: root  # 修改为实际密码
```

### 步骤三：启动应用

```bash
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

## 数据库健康检查

项目提供了数据库连通性检查接口，用于验证数据库连接状态。

### 基本健康检查

```bash
curl http://localhost:8080/health
```

响应示例：
```json
{
  "code": 200,
  "message": "健康检查通过",
  "data": {
    "status": "UP",
    "message": "服务运行正常",
    "timestamp": "2025-11-02T10:30:00"
  }
}
```

### 数据库健康检查

```bash
curl http://localhost:8080/health/db
```

成功响应示例：
```json
{
  "code": 200,
  "message": "数据库健康检查通过",
  "data": {
    "status": "UP",
    "database": "H2",
    "version": "2.2.224",
    "url": "jdbc:h2:mem:course_db",
    "username": "SA",
    "message": "数据库连接正常",
    "timestamp": "2025-11-02T10:30:00"
  }
}
```

失败响应示例：
```json
{
  "code": 503,
  "message": "数据库连接异常",
  "data": {
    "status": "DOWN",
    "error": "java.sql.SQLException",
    "message": "Connection refused",
    "timestamp": "2025-11-02T10:30:00"
  }
}
```

## 数据库表结构

### courses（课程表）

| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| id | VARCHAR(36) | 课程唯一标识 | 主键 |
| code | VARCHAR(50) | 课程代码 | 唯一、非空 |
| title | VARCHAR(200) | 课程标题 | 非空 |
| instructor_id | VARCHAR(50) | 授课教师ID | |
| instructor_name | VARCHAR(100) | 授课教师姓名 | |
| instructor_email | VARCHAR(100) | 授课教师邮箱 | |
| schedule_day_of_week | VARCHAR(20) | 上课星期 | |
| schedule_start_time | VARCHAR(20) | 开始时间 | |
| schedule_end_time | VARCHAR(20) | 结束时间 | |
| schedule_expected_attendance | INT | 预期出勤人数 | |
| capacity | INT | 课程容量 | 非空 |
| enrolled | INT | 已选人数 | 非空，默认0 |
| created_at | DATETIME | 创建时间 | 非空 |

### students（学生表）

| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| id | VARCHAR(36) | 学生唯一标识 | 主键 |
| student_id | VARCHAR(50) | 学号 | 唯一、非空 |
| name | VARCHAR(100) | 姓名 | 非空 |
| major | VARCHAR(100) | 专业 | 非空 |
| grade | INT | 年级 | 非空 |
| email | VARCHAR(100) | 邮箱 | 唯一、非空 |
| created_at | DATETIME | 创建时间 | 非空 |

### enrollments（选课记录表）

| 字段 | 类型 | 说明 | 约束 |
|------|------|------|------|
| id | VARCHAR(36) | 选课记录唯一标识 | 主键 |
| course_id | VARCHAR(36) | 课程ID | 非空 |
| student_id | VARCHAR(50) | 学生学号 | 非空 |
| status | VARCHAR(20) | 选课状态 | 非空，默认ACTIVE |
| enrolled_at | DATETIME | 选课时间 | 非空 |

**选课状态枚举**：
- `ACTIVE`: 已选课（活跃状态）
- `DROPPED`: 已退课
- `COMPLETED`: 已完成

**唯一约束**：
- (course_id, student_id) - 同一学生不能重复选择同一门课程

## 常见问题

### 1. H2 控制台无法访问

确认 `application-dev.yml` 中已启用：
```yaml
spring:
  h2:
    console:
      enabled: true
```

### 2. MySQL 连接失败

- 检查 MySQL 服务是否启动
- 验证用户名密码是否正确
- 确认数据库 `course_db` 已创建
- 检查防火墙设置

### 3. 表结构未创建

生产环境需要手动执行 SQL 脚本：
```bash
mysql -u root -p course_db < src/main/resources/db/init-mysql.sql
```

### 4. 数据初始化失败

开发环境：检查 `schema.sql` 和 `data.sql` 语法是否正确
生产环境：确保 `ddl-auto` 设置为 `validate` 或 `none`

## 迁移到生产环境清单

- [ ] 安装并启动 MySQL 8.0+
- [ ] 创建数据库 `course_db`
- [ ] 执行初始化脚本 `init-mysql.sql`
- [ ] 修改 `application-prod.yml` 中的数据库连接信息
- [ ] 修改 `application.yml` 设置 `spring.profiles.active: prod`
- [ ] 测试数据库健康检查接口
- [ ] 验证 API 功能正常
- [ ] 配置数据库备份策略

## 下一步计划

1. **数据库迁移工具**：集成 Flyway 或 Liquibase 进行版本化管理
2. **连接池优化**：调整 HikariCP 参数以适应生产负载
3. **读写分离**：配置主从数据库以提升性能
4. **缓存层**：引入 Redis 缓存热点数据
5. **监控告警**：添加数据库性能监控和慢查询日志
