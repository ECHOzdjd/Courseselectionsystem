#!/bin/bash

echo "=== Docker Compose 诊断脚本 ==="
echo ""

echo "1. 检查容器状态："
docker compose ps

echo ""
echo "2. 检查 MySQL 容器日志（最后50行）："
docker compose logs --tail=50 mysql

echo ""
echo "3. 检查应用容器日志（最后50行）："
docker compose logs --tail=50 app

echo ""
echo "4. 检查 MySQL 容器详细状态："
docker inspect coursehub-mysql --format='{{json .State.Health}}' 2>/dev/null | python3 -m json.tool 2>/dev/null || docker inspect coursehub-mysql --format='{{json .State.Health}}'

echo ""
echo "5. 尝试手动连接 MySQL："
docker exec -it coursehub-mysql mysqladmin ping -h localhost -u root -pwywywy678 2>&1 || echo "MySQL 容器无法访问"

echo ""
echo "=== 诊断完成 ==="
