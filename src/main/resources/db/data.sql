-- 初始化课程数据
INSERT INTO courses (id, code, title, instructor_id, instructor_name, instructor_email, 
                    schedule_day_of_week, schedule_start_time, schedule_end_time, schedule_expected_attendance,
                    capacity, enrolled, created_at) VALUES
('course-001', 'CS101', '计算机科学导论', 'T001', '张教授', 'zhang@zjgsu.edu.cn', 
 '星期一', '08:00', '10:00', 50, 50, 0, CURRENT_TIMESTAMP),
('course-002', 'MATH201', '高等数学', 'T002', '李教授', 'li@zjgsu.edu.cn', 
 '星期二', '10:00', '12:00', 60, 60, 0, CURRENT_TIMESTAMP),
('course-003', 'ENG301', '大学英语', 'T003', '王教授', 'wang@zjgsu.edu.cn', 
 '星期三', '14:00', '16:00', 45, 45, 0, CURRENT_TIMESTAMP);

-- 初始化学生数据
INSERT INTO students (id, student_id, name, major, grade, email, created_at) VALUES
('student-001', '2021001', '张三', '计算机科学', 2021, 'zhangsan@student.zjgsu.edu.cn', CURRENT_TIMESTAMP),
('student-002', '2021002', '李四', '软件工程', 2021, 'lisi@student.zjgsu.edu.cn', CURRENT_TIMESTAMP),
('student-003', '2022001', '王五', '信息安全', 2022, 'wangwu@student.zjgsu.edu.cn', CURRENT_TIMESTAMP),
('student-004', '2022002', '赵六', '人工智能', 2022, 'zhaoliu@student.zjgsu.edu.cn', CURRENT_TIMESTAMP);

-- 初始化选课记录数据
INSERT INTO enrollments (id, course_id, student_id, status, enrolled_at) VALUES
('enrollment-001', 'course-001', '2021001', 'ACTIVE', CURRENT_TIMESTAMP),
('enrollment-002', 'course-001', '2021002', 'ACTIVE', CURRENT_TIMESTAMP),
('enrollment-003', 'course-002', '2021001', 'ACTIVE', CURRENT_TIMESTAMP);

-- 更新课程的已选人数
UPDATE courses SET enrolled = 2 WHERE id = 'course-001';
UPDATE courses SET enrolled = 1 WHERE id = 'course-002';
