package com.zjgsu.wy.courseselectionsystem.repository;

import com.zjgsu.wy.courseselectionsystem.model.Student;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 学生数据访问层
 */
@Repository
public class StudentRepository {
    private final Map<String, Student> students = new ConcurrentHashMap<>();

    /**
     * 查询所有学生
     */
    public List<Student> findAll() {
        return new ArrayList<>(students.values());
    }

    /**
     * 根据ID查询学生
     */
    public Optional<Student> findById(String id) {
        return Optional.ofNullable(students.get(id));
    }

    /**
     * 保存学生
     */
    public Student save(Student student) {
        students.put(student.getId(), student);
        return student;
    }

    /**
     * 删除学生
     */
    public void deleteById(String id) {
        students.remove(id);
    }

    /**
     * 检查学生是否存在
     */
    public boolean existsById(String id) {
        return students.containsKey(id);
    }

    /**
     * 根据学号查询学生
     */
    public Optional<Student> findByStudentId(String studentId) {
        return students.values().stream()
                .filter(student -> student.getStudentId().equals(studentId))
                .findFirst();
    }

    /**
     * 检查学号是否已存在
     */
    public boolean existsByStudentId(String studentId) {
        return students.values().stream()
                .anyMatch(student -> student.getStudentId().equals(studentId));
    }
}
