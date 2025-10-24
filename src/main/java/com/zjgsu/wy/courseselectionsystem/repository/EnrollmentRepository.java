package com.zjgsu.wy.courseselectionsystem.repository;

import com.zjgsu.wy.courseselectionsystem.model.Enrollment;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * 选课记录数据访问层
 */
@Repository
public class EnrollmentRepository {
    private final Map<String, Enrollment> enrollments = new ConcurrentHashMap<>();

    /**
     * 查询所有选课记录
     */
    public List<Enrollment> findAll() {
        return new ArrayList<>(enrollments.values());
    }

    /**
     * 根据ID查询选课记录
     */
    public Optional<Enrollment> findById(String id) {
        return Optional.ofNullable(enrollments.get(id));
    }

    /**
     * 保存选课记录
     */
    public Enrollment save(Enrollment enrollment) {
        enrollments.put(enrollment.getId(), enrollment);
        return enrollment;
    }

    /**
     * 删除选课记录
     */
    public void deleteById(String id) {
        enrollments.remove(id);
    }

    /**
     * 检查选课记录是否存在
     */
    public boolean existsById(String id) {
        return enrollments.containsKey(id);
    }

    /**
     * 根据课程ID查询选课记录
     */
    public List<Enrollment> findByCourseId(String courseId) {
        return enrollments.values().stream()
                .filter(enrollment -> enrollment.getCourseId().equals(courseId))
                .collect(Collectors.toList());
    }

    /**
     * 根据学生ID查询选课记录
     */
    public List<Enrollment> findByStudentId(String studentId) {
        return enrollments.values().stream()
                .filter(enrollment -> enrollment.getStudentId().equals(studentId))
                .collect(Collectors.toList());
    }

    /**
     * 检查学生是否已选某门课程
     */
    public boolean existsByCourseIdAndStudentId(String courseId, String studentId) {
        return enrollments.values().stream()
                .anyMatch(enrollment -> enrollment.getCourseId().equals(courseId) 
                        && enrollment.getStudentId().equals(studentId));
    }

    /**
     * 统计某门课程的选课人数
     */
    public long countByCourseId(String courseId) {
        return enrollments.values().stream()
                .filter(enrollment -> enrollment.getCourseId().equals(courseId))
                .count();
    }
}
