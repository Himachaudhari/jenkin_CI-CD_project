# ---- Stage 1: Build the application ----
FROM eclipse-temurin:17-jdk-jammy AS build

WORKDIR /app

# Copy Maven config
COPY pom.xml .

# Download dependencies first (cache layer)
RUN mvn -B -e -ntp dependency:resolve dependency:resolve-plugins

# Copy source code
COPY src ./src

# Build project (skip tests to speed up CI)
RUN mvn -B -e -ntp clean package -DskipTests


# ---- Stage 2: Create final image ----
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]
