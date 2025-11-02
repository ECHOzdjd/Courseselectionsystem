-- Initialize data without Chinese characters to avoid encoding issues

USE course_db;

-- Clear existing data
TRUNCATE TABLE enrollments;
TRUNCATE TABLE students;
TRUNCATE TABLE courses;

-- Insert course data (using English)
INSERT INTO courses (id, code, title, instructor_id, instructor_name, instructor_email, 
                    schedule_day_of_week, schedule_start_time, schedule_end_time, schedule_expected_attendance,
                    capacity, enrolled, created_at) VALUES
('course-001', 'CS101', 'Introduction to Computer Science', 'T001', 'Prof. Zhang', 'zhang@zjgsu.edu.cn', 
 'Monday', '08:00', '10:00', 50, 50, 0, NOW()),
('course-002', 'MATH201', 'Advanced Mathematics', 'T002', 'Prof. Li', 'li@zjgsu.edu.cn', 
 'Tuesday', '10:00', '12:00', 60, 60, 0, NOW()),
('course-003', 'ENG301', 'College English', 'T003', 'Prof. Wang', 'wang@zjgsu.edu.cn', 
 'Wednesday', '14:00', '16:00', 45, 45, 0, NOW());

-- Insert student data (using English)
INSERT INTO students (id, student_id, name, major, grade, email, created_at) VALUES
('student-001', '2021001', 'Zhang San', 'Computer Science', 2021, 'zhangsan@student.zjgsu.edu.cn', NOW()),
('student-002', '2021002', 'Li Si', 'Software Engineering', 2021, 'lisi@student.zjgsu.edu.cn', NOW()),
('student-003', '2022001', 'Wang Wu', 'Information Security', 2022, 'wangwu@student.zjgsu.edu.cn', NOW()),
('student-004', '2022002', 'Zhao Liu', 'Artificial Intelligence', 2022, 'zhaoliu@student.zjgsu.edu.cn', NOW());

-- Insert enrollment data
INSERT INTO enrollments (id, course_id, student_id, status, enrolled_at) VALUES
('enrollment-001', 'course-001', '2021001', 'ACTIVE', NOW()),
('enrollment-002', 'course-001', '2021002', 'ACTIVE', NOW()),
('enrollment-003', 'course-002', '2021001', 'ACTIVE', NOW());

-- Update enrolled count
UPDATE courses SET enrolled = 2 WHERE id = 'course-001';
UPDATE courses SET enrolled = 1 WHERE id = 'course-002';

-- Verify data
SELECT 'Courses:' AS Info;
SELECT * FROM courses;
SELECT 'Students:' AS Info;
SELECT * FROM students;
SELECT 'Enrollments:' AS Info;
SELECT * FROM enrollments;
