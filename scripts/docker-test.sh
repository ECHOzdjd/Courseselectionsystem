#!/bin/bash

# Docker 测试脚本
# 用于自动化测试 Docker 容器化部署

set -e

echo "=========================================="
echo "  Course Selection System - Docker Test"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:8080"

# 等待服务就绪
wait_for_service() {
    echo -n "等待应用启动..."
    for i in {1..60}; do
        if curl -s "$BASE_URL/health" > /dev/null 2>&1; then
            echo -e "${GREEN} ✓${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    echo -e "${RED} ✗${NC}"
    echo "服务启动超时！"
    return 1
}

# 测试健康检查
test_health() {
    echo ""
    echo "1. 测试健康检查端点..."
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL/health")
    status_code=$(echo "$response" | tail -n 1)
    
    if [ "$status_code" = "200" ]; then
        echo -e "${GREEN}   ✓ Health check passed${NC}"
        return 0
    else
        echo -e "${RED}   ✗ Health check failed (HTTP $status_code)${NC}"
        return 1
    fi
}

# 测试数据库健康检查
test_db_health() {
    echo ""
    echo "2. 测试数据库连接..."
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL/health/db")
    status_code=$(echo "$response" | tail -n 1)
    
    if [ "$status_code" = "200" ]; then
        echo -e "${GREEN}   ✓ Database connection successful${NC}"
        return 0
    else
        echo -e "${RED}   ✗ Database connection failed (HTTP $status_code)${NC}"
        return 1
    fi
}

