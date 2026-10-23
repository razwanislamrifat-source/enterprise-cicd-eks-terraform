FROM maven:3.9.4-amazoncorretto-17 AS builder

LABEL org.opencontainers.image.title="advanced-cicd-app" \
      org.opencontainers.image.description="Advanced CI/CD pipeline demo Spring Boot app" \
      org.opencontainers.image.version="2.0.0" \
      org.opencontainers.image.authors="com.razwan"

WORKDIR /workspace

COPY app/pom.xml ./pom.xml
COPY app/src ./src

RUN mvn -f pom.xml clean package -DskipTests

FROM amazoncorretto:17-alpine

LABEL org.opencontainers.image.title="advanced-cicd-app" \
      org.opencontainers.image.description="Runtime image for advanced-cicd-app" \
      org.opencontainers.image.version="2.0.0" \
      org.opencontainers.image.authors="com.razwan"

# Security: run as non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder --chown=appuser:appgroup /workspace/target/advanced-cicd-app-2.0.0.jar /app/app.jar

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
