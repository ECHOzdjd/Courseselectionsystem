# Docker 测试脚本 (PowerShell 版本)
# 用于自动化测试 Docker 容器化部署

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Course Selection System - Docker Test" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$BASE_URL = "http://localhost:8080"

# 等待服务就绪
function Wait-ForService {
    Write-Host "等待应用启动..." -NoNewline
    for ($i = 1; $i -le 60; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "$BASE_URL/health" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-Host " ✓" -ForegroundColor Green
                return $true
            }
        } catch {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 2
        }
    }
    Write-Host " ✗" -ForegroundColor Red
    Write-Host "服务启动超时！" -ForegroundColor Red
    return $false
}

# 测试健康检查
function Test-Health {
    Write-Host ""
    Write-Host "1. 测试健康检查端点..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "$BASE_URL/health" -Method GET
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✓ Health check passed" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "   ✗ Health check failed: $_" -ForegroundColor Red
        return $false
    }
}

# 测试数据库健康检查
function Test-DbHealth {
    Write-Host ""
    Write-Host "2. 测试数据库连接..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "$BASE_URL/health/db" -Method GET
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✓ Database connection successful" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "   ✗ Database connection failed: $_" -ForegroundColor Red
        return $false
    }
}

# 测试课程 CRUD
function Test-CourseCrud {
    Write-Host ""
    Write-Host "3. 测试课程 CRUD 操作..." -ForegroundColor Yellow
    
    # 创建课程
    Write-Host "   - 创建课程..."
    $courseBody = @{
        code = "CS999"
        title = "Docker Test Course"
        description = "Test course for Docker deployment"
        capacity = 50
        instructor = @{
            id = "T999"
            name = "Test Instructor"
            department = "Computer Science"
            email = "test@zjgsu.edu.cn"
        }
        schedule = @{
            dayOfWeek = "MONDAY"
            startTime = "10:00"
            endTime = "12:00"
            location = "Room 999"
        }
    } | ConvertTo-Json
    
    try {
        $createResponse = Invoke-RestMethod -Uri "$BASE_URL/api/courses" -Method POST -Body $courseBody -ContentType "application/json"
        $courseId = $createResponse.data.id
        Write-Host "   ✓ Course created (ID: $courseId)" -ForegroundColor Green
        
        # 查询课程
        Write-Host "   - 查询课程..."
        $getResponse = Invoke-RestMethod -Uri "$BASE_URL/api/courses/$courseId" -Method GET
        if ($getResponse.data.id -eq $courseId) {
            Write-Host "   ✓ Course retrieved" -ForegroundColor Green
        }
        
        # 更新课程
        Write-Host "   - 更新课程..."
        $updateBody = @{
            code = "CS999"
            title = "Docker Test Course - Updated"
            description = "Updated test course"
            capacity = 60
            instructor = @{
                id = "T999"
                name = "Test Instructor Updated"
                department = "Computer Science"
                email = "test.updated@zjgsu.edu.cn"
            }
            schedule = @{
                dayOfWeek = "TUESDAY"
                startTime = "14:00"
                endTime = "16:00"
                location = "Room 888"
            }
        } | ConvertTo-Json
        
        $updateResponse = Invoke-RestMethod -Uri "$BASE_URL/api/courses/$courseId" -Method PUT -Body $updateBody -ContentType "application/json"
        Write-Host "   ✓ Course updated" -ForegroundColor Green
        
        # 删除课程
        Write-Host "   - 删除课程..."
        Invoke-RestMethod -Uri "$BASE_URL/api/courses/$courseId" -Method DELETE
        Write-Host "   ✓ Course deleted" -ForegroundColor Green
        
        return $true
    } catch {
        Write-Host "   ✗ Course CRUD test failed: $_" -ForegroundColor Red
        return $false
    }
}

# 测试学生 CRUD
function Test-StudentCrud {
    Write-Host ""
    Write-Host "4. 测试学生 CRUD 操作..." -ForegroundColor Yellow
    
    # 创建学生
    Write-Host "   - 创建学生..."
    $studentBody = @{
        studentId = "TEST999"
        name = "Docker Test Student"
        major = "Computer Science"
        grade = 2024
        email = "dockertest@zjgsu.edu.cn"
        phoneNumber = "13900000000"
        address = "Docker Container"
    } | ConvertTo-Json
    
    try {
        $createResponse = Invoke-RestMethod -Uri "$BASE_URL/api/students" -Method POST -Body $studentBody -ContentType "application/json"
        $studentId = $createResponse.data.id
        Write-Host "   ✓ Student created (ID: $studentId)" -ForegroundColor Green
        
        # 删除学生
        Write-Host "   - 删除学生..."
        Invoke-RestMethod -Uri "$BASE_URL/api/students/$studentId" -Method DELETE
        Write-Host "   ✓ Student deleted" -ForegroundColor Green
        
        return $true
    } catch {
        Write-Host "   ✗ Student CRUD test failed: $_" -ForegroundColor Red
        return $false
    }
}

# 测试数据持久化
function Test-Persistence {
    Write-Host ""
    Write-Host "5. 测试数据持久化..." -ForegroundColor Yellow
    Write-Host "   创建测试数据..."
    
    $persistBody = @{
        code = "PERSIST101"
        title = "Persistence Test Course"
        description = "This course tests data persistence"
        capacity = 30
        instructor = @{
            id = "TP001"
            name = "Persistence Tester"
            department = "Testing"
            email = "persist@test.com"
        }
        schedule = @{
            dayOfWeek = "FRIDAY"
            startTime = "09:00"
            endTime = "11:00"
            location = "Virtual Room"
        }
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$BASE_URL/api/courses" -Method POST -Body $persistBody -ContentType "application/json"
        $courseId = $response.data.id
        Write-Host "   ✓ Test data created (Course ID: $courseId)" -ForegroundColor Green
        Write-Host "   ! 请手动测试：" -ForegroundColor Yellow
        Write-Host "     1. 运行: docker compose down"
        Write-Host "     2. 运行: docker compose up -d"
        Write-Host "     3. 访问: $BASE_URL/api/courses/$courseId"
        Write-Host "     4. 验证课程数据是否仍然存在"
        return $true
    } catch {
        Write-Host "   ✗ Test data creation failed: $_" -ForegroundColor Red
        return $false
    }
}

# 主测试流程
function Main {
    Write-Host "开始测试..." -ForegroundColor Cyan
    
    # 等待服务
    if (-not (Wait-ForService)) {
        Write-Host "服务未启动，测试终止" -ForegroundColor Red
        exit 1
    }
    
    # 运行所有测试
    Test-Health
    Test-DbHealth
    Test-CourseCrud
    Test-StudentCrud
    Test-Persistence
    
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  ✓ 所有自动化测试完成" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "查看容器状态:" -ForegroundColor Yellow
    docker compose ps
    
    Write-Host ""
    Write-Host "查看容器日志:" -ForegroundColor Yellow
    Write-Host "  docker compose logs app"
    Write-Host "  docker compose logs mysql"
    
    Write-Host ""
    Write-Host "进入应用容器:" -ForegroundColor Yellow
    Write-Host "  docker exec -it coursehub-app bash"
    
    Write-Host ""
    Write-Host "停止服务:" -ForegroundColor Yellow
    Write-Host "  docker compose down"
    
    Write-Host ""
}

# 执行主流程
Main
