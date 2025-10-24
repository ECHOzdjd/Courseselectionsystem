package com.zjgsu.wy.courseselectionsystem.service;

import com.zjgsu.wy.courseselectionsystem.exception.BusinessException;
import com.zjgsu.wy.courseselectionsystem.exception.ResourceNotFoundException;
import com.zjgsu.wy.courseselectionsystem.model.Student;
import com.zjgsu.wy.courseselectionsystem.repository.EnrollmentRepository;
import com.zjgsu.wy.courseselectionsystem.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * 学生服务层
 */
@Service
public class StudentService {
    
    @Autowired
    private StudentRepository studentRepository;
    
    @Autowired
    private EnrollmentRepository enrollmentRepository;

    /**
     * 查询所有学生
     */
    public List<Student> findAll() {
        return studentRepository.findAll();
    }

    /**
     * 根据ID查询学生
     */
    public Student findById(String id) {
        return studentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("学生不存在，ID: " + id));
    }

    /**
     * 创建学生
     */
    public Student create(Student student) {
        // 检查学号是否已存在
        if (studentRepository.existsByStudentId(student.getStudentId())) {
            throw new BusinessException("学号已存在: " + student.getStudentId());
        }
        
        return studentRepository.save(student);
    }

    /**
     * 更新学生信息
     */
    public Student update(String id, Student student) {
        Student existingStudent = findById(id);
        
        // 如果学号发生变化，检查新学号是否已存在
        if (!existingStudent.getStudentId().equals(student.getStudentId())) {
            if (studentRepository.existsByStudentId(student.getStudentId())) {
                throw new BusinessException("学号已存在: " + student.getStudentId());
            }
        }
        
        student.setId(id);
        student.setCreatedAt(existingStudent.getCreatedAt()); // 保持创建时间不变
        return studentRepository.save(student);
    }

    /**
     * 删除学生
     */
    public void deleteById(String id) {
        Student student = findById(id);
        
        // 检查是否有选课记录
        List<com.zjgsu.wy.courseselectionsystem.model.Enrollment> enrollments = 
                enrollmentRepository.findByStudentId(student.getStudentId());
        
        if (!enrollments.isEmpty()) {
            throw new BusinessException("无法删除：该学生存在选课记录");
        }
        
        studentRepository.deleteById(id);
    }

    /**
     * 根据学号查询学生
     */
    public Student findByStudentId(String studentId) {
        return studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("学生不存在，学号: " + studentId));
    }

    /**
     * 检查学生是否存在
     */
    public boolean existsById(String id) {
        return studentRepository.existsById(id);
    }
}
