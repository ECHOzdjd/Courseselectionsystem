# 校园选课与教学资源管理平台

## 项目简介

这是一个基于Spring Boot开发的校园选课与教学资源管理平台，采用单体架构设计，提供完整的课程管理、学生管理和选课管理功能。

**当前版本**: v1.1.0 - 数据库持久化版本

## 版本历史

- **v1.1.0** (当前版本) - 数据库持久化
  - 集成 Spring Data JPA
  - 支持 H2 内存数据库（开发环境）
  - 支持 MySQL 8.0+（生产环境）
  - 添加事务管理
  - 数据库健康检查接口
  
- **v1.0.0** - 内存存储版本
  - 基础 REST API
  - 内存存储（ConcurrentHashMap）

## 技术栈

- **后端框架**: Spring Boot 3.2.0
- **Java版本**: Java 17
- **数据持久化**: Spring Data JPA
- **数据库**: 
  - 开发环境: H2 (内存数据库)
  - 生产环境: MySQL 8.0+
- **连接池**: HikariCP
- **构建工具**: Maven
- **API设计**: RESTful API

## 项目结构

```
src/
├── main/
│   ├── java/com/zjgsu/wy/courseselectionsystem/
│   │   ├── CourseApplication.java              # 启动类
│   │   ├── model/                             # 实体类
│   │   │   ├── Course.java                    # 课程实体
│   │   │   ├── Instructor.java                # 教师实体
│   │   │   ├── ScheduleSlot.java              # 课程时间安排实体
│   │   │   ├── Student.java                   # 学生实体
│   │   │   └── Enrollment.java                # 选课记录实体
│   │   ├── repository/                        # 数据访问层
│   │   │   ├── CourseRepository.java          # 课程数据访问
│   │   │   ├── StudentRepository.java         # 学生数据访问
│   │   │   └── EnrollmentRepository.java      # 选课记录数据访问
│   │   ├── service/                           # 业务逻辑层
│   │   │   ├── CourseService.java             # 课程业务逻辑
│   │   │   ├── StudentService.java            # 学生业务逻辑
│   │   │   └── EnrollmentService.java         # 选课业务逻辑
│   │   ├── controller/                        # 控制器层
│   │   │   ├── CourseController.java          # 课程控制器
│   │   │   ├── StudentController.java         # 学生控制器
│   │   │   └── EnrollmentController.java      # 选课控制器
│   │   ├── common/                            # 公共类
│   │   │   └── ApiResponse.java               # 统一响应格式
│   │   └── exception/                         # 异常处理
│   │       ├── GlobalExceptionHandler.java    # 全局异常处理器
│   │       ├── ResourceNotFoundException.java # 资源未找到异常
│   │       └── BusinessException.java         # 业务逻辑异常
│   └── resources/
│       └── application.yml                    # 配置文件
└── test/
```

## 功能特性

### 1. 课程管理
- 创建、查询、更新、删除课程
- 支持课程容量管理
- 自动生成课程ID

### 2. 学生管理
- 创建、查询、更新、删除学生
- 学号唯一性验证
- 邮箱格式验证
- 选课记录关联检查

### 3. 选课管理
- 学生选课和退课（事务管理）
- 课程容量限制
- 重复选课检查
- 选课记录查询
- 选课状态管理（ACTIVE/DROPPED/COMPLETED）

## 新增特性（v1.1.0）

### 数据持久化
- ✅ 使用 JPA/Hibernate 进行对象关系映射
- ✅ 支持 H2 内存数据库（开发环境）
- ✅ 支持 MySQL 数据库（生产环境）
- ✅ 多环境配置（dev/prod）

### 事务管理
- ✅ Service 层添加 `@Transactional` 支持
- ✅ 选课/退课操作原子性保证
- ✅ 数据一致性校验

### 数据库特性
- ✅ 自动建表（开发环境）
- ✅ 唯一索引约束
- ✅ 外键关联和级联操作
- ✅ 数据初始化脚本
- ✅ 数据库健康检查接口

### Repository 层增强
- ✅ 基于方法名的查询
- ✅ 自定义 JPQL 查询
- ✅ 分页和排序支持
- ✅ 统计查询功能

## API接口文档

### 课程管理API

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/courses` | 查询所有课程 |
| GET | `/api/courses/{id}` | 根据ID查询课程 |
| POST | `/api/courses` | 创建课程 |
| PUT | `/api/courses/{id}` | 更新课程 |
| DELETE | `/api/courses/{id}` | 删除课程 |

### 学生管理API

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/students` | 查询所有学生 |
| GET | `/api/students/{id}` | 根据ID查询学生 |
| POST | `/api/students` | 创建学生 |
| PUT | `/api/students/{id}` | 更新学生信息 |
| DELETE | `/api/students/{id}` | 删除学生 |

