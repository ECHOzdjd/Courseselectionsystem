package com.zjgsu.wy.courseselectionsystem.service;

import com.zjgsu.wy.courseselectionsystem.exception.ResourceNotFoundException;
import com.zjgsu.wy.courseselectionsystem.model.Course;
import com.zjgsu.wy.courseselectionsystem.repository.CourseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * 课程服务层
 */
@Service
public class CourseService {
    
    @Autowired
    private CourseRepository courseRepository;

    /**
     * 查询所有课程
     */
    public List<Course> findAll() {
        return courseRepository.findAll();
    }

    /**
     * 根据ID查询课程
     */
    public Course findById(String id) {
        return courseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("课程不存在，ID: " + id));
    }

    /**
     * 创建课程
     */
    public Course create(Course course) {
        // 检查课程代码是否已存在
        if (courseRepository.findByCode(course.getCode()).isPresent()) {
            throw new IllegalArgumentException("课程代码已存在: " + course.getCode());
        }
        return courseRepository.save(course);
    }

    /**
     * 更新课程
     */
    public Course update(String id, Course course) {
        Course existingCourse = findById(id);
        
        // 如果课程代码发生变化，检查新代码是否已存在
        if (!existingCourse.getCode().equals(course.getCode())) {
            if (courseRepository.findByCode(course.getCode()).isPresent()) {
                throw new IllegalArgumentException("课程代码已存在: " + course.getCode());
            }
        }
        
        course.setId(id);
        return courseRepository.save(course);
    }

    /**
     * 删除课程
     */
    public void deleteById(String id) {
        findById(id); // 检查课程是否存在
        courseRepository.deleteById(id);
    }

    /**
     * 检查课程是否存在
     */
    public boolean existsById(String id) {
        return courseRepository.existsById(id);
    }
}
