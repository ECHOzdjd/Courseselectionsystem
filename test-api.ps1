# 完整 API 测试脚本

Write-Host "=== Course Selection System API Test ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:8080"

# 1. 健康检查
Write-Host "1. Health Check Tests" -ForegroundColor Yellow
Write-Host "Testing /health..."
curl.exe "$baseUrl/health"
Write-Host ""
Write-Host "Testing /health/db..."
curl.exe "$baseUrl/health/db"
Write-Host ""

# 2. 课程 CRUD 测试
Write-Host "2. Course CRUD Tests" -ForegroundColor Yellow
Write-Host "GET - List all courses..."
curl.exe "$baseUrl/api/courses"
Write-Host ""

Write-Host "POST - Create new course..."
curl.exe -X POST "$baseUrl/api/courses" -H "Content-Type: application/json" -d '{\"code\":\"CS102\",\"title\":\"Data Structure\",\"capacity\":60}'
Write-Host ""

Write-Host "GET - Get specific course..."
curl.exe "$baseUrl/api/courses/course-001"
Write-Host ""

Write-Host "PUT - Update course..."
curl.exe -X PUT "$baseUrl/api/courses/course-001" -H "Content-Type: application/json" -d '{\"code\":\"CS101\",\"title\":\"Intro to CS - Updated\",\"capacity\":55}'
Write-Host ""

# 3. 学生 CRUD 测试
Write-Host "3. Student CRUD Tests" -ForegroundColor Yellow
Write-Host "GET - List all students..."
curl.exe "$baseUrl/api/students"
Write-Host ""

Write-Host "POST - Create new student..."
curl.exe -X POST "$baseUrl/api/students" -H "Content-Type: application/json" -d '{\"studentId\":\"2023001\",\"name\":\"Test Student\",\"major\":\"Computer Science\",\"grade\":2023,\"email\":\"test@example.com\"}'
Write-Host ""

Write-Host "GET - Get specific student..."
curl.exe "$baseUrl/api/students/student-001"
Write-Host ""

# 4. 选课功能测试
Write-Host "4. Enrollment Tests" -ForegroundColor Yellow
Write-Host "GET - List all enrollments..."
curl.exe "$baseUrl/api/enrollments"
Write-Host ""

Write-Host "POST - Student enrolls in course..."
curl.exe -X POST "$baseUrl/api/enrollments" -H "Content-Type: application/json" -d '{\"courseId\":\"course-002\",\"studentId\":\"2021002\"}'
Write-Host ""

Write-Host "GET - Get enrollments by course..."
curl.exe "$baseUrl/api/enrollments/course/course-001"
Write-Host ""

Write-Host "GET - Get enrollments by student..."
curl.exe "$baseUrl/api/enrollments/student/2021001"
Write-Host ""

Write-Host "DELETE - Student drops course..."
curl.exe -X DELETE "$baseUrl/api/enrollments/enrollment-003"
Write-Host ""

Write-Host ""
Write-Host "=== Test Completed ===" -ForegroundColor Green
