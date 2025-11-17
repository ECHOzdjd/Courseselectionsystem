# Docker Compose 诊断脚本 - Windows PowerShell 版本

Write-Host "=== Docker Compose 诊断脚本 ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. 检查容器状态：" -ForegroundColor Yellow
docker compose ps

Write-Host ""
Write-Host "2. 检查 MySQL 容器日志（最后50行）：" -ForegroundColor Yellow
docker compose logs --tail=50 mysql

Write-Host ""
Write-Host "3. 检查应用容器日志（最后50行）：" -ForegroundColor Yellow
docker compose logs --tail=50 app

Write-Host ""
Write-Host "4. 检查 MySQL 容器详细状态：" -ForegroundColor Yellow
docker inspect coursehub-mysql --format='{{json .State.Health}}'

Write-Host ""
Write-Host "5. 尝试手动连接 MySQL：" -ForegroundColor Yellow
try {
    docker exec -it coursehub-mysql mysqladmin ping -h localhost -u root -pwywywy678
} catch {
    Write-Host "MySQL 容器无法访问" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== 诊断完成 ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "常见解决方案：" -ForegroundColor Green
Write-Host "1. 如果 MySQL 无法启动，尝试：docker compose down -v" -ForegroundColor White
Write-Host "2. 然后重新启动：docker compose up -d" -ForegroundColor White
Write-Host "3. 查看实时日志：docker compose logs -f mysql" -ForegroundColor White
