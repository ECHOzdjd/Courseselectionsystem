# 第05次作业完成总结

## 项目信息

- **项目名称**: 校园选课与教学资源管理平台
- **当前版本**: v1.1.0
- **Git 分支**: main
- **Git 标签**: coursehub-week-05
- **项目阶段**: 单体架构（数据库持久化）
- **基于版本**: v1.0.0（第 04 次作业）

## 完成内容概览

本次作业成功将项目从内存存储升级到数据库持久化方案，实现了以下核心目标：

### ✅ 任务一：项目依赖与配置

**完成内容**:
- 在 `pom.xml` 中添加了以下依赖：
  - `spring-boot-starter-data-jpa` - JPA 持久化框架
  - `mysql-connector-j` (runtime) - MySQL 驱动
  - `com.h2database:h2` (runtime) - H2 内存数据库
  - `spring-boot-starter-actuator` - 健康检查支持
- 版本号从 1.0.0 升级到 1.1.0

**配置文件**:
- `application.yml` - 主配置，默认激活 dev 环境
- `application-dev.yml` - H2 开发环境配置
  - 使用内存数据库
  - 启用 H2 控制台
  - `ddl-auto=update` 自动建表
  - `show-sql=true` 显示 SQL 日志
- `application-prod.yml` - MySQL 生产环境配置
  - HikariCP 连接池优化
  - `ddl-auto=validate` 验证表结构
  - 关闭 SQL 日志以提升性能

### ✅ 任务二：持久化建模

**实体类 JPA 注解**:

1. **Course (courses 表)**
   - 主键：`@Id` String id
   - 唯一索引：code (课程代码)
   - 嵌入式对象：`@Embedded` Instructor, ScheduleSlot
   - 字段约束：capacity、enrolled 非空
   - 生命周期：`@PrePersist` 自动设置创建时间和默认值

2. **Student (students 表)**
   - 主键：`@Id` String id
   - 唯一索引：student_id (学号), email (邮箱)
   - 普通索引：major (专业), grade (年级)
   - 验证注解：`@NotBlank`, `@Email`
   - 生命周期：`@PrePersist` 自动设置创建时间

3. **Enrollment (enrollments 表)**
   - 主键：`@Id` String id
   - 联合唯一约束：(course_id, student_id)
   - 索引：course_id, student_id, status, enrolled_at
   - 枚举字段：`@Enumerated(EnumType.STRING)` status
   - 生命周期：`@PrePersist` 自动设置选课时间和默认状态

4. **Instructor (@Embeddable)**
   - 作为 Course 的嵌入式对象
   - 字段：id, name, email

5. **ScheduleSlot (@Embeddable)**
   - 作为 Course 的嵌入式对象
   - 字段：dayOfWeek, startTime, endTime, expectedAttendance

6. **EnrollmentStatus (枚举)**
   - ACTIVE - 已选课（活跃）
   - DROPPED - 已退课
   - COMPLETED - 已完成

### ✅ 任务三：Repository 设计

所有 Repository 接口继承 `JpaRepository<T, String>`，并添加了业务查询方法：

**CourseRepository**:
- `findByCode(String code)` - 按课程代码查询
- `findByInstructorId(String instructorId)` - 按教师查询课程
- `findCoursesWithAvailableCapacity()` - 查询有剩余容量的课程
- `findByTitleContainingIgnoreCase(String keyword)` - 标题模糊查询
- `existsByCode(String code)` - 判断课程代码是否存在
- `countByInstructorId(String instructorId)` - 统计教师课程数

**StudentRepository**:
- `findByStudentId(String studentId)` - 按学号查询
- `findByEmail(String email)` - 按邮箱查询
- `existsByStudentId(String studentId)` - 判断学号是否存在
- `existsByEmail(String email)` - 判断邮箱是否存在
- `findByMajor(String major)` - 按专业查询
- `findByGrade(Integer grade)` - 按年级查询
- `findByMajorAndGrade(String major, Integer grade)` - 组合查询

