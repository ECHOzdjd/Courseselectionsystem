package com.zjgsu.wy.courseselectionsystem.controller;

import com.zjgsu.wy.courseselectionsystem.common.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * 首页控制器
 */
@RestController
@CrossOrigin(origins = "*")
public class HomeController {

    /**
     * 首页 - 显示API信息
     */
    @GetMapping("/")
    public ResponseEntity<ApiResponse<Map<String, Object>>> home() {
        Map<String, Object> data = new HashMap<>();
        data.put("application", "校园选课与教学资源管理平台");
        data.put("version", "1.0.0");
        data.put("author", "王勇");
        data.put("description", "基于Spring Boot的校园选课系统");
        
        Map<String, String> apis = new HashMap<>();
        apis.put("课程管理", "/api/courses");
        apis.put("学生管理", "/api/students");
        apis.put("选课管理", "/api/enrollments");
        apis.put("健康检查", "/health");
        
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
}
