package com.zjgsu.wy.courseselectionsystem.repository;

import com.zjgsu.wy.courseselectionsystem.model.Course;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 课程数据访问层
 */
@Repository
public class CourseRepository {
    private final Map<String, Course> courses = new ConcurrentHashMap<>();

    /**
     * 查询所有课程
     */
    public List<Course> findAll() {
        return new ArrayList<>(courses.values());
    }

    /**
     * 根据ID查询课程
     */
    public Optional<Course> findById(String id) {
        return Optional.ofNullable(courses.get(id));
    }

    /**
     * 保存课程
     */
    public Course save(Course course) {
        courses.put(course.getId(), course);
        return course;
    }

    /**
     * 删除课程
     */
    public void deleteById(String id) {
        courses.remove(id);
    }

    /**
     * 检查课程是否存在
     */
    public boolean existsById(String id) {
        return courses.containsKey(id);
    }

    /**
     * 根据课程代码查询
     */
    public Optional<Course> findByCode(String code) {
        return courses.values().stream()
                .filter(course -> course.getCode().equals(code))
                .findFirst();
    }
}
