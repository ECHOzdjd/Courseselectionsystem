# 校园选课与教学资源管理平台

## 项目简介

这是一个基于Spring Boot开发的校园选课与教学资源管理平台，采用单体架构设计，提供完整的课程管理、学生管理和选课管理功能。

## 技术栈

- **后端框架**: Spring Boot 3.2.0
- **Java版本**: Java 17
- **数据存储**: 内存存储（ConcurrentHashMap）
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
- 学生选课和退课
- 课程容量限制
- 重复选课检查
- 选课记录查询

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

## 如何运行项目

### 环境要求
- Java 17 或更高版本
- Maven 3.6 或更高版本

### 运行步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd Courseselectionsystem
   ```

2. **编译项目**
   ```bash
   mvn clean compile
   ```

3. **运行项目**
   ```bash
   mvn spring-boot:run
   ```

4. **访问应用**
   - 应用将在 `http://localhost:8080` 启动
   - 可以使用Postman、Apifox或curl进行API测试

### 使用Maven打包
```bash
mvn clean package
java -jar target/wy-1.0.0.jar
```

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
2. **重复选课检查**: 同一学生不能重复选择同一门课程
3. **课程存在性检查**: 选课时必须验证课程是否存在
4. **学生验证**: 选课时必须验证学生是否存在
5. **级联更新**: 学生选课成功后，课程的enrolled字段自动增加
6. **学号唯一性**: 学生学号必须全局唯一
7. **邮箱格式验证**: 学生邮箱必须符合标准格式
8. **删除限制**: 有选课记录的学生不能删除

