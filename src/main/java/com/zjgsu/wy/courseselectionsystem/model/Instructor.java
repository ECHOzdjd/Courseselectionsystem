package com.zjgsu.wy.courseselectionsystem.model;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 教师实体类
 */
public class Instructor {
    @JsonProperty("id")
    private String id;
    
    @JsonProperty("name")
    private String name;
    
    @JsonProperty("email")
    private String email;

    // 默认构造函数
    public Instructor() {}

    // 全参构造函数
    public Instructor(String id, String name, String email) {
        this.id = id;
        this.name = name;
        this.email = email;
    }

    // Getter和Setter方法
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    @Override
    public String toString() {
        return "Instructor{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}
