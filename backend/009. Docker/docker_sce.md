# 1. Docker Fundamentals (Spring Boot Context)

## 1.1 What problem does Docker solve for Spring Boot applications?
## 1.2 How is a Docker container different from a virtual machine?
## 1.3 Why is Docker preferred over running Spring Boot directly on servers?
## 1.4 What is a Docker image vs container in a Spring Boot setup?
## 1.5 Why “works on my machine” disappears with Docker?

# 2. Dockerfile Design for Spring Boot

## 2.1 How do you write a Dockerfile for a Spring Boot JAR?
## 2.2 What is a multi-stage Docker build and why is it critical for Java apps?
## 2.3 Why should you avoid openjdk:latest in production?
## 2.4 Difference between COPY and ADD – when to use which?
## 2.5 Why should your Docker image run as non-root?
## 2.6 How do you reduce Docker image size for Spring Boot?

# 3. JVM, Memory & Container Awareness

## 3.1 Why does Java consume more memory inside Docker?
## 3.2 What is container-aware JVM and why is it important?
## 3.3 How do you set JVM heap size in Docker correctly?
## 3.4 What happens if you don’t configure memory limits?
## 3.5 How do you debug OutOfMemoryError inside a container?
## 3.6 Why is -XX:+UseContainerSupport important?

# 4. Configuration & Environment Management

## 4.1 How do you externalize Spring Boot configs in Docker?
## 4.2 Environment variables vs config files – tradeoffs?
## 4.3 How do you handle secrets securely in Docker?
## 4.4 Why should you never bake secrets into images?
## 4.5 How do you activate Spring profiles in Docker?
## 4.6 How do you override config per environment (dev/uat/prod)?

# 5. Networking & Service Communication

## 5.1 How do Docker containers communicate with each other?
## 5.2 Why does localhost behave differently inside Docker?
## 5.3 How does Spring Boot connect to a DB running in another container?
## 5.4 What is bridge network vs host network?
## 5.5 How do you expose Spring Boot ports securely?
## 5.6 How do you handle DNS resolution between containers?

# 6. Docker Compose for Spring Boot Systems

## 6.1 Why use Docker Compose for Spring Boot microservices?
## 6.2 How do you define Spring Boot + DB using Compose?
## 6.3 What is depends_on and what it does NOT guarantee?
## 6.4 How do you handle startup order issues?
## 6.5 How do you scale Spring Boot services using Compose?
## 6.6 Why Compose is not production orchestration?

# 7. Logging & Monitoring

## 7.1 How should Spring Boot logs be handled in Docker?
## 7.2 Why should logs go to stdout/stderr?
## 7.3 How do you view container logs?
## 7.4 How do you persist logs outside containers?
## 7.5 How do you enable health checks for Spring Boot?
## 7.6 How do you monitor container resource usage?

# 8. Data Persistence & Volumes

## 8.1 Why containers should be stateless?
## 8.2 How do you persist DB data using Docker volumes?
## 8.3 Bind mounts vs volumes – differences?
## 8.4 Why should you never store data inside container filesystem?
## 8.5 How do you back up volumes?
## 8.6 What happens to data when container restarts?

# 9. Security Best Practices

## 9.1 How do you scan Docker images for vulnerabilities?
## 9.2 Why minimal base images improve security?
## 9.3 How do you restrict container capabilities?
## 9.4 How do you protect Docker daemon access?
## 9.5 Why running Spring Boot as root is dangerous?
## 9.6 How do you handle CVE patching in Docker images?

# 10. Performance & Scaling

## 10.1 How does Docker impact Spring Boot startup time?
## 10.2 How do you reduce cold start time?
## 10.3 What is layered JAR and how does it help Docker caching?
## 10.4 How do you scale Spring Boot containers horizontally?
## 10.5 Why one process per container rule matters?
## 10.6 How do you handle graceful shutdown in Docker?

# 11. CI/CD & Image Lifecycle

## 11.1 How do you build Docker images in CI pipeline?
## 11.2 Why should Docker build be deterministic?
## 11.3 How do you version Docker images?
## 11.4 How do you promote images across environments?
## 11.5 How do you roll back a bad Docker image?
## 11.6 How do you clean up unused images safely?

# 12. Troubleshooting & Debugging

## 12.1 How do you debug a failing Spring Boot container?
## 12.2 What does docker exec help with?
## 12.3 How do you inspect container environment variables?
## 12.4 How do you troubleshoot port binding issues?
## 12.5 How do you analyze container crashes?
## 12.6 How do you attach a debugger to a running container?

# 13. Docker vs Kubernetes (Awareness)

## 13.1 Why Docker alone is insufficient for production at scale?
## 13.2 What problems Kubernetes solves beyond Docker?
## 13.3 Docker Compose vs Kubernetes – differences?
## 13.4 When should a Spring Boot developer learn Kubernetes?
## 13.5 What Docker knowledge transfers directly to Kubernetes?

# 14. Anti-Patterns & Common Mistakes

## 14.1 Fat images with build tools included – why bad?
## 14.2 Using Docker as VM – what goes wrong?
## 14.3 Hardcoding configs in Dockerfile – consequences?
## 14.4 One container running multiple services – why wrong?
## 14.5 Ignoring resource limits – real production impact?