**EnrollmentRepository**:
- `findByCourseId(String courseId)` - 按课程查询选课记录
- `findByStudentId(String studentId)` - 按学生查询选课记录
- `findByCourseIdAndStatus(...)` - 按课程和状态查询
- `findByStudentIdAndStatus(...)` - 按学生和状态查询
- `existsByCourseIdAndStudentId(...)` - 判断是否已选课（自定义JPQL）
- `countByCourseId(String courseId)` - 统计活跃选课人数（自定义JPQL）
- `countByStudentIdAndStatus(...)` - 统计学生活跃选课数

### ✅ 任务四：业务层重构

**事务管理**:
- 所有 Service 类添加 `@Transactional(readOnly = true)` 类级别注解
- 写操作方法添加 `@Transactional` 方法级别注解
- 确保选课、退课等操作的原子性和一致性

**业务逻辑优化**:
- 移除所有内存集合（ConcurrentHashMap）
- 改用 JpaRepository 进行数据访问
- 保留所有业务规则验证
- 增强错误处理，统一使用 `BusinessException` 和 `ResourceNotFoundException`

**新增功能**:
- `CourseService`: 添加 `searchByTitle()` 和 `findAvailableCourses()`
- `StudentService`: 添加 `findByMajor()` 和 `findByGrade()`
- `EnrollmentService`: 
  - 退课改为更新状态（DROPPED）而非删除记录
  - 添加按状态查询方法
  - 使用活跃选课人数进行容量检查

### ✅ 任务五：数据初始化与迁移

**初始化脚本**:

1. `src/main/resources/db/schema.sql` - H2 表结构
   - 创建 courses、students、enrollments 表
   - 定义索引和约束

2. `src/main/resources/db/data.sql` - H2 初始数据
   - 3 门课程
   - 4 个学生
   - 3 条选课记录

3. `src/main/resources/db/init-mysql.sql` - MySQL 完整初始化
   - 创建数据库 `course_db`
   - 创建表（包含注释）
   - 插入初始数据

**数据迁移策略**:
- 开发环境：自动执行 schema.sql 和 data.sql
- 生产环境：手动执行 init-mysql.sql

### ✅ 任务六：配置与部署验证

**健康检查接口**:

1. `/health` - 基本健康检查
   - 返回服务状态和时间戳

2. `/health/db` - 数据库连通性检查
   - 成功返回：数据库类型、版本、连接URL、用户名
   - 失败返回：错误类型、错误消息、HTTP 503



**验证方法**:
```bash
# 健康检查
curl http://localhost:8080/health
curl http://localhost:8080/health/db

# API 测试
curl http://localhost:8080/api/courses
curl http://localhost:8080/api/students
curl http://localhost:8080/api/enrollments
```

## 技术亮点

### 1. 多环境配置
- 开发和生产环境完全隔离
- 灵活的环境切换机制
- 针对不同环境的优化配置

### 2. 数据建模
- 合理使用 `@Embeddable` 嵌入式对象
- 完善的索引设计
- 枚举类型的正确使用
- 生命周期回调自动填充字段

### 3. Repository 层
- 遵循 Spring Data JPA 命名规范
- 自定义 JPQL 查询
- 复杂查询条件组合
- 统计和聚合查询

### 4. 事务管理
- 读写分离的事务策略
- 原子性操作保证
- 异常自动回滚

### 5. 业务规则增强
- 软删除选课记录（状态更新）
- 活跃选课人数统计
- 邮箱唯一性校验
- 删除前的关联检查

## 遇到的问题与解决方案

### 问题1: 选课记录删除导致数据丢失

**问题描述**: 
原始设计中退课直接删除 Enrollment 记录，导致无法追踪历史选课信息。

**解决方案**:
- 引入 `EnrollmentStatus` 枚举
- 退课操作改为状态更新（ACTIVE → DROPPED）
- 统计和查询时只计算 ACTIVE 状态的记录

### 问题2: 嵌入式对象的字段映射

**问题描述**:
Instructor 和 ScheduleSlot 作为嵌入式对象，字段名可能冲突。

