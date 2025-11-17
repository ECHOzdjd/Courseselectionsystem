# 第一阶段：构建应用
# 使用阿里云镜像
FROM maven:3.9-openjdk-17 AS builder

# 设置工作目录
WORKDIR /build

# 配置 Maven 使用阿里云镜像
RUN mkdir -p /root/.m2 && \
    echo '<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" \
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 \
          http://maven.apache.org/xsd/settings-1.0.0.xsd"> \
          <mirrors> \
            <mirror> \
              <id>aliyunmaven</id> \
              <mirrorOf>*</mirrorOf> \
              <name>阿里云公共仓库</name> \
              <url>https://maven.aliyun.com/repository/public</url> \
            </mirror> \
          </mirrors> \
        </settings>' > /root/.m2/settings.xml

# 复制 Maven 配置文件
COPY pom.xml .

# 下载依赖（利用 Docker 缓存）
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src ./src

# 构建应用（跳过测试以加快构建速度）
RUN mvn clean package -DskipTests

# 第二阶段：运行应用
FROM eclipse-temurin:17-jre-alpine

# 安装 curl（用于健康检查）
RUN apk add --no-cache curl

# 创建非 root 用户（安全性优化）
RUN addgroup -S appuser && adduser -S appuser -G appuser

# 设置工作目录
WORKDIR /app

# 从构建阶段复制 JAR 文件
COPY --from=builder /build/target/wy-*.jar app.jar

# 更改文件所有者
RUN chown -R appuser:appuser /app

# 切换到非 root 用户
USER appuser

# 暴露应用端口
EXPOSE 8080

# 设置 JVM 参数优化内存使用
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# 启动应用
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