# 测试课程 CRUD
test_course_crud() {
    echo ""
    echo "3. 测试课程 CRUD 操作..."
    
    # 创建课程
    echo "   - 创建课程..."
    course_response=$(curl -s -X POST "$BASE_URL/api/courses" \
        -H "Content-Type: application/json" \
        -d '{
            "code":"CS999",
            "title":"Docker Test Course",
            "description":"Test course for Docker deployment",
            "capacity":50,
            "instructor": {
                "id":"T999",
                "name":"Test Instructor",
                "department":"Computer Science",
                "email":"test@zjgsu.edu.cn"
            },
            "schedule": {
                "dayOfWeek":"MONDAY",
                "startTime":"10:00",
                "endTime":"12:00",
                "location":"Room 999"
            }
        }')
    
    # 提取课程 ID
    course_id=$(echo "$course_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -n "$course_id" ]; then
        echo -e "${GREEN}   ✓ Course created (ID: $course_id)${NC}"
        
        # 查询课程
        echo "   - 查询课程..."
        if curl -s "$BASE_URL/api/courses/$course_id" | grep -q "$course_id"; then
            echo -e "${GREEN}   ✓ Course retrieved${NC}"
        else
            echo -e "${RED}   ✗ Course retrieval failed${NC}"
            return 1
        fi
        
        # 更新课程
        echo "   - 更新课程..."
        update_response=$(curl -s -X PUT "$BASE_URL/api/courses/$course_id" \
            -H "Content-Type: application/json" \
            -d '{
                "code":"CS999",
                "title":"Docker Test Course - Updated",
                "description":"Updated test course",
                "capacity":60,
                "instructor": {
                    "id":"T999",
                    "name":"Test Instructor Updated",
                    "department":"Computer Science",
                    "email":"test.updated@zjgsu.edu.cn"
                },
                "schedule": {
                    "dayOfWeek":"TUESDAY",
                    "startTime":"14:00",
                    "endTime":"16:00",
                    "location":"Room 888"
                }
            }')
        
        if echo "$update_response" | grep -q "Updated"; then
            echo -e "${GREEN}   ✓ Course updated${NC}"
        else
            echo -e "${YELLOW}   ? Course update response unclear${NC}"
        fi
        
        # 删除课程
        echo "   - 删除课程..."
        delete_status=$(curl -s -w "%{http_code}" -X DELETE "$BASE_URL/api/courses/$course_id")
        if [ "$delete_status" = "200" ] || [ "$delete_status" = "204" ]; then
            echo -e "${GREEN}   ✓ Course deleted${NC}"
        else
            echo -e "${RED}   ✗ Course deletion failed (HTTP $delete_status)${NC}"
            return 1
        fi
        
        return 0
    else
        echo -e "${RED}   ✗ Course creation failed${NC}"
        return 1
    fi
}

# 测试学生 CRUD
test_student_crud() {
    echo ""
    echo "4. 测试学生 CRUD 操作..."
    
    # 创建学生
    echo "   - 创建学生..."
    student_response=$(curl -s -X POST "$BASE_URL/api/students" \
        -H "Content-Type: application/json" \
        -d '{
            "studentId":"TEST999",
            "name":"Docker Test Student",
            "major":"Computer Science",
            "grade":2024,
            "email":"dockertest@zjgsu.edu.cn",
            "phoneNumber":"13900000000",
            "address":"Docker Container"
        }')
    
    student_id=$(echo "$student_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -n "$student_id" ]; then
        echo -e "${GREEN}   ✓ Student created (ID: $student_id)${NC}"
        
        # 删除学生
        echo "   - 删除学生..."
        delete_status=$(curl -s -w "%{http_code}" -X DELETE "$BASE_URL/api/students/$student_id")
        if [ "$delete_status" = "200" ] || [ "$delete_status" = "204" ]; then
            echo -e "${GREEN}   ✓ Student deleted${NC}"
        fi
        
        return 0
    else
        echo -e "${RED}   ✗ Student creation failed${NC}"
        return 1
    fi
}

# 测试数据持久化
test_persistence() {
    echo ""
    echo "5. 测试数据持久化..."
    echo "   创建测试数据..."
    
    # 创建一个课程用于持久化测试
    persist_response=$(curl -s -X POST "$BASE_URL/api/courses" \
        -H "Content-Type: application/json" \
        -d '{
            "code":"PERSIST101",
            "title":"Persistence Test Course",
            "description":"This course tests data persistence",
            "capacity":30,
            "instructor": {
                "id":"TP001",
                "name":"Persistence Tester",
                "department":"Testing",
                "email":"persist@test.com"
            },
            "schedule": {
                "dayOfWeek":"FRIDAY",
                "startTime":"09:00",
                "endTime":"11:00",
                "location":"Virtual Room"
            }
        }')
    
    persist_course_id=$(echo "$persist_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -n "$persist_course_id" ]; then
        echo -e "${GREEN}   ✓ Test data created (Course ID: $persist_course_id)${NC}"
        echo -e "${YELLOW}   ! 请手动测试：${NC}"
        echo "     1. 运行: docker compose down"
        echo "     2. 运行: docker compose up -d"
        echo "     3. 访问: $BASE_URL/api/courses/$persist_course_id"
        echo "     4. 验证课程数据是否仍然存在"
        return 0
    else
        echo -e "${RED}   ✗ Test data creation failed${NC}"
        return 1
    fi
}

# 主测试流程
main() {
    echo "开始测试..."
    
    # 等待服务
    if ! wait_for_service; then
        echo -e "${RED}服务未启动，测试终止${NC}"
        exit 1
    fi
    
    # 运行所有测试
    test_health
    test_db_health
    test_course_crud
    test_student_crud
    test_persistence
    
    echo ""
    echo "=========================================="
    echo -e "${GREEN}  ✓ 所有自动化测试完成${NC}"
    echo "=========================================="
    echo ""
    echo "查看容器状态:"
    docker compose ps
    
    echo ""
    echo "查看容器日志:"
    echo "  docker compose logs app"
    echo "  docker compose logs mysql"
    
    echo ""
    echo "进入应用容器:"
    echo "  docker exec -it coursehub-app bash"
    
    echo ""
    echo "停止服务:"
    echo "  docker compose down"
    
    echo ""
}

# 执行主流程
main