**解决方案**:
使用 `@AttributeOverrides` 重命名数据库列：
```java
@AttributeOverride(name = "id", column = @Column(name = "instructor_id"))
```

### 问题3: 邮箱唯一性验证缺失

**问题描述**:
v1.0.0 只验证学号唯一性，未验证邮箱。

**解决方案**:
- 在 Student 实体添加 email 唯一约束
- 在 StudentService 添加邮箱重复检查
- 在 StudentRepository 添加 `existsByEmail()` 方法

## 测试结果

### 功能测试
- ✅ 课程 CRUD 操作
- ✅ 学生 CRUD 操作
- ✅ 选课和退课流程
- ✅ 容量限制验证
- ✅ 重复选课检查
- ✅ 唯一性约束验证
- ✅ 删除关联检查
- ✅ 事务回滚测试

### 数据库测试
- ✅ H2 自动建表和数据初始化
- ✅ H2 控制台访问
- ✅ MySQL 手动初始化
- ✅ 数据库健康检查接口
- ✅ 索引和约束验证
- ✅ 应用重启后数据持久化

### API 测试
- ✅ 所有接口正常响应
- ✅ 错误处理正确
- ✅ 统一响应格式
- ✅ HTTP 状态码正确

## 文档更新

### 新增文档
1. `docs/DATABASE_SETUP.md` - 完整的数据库配置指南
   - 环境切换详解
   - H2 和 MySQL 配置步骤
   - 健康检查使用说明
   - 表结构文档
   - 常见问题解答

2. `docs/ASSIGNMENT_05_SUMMARY.md` - 本作业总结文档

### 更新文档
1. `README.md` - 主文档大幅更新
   - 版本历史
   - 新增特性说明
   - 快速开始指南
   - 详细的项目结构
   - Git 提交规范
   - 后续计划路线图



## Git 提交记录示例

```bash
# 初始化数据库持久化
git commit -m "feat(persistence): add spring data jpa dependencies"

# 实体类改造
git commit -m "feat(model): add jpa annotations to entities"
git commit -m "feat(model): add EnrollmentStatus enum"

# Repository 层
git commit -m "refactor(repository): migrate to JpaRepository"
git commit -m "feat(repository): add custom query methods"

# Service 层
git commit -m "refactor(service): add transactional support"
git commit -m "fix(service): improve enrollment status management"

# 配置和脚本
git commit -m "feat(config): add multi-environment configuration"
git commit -m "feat(db): add database initialization scripts"

# 健康检查
git commit -m "feat(health): add database connectivity check endpoint"

# 文档
git commit -m "docs: update README with database setup guide"
git commit -m "docs: add comprehensive database configuration guide"

# 发布
git tag -a coursehub-week-05 -m "v1.1.0: Database persistence implementation"
```

## 下一步计划

### 第06次作业准备
1. **数据库版本管理**
   - 集成 Flyway
   - 版本化数据库迁移脚本

2. **测试覆盖**
   - 单元测试（Service 层）
   - 集成测试（Repository 层）
   - API 测试自动化

3. **API 文档**
   - 集成 Swagger/OpenAPI
   - 自动生成 API 文档

4. **日志和监控**
   - 结构化日志
   - 性能监控
   - 慢查询日志

### 微服务准备
1. 服务拆分规划
2. API 网关设计
3. 服务间通信方案
4. 分布式事务处理

## 总结

本次作业成功实现了从内存存储到数据库持久化的升级，主要成就包括：

1. **完整的 JPA 集成**: 实体映射、Repository 设计、事务管理
2. **多环境支持**: 开发和生产环境隔离，便于团队协作
3. **业务逻辑增强**: 软删除、状态管理、更完善的验证
4. **完善的文档**: 详细的配置指南和使用说明
5. **便捷的工具**: 启动脚本、健康检查接口

项目已具备生产环境部署的基础，为后续的微服务改造打下了坚实的数据层基础。

---

**完成时间**: 2025年11月2日  
**版本**: v1.1.0  
**作业**: 第05次 - 数据库持久化
