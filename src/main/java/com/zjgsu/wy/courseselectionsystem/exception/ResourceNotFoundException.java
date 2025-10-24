package com.zjgsu.wy.courseselectionsystem.exception;

/**
 * 资源未找到异常
 */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
