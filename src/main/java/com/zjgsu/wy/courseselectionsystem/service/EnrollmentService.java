package com.zjgsu.wy.courseselectionsystem.service;

import com.zjgsu.wy.courseselectionsystem.exception.BusinessException;
import com.zjgsu.wy.courseselectionsystem.exception.ResourceNotFoundException;
import com.zjgsu.wy.courseselectionsystem.model.Course;
import com.zjgsu.wy.courseselectionsystem.model.Enrollment;
import com.zjgsu.wy.courseselectionsystem.model.EnrollmentStatus;
import com.zjgsu.wy.courseselectionsystem.model.Student;
import com.zjgsu.wy.courseselectionsystem.repository.CourseRepository;
import com.zjgsu.wy.courseselectionsystem.repository.EnrollmentRepository;
import com.zjgsu.wy.courseselectionsystem.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 选课服务层
 */
@Service
@Transactional(readOnly = true)
public class EnrollmentService {
    
    @Autowired
    private EnrollmentRepository enrollmentRepository;
    
    @Autowired
    private CourseRepository courseRepository;
    
    @Autowired
    private StudentRepository studentRepository;

    /**
     * 查询所有选课记录
     */
    public List<Enrollment> findAll() {
        return enrollmentRepository.findAll();
    }

    /**
     * 根据ID查询选课记录
     */
    public Enrollment findById(String id) {
        return enrollmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("选课记录不存在，ID: " + id));
    }

    /**
     * 学生选课
     */
    @Transactional
    public Enrollment enroll(String courseId, String studentId) {
        // 验证课程是否存在
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("课程不存在，ID: " + courseId));
        
        // 验证学生是否存在
        Student student = studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("学生不存在，学号: " + studentId));
        
        // 检查是否已选该课程（活跃状态）
        if (enrollmentRepository.existsByCourseIdAndStudentId(courseId, studentId)) {
            throw new BusinessException("学生已选择该课程");
        }
        
        // 检查课程容量
        long currentEnrollments = enrollmentRepository.countByCourseId(courseId);
        if (currentEnrollments >= course.getCapacity()) {
            throw new BusinessException("课程容量已满，无法选课");
        }
        
        // 创建选课记录
        Enrollment enrollment = new Enrollment(courseId, studentId);
        enrollment.setStatus(EnrollmentStatus.ACTIVE);
        enrollment = enrollmentRepository.save(enrollment);
        
        // 更新课程的已选人数
        course.setEnrolled((int) (currentEnrollments + 1));
        courseRepository.save(course);
        
        return enrollment;
    }

    /**
     * 学生退课
     */
    @Transactional
    public void unenroll(String id) {
        Enrollment enrollment = findById(id);
        
        // 检查选课记录状态
        if (enrollment.getStatus() != EnrollmentStatus.ACTIVE) {
            throw new BusinessException("该选课记录状态不是活跃状态，无法退课");
        }
        
        String courseId = enrollment.getCourseId();
        
        // 更新选课状态为已退课
        enrollment.setStatus(EnrollmentStatus.DROPPED);
        enrollmentRepository.save(enrollment);
        
        // 更新课程的已选人数
        Course course = courseRepository.findById(courseId).orElse(null);
        if (course != null) {
            long currentEnrollments = enrollmentRepository.countByCourseId(courseId);
            course.setEnrolled((int) currentEnrollments);
            courseRepository.save(course);
        }
    }

    /**
     * 根据课程ID查询选课记录
     */
    public List<Enrollment> findByCourseId(String courseId) {
        // 验证课程是否存在
        if (!courseRepository.existsById(courseId)) {
            throw new ResourceNotFoundException("课程不存在，ID: " + courseId);
        }
        
        return enrollmentRepository.findByCourseId(courseId);
    }

    /**
     * 根据学生ID查询选课记录
     */
    public List<Enrollment> findByStudentId(String studentId) {
        // 验证学生是否存在
        studentRepository.findByStudentId(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("学生不存在，学号: " + studentId));
        
        return enrollmentRepository.findByStudentId(studentId);
    }
    
    /**
     * 根据课程ID和状态查询选课记录
     */
    public List<Enrollment> findByCourseIdAndStatus(String courseId, EnrollmentStatus status) {
        return enrollmentRepository.findByCourseIdAndStatus(courseId, status);
    }
    
    /**
     * 根据学生ID和状态查询选课记录
     */
    public List<Enrollment> findByStudentIdAndStatus(String studentId, EnrollmentStatus status) {
        return enrollmentRepository.findByStudentIdAndStatus(studentId, status);
    }
}
