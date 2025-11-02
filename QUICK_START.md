# 快速参考指南

## 快速启动

### 开发环境（推荐用于快速测试）

```bash
# 方式1：使用启动脚本
run-dev.bat

# 方式2：使用Maven命令
mvn spring-boot:run

# 方式3：指定环境
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

**访问地址**:
- API: http://localhost:8080
- H2 控制台: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:course_db`
  - Username: `sa`
  - Password: (留空)

### 生产环境

```bash
# 1. 初始化MySQL数据库
mysql -u root -p < src/main/resources/db/init-mysql.sql

# 2. 配置连接信息
# 编辑 src/main/resources/application-prod.yml

# 3. 启动应用
run-prod.bat
# 或
mvn spring-boot:run "-Dspring-boot.run.profiles=prod"
```

## API 快速测试

### 健康检查

```bash
# 服务健康检查
curl http://localhost:8080/health

# 数据库健康检查
curl http://localhost:8080/health/db
```

### 课程管理

```bash
# 查询所有课程
curl http://localhost:8080/api/courses

# 查询单个课程
curl http://localhost:8080/api/courses/course-001

# 创建课程
curl -X POST http://localhost:8080/api/courses ^
  -H "Content-Type: application/json" ^
  -d "{\"code\":\"CS102\",\"title\":\"数据结构\",\"capacity\":60}"

# 更新课程
curl -X PUT http://localhost:8080/api/courses/course-001 ^
  -H "Content-Type: application/json" ^
  -d "{\"code\":\"CS101\",\"title\":\"计算机导论（更新）\",\"capacity\":55}"

# 删除课程
curl -X DELETE http://localhost:8080/api/courses/course-001
```

### 学生管理

```bash
# 查询所有学生
curl http://localhost:8080/api/students

# 创建学生
curl -X POST http://localhost:8080/api/students ^
  -H "Content-Type: application/json" ^
  -d "{\"studentId\":\"2023001\",\"name\":\"张三\",\"major\":\"计算机科学\",\"grade\":2023,\"email\":\"zhangsan@example.com\"}"

# 更新学生
curl -X PUT http://localhost:8080/api/students/student-001 ^
  -H "Content-Type: application/json" ^
  -d "{\"studentId\":\"2021001\",\"name\":\"张三（更新）\",\"major\":\"软件工程\",\"grade\":2021,\"email\":\"zhangsan.new@example.com\"}"

# 删除学生
curl -X DELETE http://localhost:8080/api/students/student-001
```

### 选课管理

```bash
# 查询所有选课记录
curl http://localhost:8080/api/enrollments

# 学生选课
curl -X POST http://localhost:8080/api/enrollments ^
  -H "Content-Type: application/json" ^
  -d "{\"courseId\":\"course-001\",\"studentId\":\"2021001\"}"

# 学生退课
curl -X DELETE http://localhost:8080/api/enrollments/enrollment-001

# 查询某课程的选课记录
curl http://localhost:8080/api/enrollments/course/course-001

# 查询某学生的选课记录
curl http://localhost:8080/api/enrollments/student/2021001
```

## 常用 SQL 查询

### H2 数据库（开发环境）

连接到 H2 控制台后执行：

```sql
-- 查询所有课程
SELECT * FROM COURSES;

-- 查询所有学生
SELECT * FROM STUDENTS;

-- 查询所有选课记录
SELECT * FROM ENROLLMENTS;

-- 查询课程及其选课人数
SELECT c.code, c.title, c.capacity, c.enrolled, 
       (SELECT COUNT(*) FROM ENROLLMENTS e WHERE e.course_id = c.id AND e.status = 'ACTIVE') as active_count
FROM COURSES c;

-- 查询学生的选课情况
SELECT s.student_id, s.name, c.code, c.title, e.status, e.enrolled_at
FROM ENROLLMENTS e
JOIN STUDENTS s ON e.student_id = s.student_id
JOIN COURSES c ON e.course_id = c.id
ORDER BY s.student_id, e.enrolled_at;
```

### MySQL 数据库（生产环境）

