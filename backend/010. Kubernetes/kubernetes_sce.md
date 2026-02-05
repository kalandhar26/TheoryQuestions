# 1. Application Deployment & Pods

## Your Spring Boot app crashes on startup in Kubernetes but works locally. How do you debug it?

## A pod keeps restarting with CrashLoopBackOff. What are the first 5 things you check?

## You deployed a new version but traffic is still hitting the old one. Why?

## How would you configure JVM heap size correctly inside a container?

## Your pod is running but the application is not reachable.What could be wrong?

## How do you pass Spring profiles (dev, qa, prod) to a pod?

## Your application needs a startup dependency (DB, Kafka). How do you ensure startup order?

# 2. Services, Networking & Routing

## Your Spring Boot service is not reachable from another pod. How do you debug networking?

## Difference between ClusterIP, NodePort, and LoadBalancer — when do you use each?

## How does Kubernetes service discovery work for Spring Boot apps?

## Your app works inside the cluster but not from the browser. What are the causes?

## How would you expose /actuator/health only internally but not publicly?

## How does DNS resolution work between services in Kubernetes?

# 3. Ingress & API Gateway

## You need path-based routing (/users, /orders) to different services.How do you do it?

## How does Ingress differ from an API Gateway like Spring Cloud Gateway?

## TLS is required for your Spring Boot app. Where do you terminate SSL?

## How do you handle redirects (HTTP → HTTPS) at Kubernetes level?

## Your Ingress works in dev but fails in prod. ## HowWhat environment differences matter?

# 4. Configuration Management

## How do you externalize application.yml using ConfigMaps?

## When should you use Secrets vs ConfigMaps?

## How do you rotate DB passwords without redeploying the app?

## HowWhat happens if a ConfigMap changes while the pod is running?

## How do you inject secrets securely into Spring Boot apps?

# 5. Scaling & Performance

## Your Spring Boot app experiences high CPU during peak hours. How do you scale it?

## Difference between replicas and Horizontal Pod Autoscaler (HPA)?

## HowWhat metrics does HPA use by default?

## Your app scales but DB becomes the bottleneck.How do you fix it?

## Why autoscaling sometimes doesn’t trigger even under load?

# 6. Health Checks & Reliability

## Difference between liveness and readiness probes with Spring Boot examples.

## HowWhat happens if liveness probe fails repeatedly?

## Why should readiness probe be used with rolling deployments?

## How do you configure actuator health endpoints for Kubernetes?

## How do you avoid killing pods during long-running requests?

# 7. Rolling Updates & Deployments

## How does Kubernetes perform rolling updates?

## Zero-downtime deployment strategy for Spring Boot apps?

## HowWhat happens if a new deployment version is buggy?

## How do you rollback to a previous version quickly?

## Blue-Green vs Canary deployment — which would you choose and why?

# 8. Resource Management

## Why should you always define CPU and memory limits?

## HowWhat happens if your Spring Boot app exceeds memory limits?

## Difference between requests and limits?

## How do you tune JVM GC behavior in Kubernetes?

## How do you detect memory leaks in pods?

# 9. Security & Access Control

## How do you restrict pod-to-pod communication?

## How does Kubernetes RBAC affect Spring Boot deployments?

## How do you prevent developers from accessing production secrets?

## How do you secure internal service communication?

## HowWhat is the risk of running containers as root?

# 10. Observability & Debugging

## How do you view logs of a specific pod?

## How do you debug a pod without SSH access?

## How do you implement centralized logging for Spring Boot apps?

## How do you expose metrics for Prometheus?

## How do you trace a request across multiple microservices?

# 11. Stateful Apps & Databases

## Should databases run inside Kubernetes? When yes, when no?

## Difference between Deployment and StatefulSet?

## How does persistent storage work for pods?

## What happens to data if a pod dies?

## How do you handle DB failover in Kubernetes?

# 12. Environment Strategy & CI/CD

## How do you manage dev, QA, and prod clusters?

## How does CI/CD deploy Spring Boot apps to Kubernetes?

## How do you avoid configuration drift between environments?

## HowWhat checks should happen before deploying to prod?

## How do you run database migrations safely?

# 13. Failure & Disaster Scenarios

## A node goes down. What happens to your Spring Boot app?

## How does Kubernetes reschedule pods after failure?

## What happens during a full cluster outage?

## How do you design multi-AZ or multi-region deployments?

## How do you test failure scenarios proactively?

# 14. Real-World Banking / Enterprise Scenarios

## How do you deploy Spring Boot apps with strict regulatory requirements?

## How do you ensure audit logs are not lost if pods restart?

## How do you isolate workloads for different teams?

## How do you enforce network policies for sensitive services?

## How do you handle secret rotation without downtime?

# 15. Design & Architecture Thinking

## When should Kubernetes NOT be used for Spring Boot apps?

## What are common mistakes Java developers make with Kubernetes?

## How do you design Kubernetes-ready Spring Boot applications?

## What’s the biggest JVM + Kubernetes antipattern you’ve seen?

## How do you explain Kubernetes benefits to non-technical stakeholders?