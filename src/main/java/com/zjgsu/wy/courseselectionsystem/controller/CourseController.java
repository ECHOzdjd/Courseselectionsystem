package com.zjgsu.wy.courseselectionsystem.controller;

import com.zjgsu.wy.courseselectionsystem.common.ApiResponse;
import com.zjgsu.wy.courseselectionsystem.model.Course;
import com.zjgsu.wy.courseselectionsystem.service.CourseService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 课程控制器
 */
@RestController
@RequestMapping("/api/courses")
@CrossOrigin(origins = "*")
public class CourseController {
    
    @Autowired
    private CourseService courseService;

    /**
     * 查询所有课程
     */
    @GetMapping
    public ResponseEntity<ApiResponse<List<Course>>> getAllCourses() {
        List<Course> courses = courseService.findAll();
        return ResponseEntity.ok(ApiResponse.success(courses));
    }

    /**
     * 根据ID查询课程
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Course>> getCourseById(@PathVariable String id) {
        Course course = courseService.findById(id);
        return ResponseEntity.ok(ApiResponse.success(course));
    }

    /**
     * 创建课程
     */
    @PostMapping
    public ResponseEntity<ApiResponse<Course>> createCourse(@Valid @RequestBody Course course) {
        Course createdCourse = courseService.create(course);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("课程创建成功", createdCourse));
    }

    /**
     * 更新课程
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Course>> updateCourse(
            @PathVariable String id, 
            @Valid @RequestBody Course course) {
        Course updatedCourse = courseService.update(id, course);
        return ResponseEntity.ok(ApiResponse.success("课程更新成功", updatedCourse));
    }

    /**
     * 删除课程
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Object>> deleteCourse(@PathVariable String id) {
        courseService.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("课程删除成功", null));
    }
}
