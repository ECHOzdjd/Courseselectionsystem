package com.zjgsu.wy.courseselectionsystem.controller;

import com.zjgsu.wy.courseselectionsystem.common.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * 首页控制器
 */
@RestController
@CrossOrigin(origins = "*")
public class HomeController {
    
    @Autowired
    private DataSource dataSource;

    /**
     * 首页 - 显示API信息
     */
    @GetMapping("/")
    public ResponseEntity<ApiResponse<Map<String, Object>>> home() {
        Map<String, Object> data = new HashMap<>();
        data.put("application", "校园选课与教学资源管理平台");
        data.put("version", "1.1.0");
        data.put("author", "王勇");
        data.put("description", "基于Spring Boot的校园选课系统（数据库持久化版本）");
        
        Map<String, String> apis = new HashMap<>();
        apis.put("课程管理", "/api/courses");
        apis.put("学生管理", "/api/students");
        apis.put("选课管理", "/api/enrollments");
        apis.put("健康检查", "/health");
        apis.put("数据库健康检查", "/health/db");
        
        data.put("available_apis", apis);
        
        return ResponseEntity.ok(ApiResponse.success("欢迎使用校园选课与教学资源管理平台", data));
    }

    /**
     * 健康检查端点
     */
    @GetMapping("/health")
    public ResponseEntity<ApiResponse<Map<String, String>>> health() {
        Map<String, String> data = new HashMap<>();
        data.put("status", "UP");
        data.put("message", "服务运行正常");
        data.put("timestamp", java.time.LocalDateTime.now().toString());
        
        return ResponseEntity.ok(ApiResponse.success("健康检查通过", data));
    }
    
    /**
     * 数据库连通性健康检查
     */
    @GetMapping("/health/db")
    public ResponseEntity<ApiResponse<Map<String, Object>>> healthDb() {
        Map<String, Object> data = new HashMap<>();
        
        try (Connection connection = dataSource.getConnection()) {
            // 尝试获取数据库连接
            boolean isValid = connection.isValid(3); // 3秒超时
            
            if (isValid) {
                data.put("status", "UP");
                data.put("database", connection.getMetaData().getDatabaseProductName());
                data.put("version", connection.getMetaData().getDatabaseProductVersion());
                data.put("url", connection.getMetaData().getURL());
                data.put("username", connection.getMetaData().getUserName());
                data.put("message", "数据库连接正常");
                data.put("timestamp", java.time.LocalDateTime.now().toString());
                
                return ResponseEntity.ok(ApiResponse.success("数据库健康检查通过", data));
            } else {
                data.put("status", "DOWN");
                data.put("message", "数据库连接无效");
                data.put("timestamp", java.time.LocalDateTime.now().toString());
                
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .body(ApiResponse.error(503, "数据库连接失败", data));
            }
            
        } catch (SQLException e) {
            data.put("status", "DOWN");
            data.put("error", e.getClass().getName());
            data.put("message", e.getMessage());
            data.put("timestamp", java.time.LocalDateTime.now().toString());
            
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body(ApiResponse.error(503, "数据库连接异常", data));
        }
    }
}
