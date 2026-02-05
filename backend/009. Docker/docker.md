# What is Docker?
- Docker is a platform for developing, shipping, and running applications in lightweight, portable containers. Containers package an application with all its dependencies, ensuring consistency across environments.

## Key Concepts:
- Images: Read-only templates with instructions for creating containers
- Containers: Runnable instances of images
- Dockerfile: Text document with commands to assemble an image
- Docker Hub: Public registry for Docker images
- Docker Engine: The core Docker application that runs containers

# Daily Development Commands

| **Command**           | **Description**                          | **Example**                                 |
|-----------------------|------------------------------------------|---------------------------------------------|
| `docker build`        | Build an image from Dockerfile           | `docker build -t my-spring-app:1.0 .`       |
| `docker run`          | Run a container from an image            | `docker run -p 8080:8080 my-spring-app:1.0` |
| `docker ps`           | List running containers                  | `docker ps` or `docker ps -a` for all       |
| `docker logs`         | View container logs                      | `docker logs <container-id>`                |
| `docker exec`         | Run a command inside a running container | `docker exec -it <container-id> /bin/sh`    |
| `docker-compose up`   | Start multi-container apps               | `docker-compose up -d` (detached mode)      |
| `docker-compose down` | Stop and remove containers               | `docker-compose down`                       |
| `docker stop`         | Stop a running container                 | `docker stop <container-id>`                |
| `docker rm`           | Remove a stopped container               | `docker rm <container-id>`                  |
| `docker rmi`          | Remove an unused image                   | `docker rmi my-spring-app:1.0`              |

# Production Release & Debugging Commands

| **Command**           | **Description**                  | **Example**                     |
|-----------------------|----------------------------------|---------------------------------|
| `docker login`        | Log in to Docker Hub/ECR         | `docker login -u <username>`    |
| `docker push`         | Push image to a registry         | `docker push my-spring-app:1.0` |
| `docker pull`         | Pull an image from a registry    | `docker pull amazon/aws-cli`    |
| `docker inspect`      | Get container metadata           | `docker inspect <container-id>` |
| `docker stats`        | Monitor container resource usage | `docker stats`                  |
| `docker network ls`   | List Docker networks             | `docker network ls`             |
| `docker volume ls`    | List Docker volumes              | `docker volume ls`              |
| `docker system prune` | Clean unused containers/images   | `docker system prune -a`        |
| `docker-compose logs` | View logs for all services       | `docker-compose logs -f`        |
| `docker restart`      | Restart a container              | `docker restart <container-id>` |

## Key Commands for Java/Spring Boot Microservices

| **Use Case**                                             | **Command**                                                                                                                                        |
|----------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| Debugging a Spring Boot app in Docker                    | `docker run -p 8080:8080 -p 5005:5005 -e JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,address=5005,server=y,suspend=n" my-spring-app:1.0` |
| Building a multi-stage Dockerfile (optimized for Java)   | `docker build --target=production -t my-spring-app:prod .`                                                                                         |
| Running with environment variables (for application.yml) | `docker run -e "SPRING_PROFILES_ACTIVE=prod" -e "DB_URL=jdbc:mysql://host:3306/db" my-spring-app:1.0`                                              |
| Health check for microservices                           | `docker inspect --format='{{json .State.Health}}' <container-id>`                                                                                  |

## Sample Docker file

```Dockerfile
# ---------- Build stage ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
COPY src ./src
RUN mvn -B -q package -DskipTests

# ---------- Runtime stage ----------
FROM gcr.io/distroless/java21-debian12:nonroot
WORKDIR /app
COPY --from=build /workspace/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Multi Staged Docker file

```yaml

```