### 选课管理API

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/enrollments` | 查询所有选课记录 |
| GET | `/api/enrollments/{id}` | 根据ID查询选课记录 |
| POST | `/api/enrollments` | 学生选课 |
| DELETE | `/api/enrollments/{id}` | 学生退课 |
| GET | `/api/enrollments/course/{courseId}` | 按课程查询选课记录 |
| GET | `/api/enrollments/student/{studentId}` | 按学生查询选课记录 |

### 健康检查API

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/health` | 服务健康检查 |
| GET | `/health/db` | 数据库连通性检查 |

## 快速开始

### 环境要求
- Java 17 或更高版本
- Maven 3.6 或更高版本
- （生产环境）MySQL 8.0 或更高版本

### 开发环境运行（H2数据库）

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd Courseselectionsystem
   ```

2. **编译项目**
   ```bash
   mvn clean compile
   ```

3. **运行项目（开发模式）**
   ```bash
   mvn spring-boot:run
   ```
   
   或指定开发环境：
   ```bash
   mvn spring-boot:run -Dspring-boot.run.profiles=dev
   ```

4. **访问应用**
   - API 地址: http://localhost:8080
   - H2 控制台: http://localhost:8080/h2-console
     - JDBC URL: `jdbc:h2:mem:course_db`
     - Username: `sa`
     - Password: (留空)

### 生产环境运行（MySQL数据库）

1. **准备 MySQL 数据库**
   ```bash
   mysql -u root -p
   ```
   
   ```sql
   source src/main/resources/db/init-mysql.sql
   ```

2. **配置数据库连接**
   
   编辑 `src/main/resources/application-prod.yml`：
   ```yaml
   spring:
     datasource:
       url: jdbc:mysql://localhost:3306/course_db
       username: your_username
       password: your_password
   ```

3. **启动应用**
   ```bash
   mvn spring-boot:run -Dspring-boot.run.profiles=prod
   ```

4. **验证数据库连接**
   ```bash
   curl http://localhost:8080/health/db
   ```

### 使用Maven打包
```bash
mvn clean package
java -jar target/wy-1.1.0.jar --spring.profiles.active=dev
```

**详细的数据库配置说明请查看**: [数据库配置与初始化指南](docs/DATABASE_SETUP.md)

## 测试说明

项目包含完整的API测试文档（`test-api.http`），涵盖以下测试场景：

1. **完整的课程管理流程**
   - 创建3门不同的课程
   - 查询、更新、删除课程
   - 验证404错误处理

2. **选课业务流程**
   - 课程容量限制测试
   - 重复选课检查
   - 选课记录管理

3. **学生管理流程**
   - 学生CRUD操作
   - 学号唯一性验证
   - 邮箱格式验证
   - 选课记录关联检查

4. **错误处理**
   - 资源不存在处理
   - 参数验证错误
   - 业务逻辑错误

## 统一响应格式

所有API返回统一的JSON格式：

### 成功响应
```json
{
  "code": 200,
  "message": "Success",
  "data": { ... }
}
```

### 错误响应
```json
{
  "code": 404,
  "message": "Course not found",
  "data": null
}
```

## 业务规则

1. **课程容量限制**: 课程选课人数不能超过容量（capacity）
2. **重复选课检查**: 同一学生不能重复选择同一门课程（活跃状态）
3. **课程存在性检查**: 选课时必须验证课程是否存在
4. **学生验证**: 选课时必须验证学生是否存在
5. **级联更新**: 学生选课成功后，课程的enrolled字段自动增加
6. **学号唯一性**: 学生学号必须全局唯一
7. **邮箱唯一性**: 学生邮箱必须全局唯一
8. **邮箱格式验证**: 学生邮箱必须符合标准格式
9. **删除限制**: 有活跃选课记录的学生不能删除
10. **事务一致性**: 选课和退课操作具有原子性，失败时自动回滚
11. **选课状态管理**: 退课时不删除记录，而是将状态更新为 DROPPED

## 项目结构

```
src/
├── main/
│   ├── java/com/zjgsu/wy/courseselectionsystem/
│   │   ├── CourseApplication.java              # 启动类
│   │   ├── model/                             # 实体类（JPA实体）
│   │   │   ├── Course.java                    # 课程实体
│   │   │   ├── Instructor.java                # 教师嵌入式对象
│   │   │   ├── ScheduleSlot.java              # 课程时间安排嵌入式对象
│   │   │   ├── Student.java                   # 学生实体
│   │   │   ├── Enrollment.java                # 选课记录实体
│   │   │   └── EnrollmentStatus.java          # 选课状态枚举
│   │   ├── repository/                        # 数据访问层（JpaRepository）
│   │   │   ├── CourseRepository.java          # 课程数据访问
│   │   │   ├── StudentRepository.java         # 学生数据访问
│   │   │   └── EnrollmentRepository.java      # 选课记录数据访问
│   │   ├── service/                           # 业务逻辑层（事务管理）
│   │   │   ├── CourseService.java             # 课程业务逻辑
│   │   │   ├── StudentService.java            # 学生业务逻辑
│   │   │   └── EnrollmentService.java         # 选课业务逻辑
│   │   ├── controller/                        # 控制器层
│   │   │   ├── CourseController.java          # 课程控制器
│   │   │   ├── StudentController.java         # 学生控制器
│   │   │   ├── EnrollmentController.java      # 选课控制器
│   │   │   └── HomeController.java            # 首页和健康检查
│   │   ├── common/                            # 公共类
│   │   │   └── ApiResponse.java               # 统一响应格式
│   │   └── exception/                         # 异常处理
│   │       ├── GlobalExceptionHandler.java    # 全局异常处理器
│   │       ├── ResourceNotFoundException.java # 资源未找到异常
│   │       └── BusinessException.java         # 业务逻辑异常
│   └── resources/
│       ├── application.yml                    # 主配置文件
│       ├── application-dev.yml                # 开发环境配置（H2）
│       ├── application-prod.yml               # 生产环境配置（MySQL）
│       └── db/                                # 数据库脚本
│           ├── schema.sql                     # 表结构（H2）
│           ├── data.sql                       # 初始数据（H2）
│           └── init-mysql.sql                 # MySQL初始化脚本
└── docs/
    └── DATABASE_SETUP.md                      # 数据库配置指南
