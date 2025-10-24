package com.zjgsu.wy.courseselectionsystem.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 选课记录实体类
 */
public class Enrollment {
    @JsonProperty("id")
    private String id;
    
    @JsonProperty("courseId")
    private String courseId;
    
    @JsonProperty("studentId")
    private String studentId;
    
    @JsonProperty("enrolledAt")
    private LocalDateTime enrolledAt;

    // 默认构造函数
    public Enrollment() {
        this.id = UUID.randomUUID().toString();
        this.enrolledAt = LocalDateTime.now();
    }

    // 全参构造函数
    public Enrollment(String courseId, String studentId) {
        this.id = UUID.randomUUID().toString();
        this.courseId = courseId;
        this.studentId = studentId;
        this.enrolledAt = LocalDateTime.now();
    }

    // Getter和Setter方法
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCourseId() {
        return courseId;
    }

    public void setCourseId(String courseId) {
        this.courseId = courseId;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public LocalDateTime getEnrolledAt() {
        return enrolledAt;
    }

    public void setEnrolledAt(LocalDateTime enrolledAt) {
        this.enrolledAt = enrolledAt;
    }

    @Override
    public String toString() {
        return "Enrollment{" +
                "id='" + id + '\'' +
                ", courseId='" + courseId + '\'' +
                ", studentId='" + studentId + '\'' +
                ", enrolledAt=" + enrolledAt +
                '}';
    }
}
