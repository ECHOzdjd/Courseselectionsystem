package com.zjgsu.wy.courseselectionsystem.controller;

import com.zjgsu.wy.courseselectionsystem.common.ApiResponse;
import com.zjgsu.wy.courseselectionsystem.model.Enrollment;
import com.zjgsu.wy.courseselectionsystem.service.EnrollmentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 选课控制器
 */
@RestController
@RequestMapping("/api/enrollments")
@CrossOrigin(origins = "*")
public class EnrollmentController {
    
    @Autowired
    private EnrollmentService enrollmentService;

    /**
     * 查询所有选课记录
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Enrollment>>> getAllEnrollments() {
        List<Enrollment> enrollments = enrollmentService.findAll();
        return ResponseEntity.ok(ApiResponse.success(enrollments));
    }

    /**
     * 根据ID查询选课记录
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Enrollment>> getEnrollmentById(@PathVariable String id) {
        Enrollment enrollment = enrollmentService.findById(id);
        return ResponseEntity.ok(ApiResponse.success(enrollment));
    }

    /**
     * 学生选课
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Enrollment>> enroll(@RequestBody Map<String, String> request) {
        String courseId = request.get("courseId");
        String studentId = request.get("studentId");
        
        if (courseId == null || studentId == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.badRequest("courseId和studentId不能为空"));
        }
        
        Enrollment enrollment = enrollmentService.enroll(courseId, studentId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("选课成功", enrollment));
    }

    /**
     * 学生退课
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> unenroll(@PathVariable String id) {
        enrollmentService.unenroll(id);
        return ResponseEntity.ok(ApiResponse.success("退课成功", null));
    }

    /**
     * 根据课程ID查询选课记录
     */
    @GetMapping("/course/{courseId}")
    public ResponseEntity<ApiResponse<List<Enrollment>>> getEnrollmentsByCourse(@PathVariable String courseId) {
        List<Enrollment> enrollments = enrollmentService.findByCourseId(courseId);
        return ResponseEntity.ok(ApiResponse.success(enrollments));
    }

    /**
     * 根据学生ID查询选课记录
     */
    @GetMapping("/student/{studentId}")
    public ResponseEntity<ApiResponse<List<Enrollment>>> getEnrollmentsByStudent(@PathVariable String studentId) {
        List<Enrollment> enrollments = enrollmentService.findByStudentId(studentId);
        return ResponseEntity.ok(ApiResponse.success(enrollments));
    }
}
