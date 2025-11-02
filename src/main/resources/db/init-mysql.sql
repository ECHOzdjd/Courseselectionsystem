-- MySQL 生产环境数据库初始化脚本

-- 创建数据库
CREATE DATABASE IF NOT EXISTS course_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE course_db;

-- 课程表
CREATE TABLE IF NOT EXISTS courses (
    id VARCHAR(36) PRIMARY KEY COMMENT '课程唯一标识',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '课程代码',
    title VARCHAR(200) NOT NULL COMMENT '课程标题',
    instructor_id VARCHAR(50) COMMENT '授课教师ID',
    instructor_name VARCHAR(100) COMMENT '授课教师姓名',
    instructor_email VARCHAR(100) COMMENT '授课教师邮箱',
    schedule_day_of_week VARCHAR(20) COMMENT '上课星期',
    schedule_start_time VARCHAR(20) COMMENT '开始时间',
    schedule_end_time VARCHAR(20) COMMENT '结束时间',
    schedule_expected_attendance INT COMMENT '预期出勤人数',
    capacity INT NOT NULL COMMENT '课程容量',
    enrolled INT NOT NULL DEFAULT 0 COMMENT '已选人数',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_course_code (code),
    INDEX idx_instructor_id (instructor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程表';

-- 学生表
CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(36) PRIMARY KEY COMMENT '学生唯一标识',
    student_id VARCHAR(50) NOT NULL UNIQUE COMMENT '学号',
    name VARCHAR(100) NOT NULL COMMENT '姓名',
    major VARCHAR(100) NOT NULL COMMENT '专业',
    grade INT NOT NULL COMMENT '年级',
    email VARCHAR(100) NOT NULL UNIQUE COMMENT '邮箱',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_student_id (student_id),
    INDEX idx_email (email),
    INDEX idx_major (major),
    INDEX idx_grade (grade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生表';

-- 选课记录表
CREATE TABLE IF NOT EXISTS enrollments (
    id VARCHAR(36) PRIMARY KEY COMMENT '选课记录唯一标识',
    course_id VARCHAR(36) NOT NULL COMMENT '课程ID',
    student_id VARCHAR(50) NOT NULL COMMENT '学生学号',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '选课状态：ACTIVE-已选课, DROPPED-已退课, COMPLETED-已完成',
    enrolled_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '选课时间',
    CONSTRAINT uk_course_student UNIQUE (course_id, student_id),
    INDEX idx_course_id (course_id),
    INDEX idx_student_id (student_id),
    INDEX idx_status (status),
    INDEX idx_enrolled_at (enrolled_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='选课记录表';

-- 初始化课程数据
INSERT INTO courses (id, code, title, instructor_id, instructor_name, instructor_email, 
                    schedule_day_of_week, schedule_start_time, schedule_end_time, schedule_expected_attendance,
                    capacity, enrolled, created_at) VALUES
('course-001', 'CS101', '计算机科学导论', 'T001', '张教授', 'zhang@zjgsu.edu.cn', 
 '星期一', '08:00', '10:00', 50, 50, 0, NOW()),
('course-002', 'MATH201', '高等数学', 'T002', '李教授', 'li@zjgsu.edu.cn', 
 '星期二', '10:00', '12:00', 60, 60, 0, NOW()),
('course-003', 'ENG301', '大学英语', 'T003', '王教授', 'wang@zjgsu.edu.cn', 
 '星期三', '14:00', '16:00', 45, 45, 0, NOW());

-- 初始化学生数据
INSERT INTO students (id, student_id, name, major, grade, email, created_at) VALUES
('student-001', '2021001', '张三', '计算机科学', 2021, 'zhangsan@student.zjgsu.edu.cn', NOW()),
('student-002', '2021002', '李四', '软件工程', 2021, 'lisi@student.zjgsu.edu.cn', NOW()),
('student-003', '2022001', '王五', '信息安全', 2022, 'wangwu@student.zjgsu.edu.cn', NOW()),
('student-004', '2022002', '赵六', '人工智能', 2022, 'zhaoliu@student.zjgsu.edu.cn', NOW());

-- 初始化选课记录数据
INSERT INTO enrollments (id, course_id, student_id, status, enrolled_at) VALUES
('enrollment-001', 'course-001', '2021001', 'ACTIVE', NOW()),
('enrollment-002', 'course-001', '2021002', 'ACTIVE', NOW()),
('enrollment-003', 'course-002', '2021001', 'ACTIVE', NOW());

-- 更新课程的已选人数
UPDATE courses SET enrolled = 2 WHERE id = 'course-001';
UPDATE courses SET enrolled = 1 WHERE id = 'course-002';
