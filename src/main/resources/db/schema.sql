-- 课程表
CREATE TABLE IF NOT EXISTS courses (
    id VARCHAR(36) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    instructor_id VARCHAR(50),
    instructor_name VARCHAR(100),
    instructor_email VARCHAR(100),
    schedule_day_of_week VARCHAR(20),
    schedule_start_time VARCHAR(20),
    schedule_end_time VARCHAR(20),
    schedule_expected_attendance INT,
    capacity INT NOT NULL,
    enrolled INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL
);

-- 学生表
CREATE TABLE IF NOT EXISTS students (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    major VARCHAR(100) NOT NULL,
    grade INT NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL
);

-- 选课记录表
CREATE TABLE IF NOT EXISTS enrollments (
    id VARCHAR(36) PRIMARY KEY,
    course_id VARCHAR(36) NOT NULL,
    student_id VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    enrolled_at TIMESTAMP NOT NULL,
    CONSTRAINT uk_course_student UNIQUE (course_id, student_id)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_course_code ON courses(code);

CREATE INDEX IF NOT EXISTS idx_student_id_students ON students(student_id);
CREATE INDEX IF NOT EXISTS idx_email ON students(email);
CREATE INDEX IF NOT EXISTS idx_major ON students(major);
CREATE INDEX IF NOT EXISTS idx_grade ON students(grade);

CREATE INDEX IF NOT EXISTS idx_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_student_id_enrollments ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_status ON enrollments(status);
CREATE INDEX IF NOT EXISTS idx_enrolled_at ON enrollments(enrolled_at);