```

## 文档

- [数据库配置与初始化指南](docs/DATABASE_SETUP.md) - 详细的数据库设置步骤
- [API 测试文档](test-api.http) - 完整的API测试用例
- [Postman Collection](postman_collection.json) - Postman API 集合

## 测试

### 运行测试

```bash
mvn test
```

### API 测试

项目包含完整的API测试文档（`test-api.http`），涵盖以下测试场景：

1. **完整的课程管理流程**
   - 创建3门不同的课程
   - 查询、更新、删除课程
   - 验证404错误处理

2. **选课业务流程**
   - 课程容量限制测试
   - 重复选课检查
   - 选课记录管理
   - 退课功能测试

3. **学生管理流程**
   - 学生CRUD操作
   - 学号唯一性验证
   - 邮箱格式验证
   - 选课记录关联检查

4. **错误处理**
   - 资源不存在处理
   - 参数验证错误
   - 业务逻辑错误

5. **数据库健康检查**
   - 服务健康状态
   - 数据库连接状态


**Type 类型**:
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具链相关

```


## 后续计划

### 短期目标
- [ ] 集成 Flyway 进行数据库版本管理
- [ ] 添加单元测试和集成测试
- [ ] 实现 API 文档自动生成（Swagger/OpenAPI）
- [ ] 添加日志记录和监控

### 中期目标
- [ ] 引入 Redis 缓存
- [ ] 实现数据库读写分离
- [ ] 添加用户认证和授权（Spring Security）
- [ ] 实现微服务架构迁移准备

### 长期目标
- [ ] 微服务拆分（课程服务、学生服务、选课服务）
- [ ] 服务注册与发现（Nacos/Eureka）
- [ ] API 网关集成
- [ ] 分布式事务处理

## 常见问题

### 1. 如何切换数据库环境？

参考 [数据库配置指南](docs/DATABASE_SETUP.md) 中的"环境切换"章节。

### 2. H2 控制台无法访问

确保应用使用开发环境配置启动：
```bash
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

### 3. MySQL 连接失败

- 检查 MySQL 服务是否运行
- 验证 `application-prod.yml` 中的连接信息
- 确认数据库 `course_db` 已创建

### 4. 表结构未创建

- 开发环境（H2）：自动创建，无需手动操作
- 生产环境（MySQL）：执行 `src/main/resources/db/init-mysql.sql`

---

**版本**: v1.1.0  
**最后更新**: 2025年11月2日

