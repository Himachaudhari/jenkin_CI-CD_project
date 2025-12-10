### Stage 1 — Build the application with Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom and download dependencies (cache layer)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy rest of the code and build
COPY src ./src
RUN mvn -B package -DskipTests

### Stage 2 — Create lightweight runtime image
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