```sql
-- 连接数据库
USE course_db;

-- 查询所有课程及详细信息
SELECT id, code, title, instructor_name, capacity, enrolled, created_at
FROM courses
ORDER BY code;

-- 查询有剩余容量的课程
SELECT code, title, capacity, enrolled, (capacity - enrolled) as available
FROM courses
WHERE enrolled < capacity;

-- 查询学生的选课统计
SELECT s.student_id, s.name, s.major, s.grade,
       COUNT(CASE WHEN e.status = 'ACTIVE' THEN 1 END) as active_courses,
       COUNT(CASE WHEN e.status = 'DROPPED' THEN 1 END) as dropped_courses
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name, s.major, s.grade;

-- 查询课程的选课详情
SELECT c.code, c.title, c.capacity, c.enrolled,
       s.student_id, s.name, s.major, e.status, e.enrolled_at
FROM enrollments e
JOIN courses c ON e.course_id = c.id
JOIN students s ON e.student_id = s.student_id
ORDER BY c.code, e.enrolled_at;
```

## 环境变量配置

### Windows PowerShell

```powershell
# 设置开发环境
$env:SPRING_PROFILES_ACTIVE="dev"
java -jar target\wy-1.1.0.jar

# 设置生产环境
$env:SPRING_PROFILES_ACTIVE="prod"
java -jar target\wy-1.1.0.jar
```

### Linux/Mac

```bash
# 设置开发环境
export SPRING_PROFILES_ACTIVE=dev
java -jar target/wy-1.1.0.jar

# 设置生产环境
export SPRING_PROFILES_ACTIVE=prod
java -jar target/wy-1.1.0.jar
```

## 故障排查

### 1. 应用无法启动

```bash
# 检查日志
tail -f logs/spring.log

# 检查端口占用
netstat -ano | findstr :8080

# 检查 Java 版本
java -version  # 需要 Java 17+
```

### 2. 数据库连接失败

```bash
# 检查 MySQL 服务
# Windows
sc query MySQL80

# 测试连接
mysql -u root -p -e "SELECT 1"

# 检查数据库是否存在
mysql -u root -p -e "SHOW DATABASES LIKE 'course_db'"
```

### 3. H2 控制台无法访问

检查配置文件 `application-dev.yml`:
```yaml
spring:
  h2:
    console:
      enabled: true  # 确保为 true
```

### 4. API 返回 500 错误

```bash
# 检查数据库健康
curl http://localhost:8080/health/db

# 查看详细错误日志
# 日志位置: logs/spring.log 或控制台输出
```

## 性能优化建议

### 开发环境

```yaml
# application-dev.yml
spring:
  jpa:
    show-sql: true          # 显示 SQL
    properties:
      hibernate:
        format_sql: true    # 格式化 SQL
```

### 生产环境

```yaml
# application-prod.yml
spring:
  jpa:
    show-sql: false         # 关闭 SQL 日志
  datasource:
    hikari:
      maximum-pool-size: 20 # 根据实际负载调整
      minimum-idle: 10
```

## 项目结构速查

```
Courseselectionsystem/
├── src/main/
│   ├── java/.../courseselectionsystem/
│   │   ├── model/              # 实体类（JPA）
│   │   ├── repository/         # 数据访问（JpaRepository）
│   │   ├── service/            # 业务逻辑（事务管理）
│   │   ├── controller/         # REST API
│   │   ├── common/             # 统一响应
│   │   └── exception/          # 异常处理
│   └── resources/
│       ├── application.yml         # 主配置
│       ├── application-dev.yml     # 开发配置
│       ├── application-prod.yml    # 生产配置
│       └── db/                     # 数据库脚本
├── docs/                       # 文档
├── run-dev.bat                 # 开发环境启动
├── run-prod.bat                # 生产环境启动
├── package.bat                 # 打包脚本
├── pom.xml                     # Maven 配置
└── README.md                   # 项目说明
```

## 常用命令速查

```bash
# 清理编译
mvn clean compile

# 运行测试
mvn test

# 打包（跳过测试）
mvn clean package -DskipTests

# 查看依赖树
mvn dependency:tree

# 清理target目录
mvn clean

# 检查更新
mvn versions:display-dependency-updates
```

## 更多信息

- [完整文档](README.md)
- [数据库配置指南](docs/DATABASE_SETUP.md)
- [作业完成总结](docs/ASSIGNMENT_05_SUMMARY.md)
- [API 测试文档](test-api.http)

---

**快速获取帮助**: 
- 查看 README.md 的"常见问题"部分
- 查看 DATABASE_SETUP.md 的故障排查章节
- 检查应用日志输出
