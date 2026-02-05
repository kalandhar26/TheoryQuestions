### What is Microservices Architecture?

- Microservices architecture is about splitting a large application into smaller, independent services, each focusing on
  a single business capability. In Spring Boot, we create each service as a standalone application with its own database
  and deployment lifecycle, which allows us to scale or deploy services independently.

### Difference between Monolithic and Microservices?

- In a monolithic app, everything is tightly coupled, so a small change can require redeploying the whole application.
  Microservices, on the other hand, lets us deploy independent Spring Boot services. For example, updating the
  PaymentService doesn’t affect the UserService.

### What is Spring Boot and Why is it used in microservices?

- Spring Boot is a popular framework for building microservices due to its simplicity, ease of use, and ability to
  create standalone applications with built-in support for configuration management, logging, and monitoring.
- Spring Boot simplifies creating microservices by providing auto-configuration, embedded servers, and starter
  dependencies. Instead of manually configuring servers, we just add dependencies and annotations like
  @SpringBootApplication and the service is ready to run

### What is REST API and How do you implement it in Spring Boot?

- REST API, or Representational State Transfer Application Programming Interface, is a design pattern for building web
  services that uses standard HTTP methods to perform operations on resources. In Spring Boot, we can implement REST
  APIs using the Spring Web framework, which provides a simple and intuitive way to create RESTful web services.
- REST APIs allow services to communicate over HTTP. In Spring Boot, we use @RestController for the controller class and
  @GetMapping or @PostMapping for endpoints

```java

@RestController
@RequestMapping("/users")
public class UserController {
    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userService.findById(id);
    }
}
```

### What is an API Gateway?

- An API Gateway is a single entry point for all client requests. In Spring Boot, we can use Spring Cloud Gateway to
  route requests to multiple services, handle authentication, and implement rate limiting.

### Why do we need an API Gateway?

- API Gateway centralizes cross-cutting concerns like authentication, logging, and routing. For example, using Spring
  Cloud Gateway with filters, we can validate JWT tokens before sending requests to backend services.

### What is Load Balancing?

- Load balancing distributes incoming traffic across multiple instances of a service to avoid overload. In Spring Boot,
  we can use `@LoadBalanced` with `RestTemplate` or WebClient to balance calls between instances registered in Eureka.

### Difference between Horizontal and Vertical Scaling?

- Vertical scaling adds more CPU/RAM to a single instance, while horizontal scaling adds more instances. In Spring Boot
  microservices, horizontal scaling is preferred since services are stateless and can easily run multiple copies in
  Kubernetes.

### What is Stateless vs Stateful Service?

- Stateless services are easier to scale and maintain since they don't rely on shared state, while stateful services
  require more complex management but offer more functionality.
- A stateless service doesn’t store any client data between requests, making it easier to scale. A stateful service
  keeps user data in memory. In Spring Boot, REST APIs are typically stateless, and session data is stored externally if
  needed.

### What is a Database per Service and Why is it important?

- Each microservice has its own database to avoid tight coupling. For example, `OrderService` has its own DB and
  `UserService` has a separate one. This allows independent changes without affecting other services.

### What is Service Discovery?

- Service discovery helps services find each other dynamically instead of hardcoding URLs. In Spring Boot, we can use
  Eureka Server (`@EnableEurekaServer`) and Eureka Clients (`@EnableEurekaClient`) to register and discover services.

### How is Eureka Server and Eureka Client used?

- Eureka Server maintains a registry of services. Each Spring Boot microservice registers itself with Eureka Client
  using `@EnableEurekaClient`, allowing other services to call it by its logical name rather than a hardcoded URL.

### What is Spring Cloud Config?

- Spring Cloud Config provides centralized configuration for microservices. Instead of keeping configs in each service,
  we maintain a config server (usually with Git), and services fetch their configs at startup using `@RefreshScope`

### What is CI/CD and Why is it needed in microservices?

- CI/CD automates building, testing, and deploying services. In a Spring Boot microservices project, Jenkins pipelines
  can build each service, run tests, build Docker images, and deploy them to Kubernetes automatically.

### What is DevOps and its relation to microservices?

- DevOps is collaboration between developers and operations. Microservices fit well because each service can be
  independently deployed, monitored, and scaled, allowing DevOps teams to automate deployment pipelines efficiently.

### What is Authentication and Authorization?

- Authentication verifies who the user is, and authorization decides what actions the user can perform. In Spring Boot,
  we use Spring Security with JWT or OAuth2 to handle authentication and role-based authorization.

### What is JWT and How is it used in Spring Boot?

- JWT (JSON Web Token) is a token-based authentication mechanism. When a user logs in, we generate a JWT and return it
  to the client. Subsequent requests include this token for validation using Spring Security filters.

### What is OAuth2 and when to use it?

- OAuth2 allows users to log in via third-party providers like Google or Facebook. In Spring Boot, we can use
  `spring-boot-starter-oauth2-client` to authenticate users and obtain access tokens without managing passwords
  directly.

### What is Docker and How do you run a Spring Boot microservice in a container?

- Docker packages a microservice with all dependencies so it can run anywhere. We create a Dockerfile:

```Dockerfile
FROM openjdk:17
COPY target/user-service.jar user-service.jar
ENTRYPOINT ["java","-jar","user-service.jar"]
```

- Then we build and run the container independently of the host system

### What is Kubernetes and Why is it useful for microservices?

- Kubernetes orchestrates containers. For Spring Boot microservices, it manages scaling, failover, and service discovery
  across multiple instances, making deployments resilient and automated.

### What is Logging and Why is it important in microservices?

- Logging helps us understand what happens in each service. Spring Boot uses SLF4J with Logback to write logs, and we
  can centralize logs using ELK Stack or Graylog to debug issues across multiple services.

### What is Monitoring and which tools can you use?

- Monitoring tracks the health and performance of services. Spring Boot Actuator exposes metrics, which we can collect
  with Prometheus and visualize in Grafana to monitor CPU, memory, and service latency

### Difference between HTTP and HTTPS?

- HTTP is plain-text communication, while HTTPS encrypts data in transit. In Spring Boot, we can enable HTTPS by
  configuring server.ssl.key-store and server.ssl.key-store-password in application.properties.

### How do microservices communicate synchronously?

- Synchronous communication means a service waits for the response. In Spring Boot, we use RestTemplate or WebClient to
  call another service and wait for a response before continuing

### How do microservices communicate asynchronously?

- Asynchronous communication allows services to continue without waiting. We can use Kafka or RabbitMQ in Spring Boot to
  send and receive messages between services.

### What is Retry Mechanism and Why is it needed?

- Retry mechanism tries a failed request again after a failure. In Spring Boot, Resilience4j provides @Retry to
  automatically retry service calls, reducing temporary failures impact

### What is Timeout and How do you configure it?

- Timeout defines how long to wait for a response. In Spring Boot, we can set timeouts in RestTemplate or WebClient to
  avoid waiting indefinitely on slow or failing services.

### What is Idempotency and Why is it important?

- Idempotency ensures multiple identical requests produce the same result. For example, placing an order twice
  accidentally should still create only one order. Spring Boot can implement idempotency using unique request IDs in
  headers.

### How do you handle failures in a microservice?

- Failures can be handled using retries, fallbacks, and circuit breakers. In Spring Boot, Resilience4j @CircuitBreaker
  allows specifying a fallback method to prevent cascading failures.

### What is Rate Limiting and How does it work?

- Rate limiting controls the number of requests a user can make in a time frame. In Spring Boot, we can implement it
  using Bucket4j or Redis-based solutions to prevent overload

### What is Traffic Shaping?

- Traffic shaping controls the flow of requests to services to avoid bursts. For example, we can delay low-priority
  requests in Spring Boot using filters or API Gateway rate-limiting rules.

### What is Bulkhead Pattern?

- Bulkhead pattern isolates parts of a system so that failure in one service doesn’t bring down the whole system. In
  Spring Boot, Resilience4j can create separate thread pools for services to implement this pattern.

### What is Fault Tolerance in microservices?

- Fault tolerance ensures the system continues to operate even if some services fail. Spring Boot uses retries, circuit
  breakers, and fallback mechanisms to maintain resilience.

### Difference between API Versioning and Backward Compatibility?

- API versioning allows clients to use old versions while new features are added. Backward compatibility ensures old
  clients still work with new changes. In Spring Boot, we can use versioned paths like /api/v1/users.

### What are some advantages of using Spring Boot for microservices?

- Spring Boot reduces boilerplate, provides embedded servers, easy dependency management, and integrates well with
  Spring Cloud for service discovery, configuration, and messaging, making microservices development faster and
  maintainable.

========================================================================================================================

### What is Circuit Breaker Pattern and How is it implemented in Spring Boot?

- Circuit breaker prevents repeatedly calling a failing service, avoiding cascading failures. In Spring Boot, we use
  Resilience4j with @CircuitBreaker(name = "serviceName", fallbackMethod = "fallback"), so when a service fails, the
  fallback method handles it gracefully.

### What is Resilience4j and How do you use it?

- Resilience4j is a lightweight fault-tolerance library for Java. In Spring Boot, we use it for retries, circuit
  breakers, bulkheads, and rate limiting. For example, @Retry can automatically retry failed REST calls, reducing
  transient errors

### What is Distributed Tracing?

- Distributed tracing tracks requests as they flow through multiple microservices, helping us find bottlenecks. In
  Spring Boot, we use Spring Cloud Sleuth with Zipkin to trace requests across services and visualize the path.

### How do you implement distributed tracing with Sleuth and Zipkin?

- Spring Cloud Sleuth automatically adds trace IDs to logs. We can start Zipkin as a service and Spring Boot
  microservices send traces there. Then in Grafana or Zipkin UI, we can see the entire request journey.

### How do you handle configuration management in microservices?

- Configuration management centralizes configs so changes don’t require redeployment. In Spring Boot, Spring Cloud
  Config Server manages externalized configs, and @RefreshScope lets services reload updated configs dynamically.

### Difference between synchronous and asynchronous communication?

- Synchronous waits for a response, like REST calls with RestTemplate or WebClient. Asynchronous doesn’t wait, like
  sending messages via Kafka or RabbitMQ, which improves scalability and avoids blocking requests.

### What is Kafka and How is it used with Spring Boot?

- Kafka is a distributed messaging system. In Spring Boot, we use spring-kafka to produce and consume messages
  asynchronously. For example, @KafkaListener listens to topics, and services can communicate reliably without waiting.

### What is RabbitMQ and when to use it?

- RabbitMQ is a message broker for asynchronous communication. Spring Boot uses spring-boot-starter-amqp with
  @RabbitListener to consume messages. It’s ideal for tasks like order processing or notifications that don’t need
  immediate responses.

### How do you implement logging in distributed microservices?

- Logging is critical for debugging multiple services. In Spring Boot, we use SLF4J + Logback and propagate trace IDs
  with Sleuth, so logs from different services can be correlated in a centralized system like ELK Stack

### What is Spring Boot Actuator and How is it used for monitoring?

- Actuator exposes endpoints for health, metrics, and environment info. We can check /actuator/health or
  /actuator/metrics to monitor service health in Spring Boot and integrate with Prometheus/Grafana for dashboards.

### How do you implement health checks in Spring Boot?

- Health checks monitor the status of services. Actuator provides /actuator/health, and we can add custom health
  indicators by implementing HealthIndicator to check database, external APIs, or other dependencies.

### What is Blue-Green Deployment?

- Blue-Green Deployment runs two identical environments. We deploy new code to the green environment and switch traffic
  once it’s stable, reducing downtime. Spring Boot apps in Docker/Kubernetes fit well for this approach.

### What is Canary Deployment?

- Canary Deployment releases new versions to a small subset of users first. We monitor logs and metrics, then gradually
  roll out. In Spring Boot microservices, API Gateway routing helps direct traffic for canary releases.

### How do you manage API security using Spring Security?

- Spring Security secures endpoints via authentication and authorization. In Spring Boot, we can define roles, configure
  JWT filters, and restrict access using @PreAuthorize("hasRole('ADMIN')") on controller methods.

### How do you implement OAuth2 with Spring Boot?

- OAuth2 lets users log in with external providers. In Spring Boot, spring-boot-starter-oauth2-client configures clients
  like Google. We can annotate controllers with @PreAuthorize to secure endpoints based on scopes.

### How do you secure REST endpoints with JWT?

- JWT secures REST APIs by including a signed token with each request. In Spring Boot, a filter validates the JWT before
  reaching controllers. If valid, the request proceeds; otherwise, it’s rejected with 401.

### How do you handle data consistency across services?

- Microservices can have eventual consistency. We use patterns like Saga or event-driven architecture. For example,
  publishing an order-created event via Kafka ensures inventory and billing services stay in sync asynchronously.

### What is Eventual Consistency?

- Eventual consistency means the system will become consistent over time, even if updates are propagated asynchronously.
  Spring Boot services can use message queues or Kafka to update other services without blocking the main workflow.

### What is Saga Pattern?

- Saga Pattern manages distributed transactions by splitting them into multiple steps with compensating actions if one
  fails. In Spring Boot, we can implement sagas using state machines or orchestration via events.

### Difference between Compensating Transaction and Distributed Transaction?

- Distributed transaction tries to commit all operations atomically, which is hard to scale. Compensating transactions
  undo previous actions if a later step fails, which is commonly used in Spring Boot microservices for reliability.

### How do you perform database migrations in microservices?

- Database migration ensures schema updates are consistent. In Spring Boot, we use Flyway or Liquibase to version and
  apply migrations automatically during service startup or deployment

### What is CQRS pattern and How does it help?

- CQRS separates read and write operations into different models. In Spring Boot, commands handle writes and queries
  handle reads, improving performance and scalability in high-load microservices.

### How do you implement caching in microservices?

- Caching reduces database load. In Spring Boot, we use @Cacheable, @CachePut, or Redis integration. For example,
  frequently read data like user profiles can be cached to improve performance.

### What is Circuit Breaking fallback in Spring Boot?

- Fallback handles failures gracefully. Using Resilience4j, @CircuitBreaker(fallbackMethod = "fallback") ensures that if
  a downstream service fails, we return a default response or call an alternative method.

### How do you implement rate limiting in Spring Boot?

- Rate limiting controls request frequency. Spring Boot can use Bucket4j or Redis to limit API calls per user/IP,
  preventing overload and ensuring fair usage of services.

### What is API throttling?

- API throttling is limiting request rate over time to protect services. It ensures no client can flood a service, and
  can be implemented using Spring Cloud Gateway filters or external API management tools.

### How do you handle cross-cutting concerns like logging, security, metrics?

- We separate cross-cutting concerns from business logic using filters, interceptors, or aspects. In Spring Boot,
  @ControllerAdvice, AOP, and Spring Security filters handle logging, security, and metrics centrally

### What are Sidecars and How are they used in microservices?

- Sidecars run alongside a service to provide auxiliary features like logging, monitoring, or service discovery. Tools
  like Envoy or Istio act as sidecars, while Spring Boot services continue focusing on business logic.x`

### How do you handle message failures (Dead Letter Queue)?

- Dead Letter Queue (DLQ) stores failed messages for later inspection. In Spring Boot Kafka, @KafkaListener can
  configure a DLQ topic, ensuring problematic messages don’t block normal processing

### How do you do load testing for microservices?

- Load testing checks service performance under heavy traffic. We use tools like JMeter or Gatling, targeting Spring
  Boot microservices with realistic scenarios and monitoring metrics with Actuator and Prometheus

### What is Service Mesh and Why is it used?

- Service mesh manages communication between services at the infrastructure level. Istio or Linkerd can be used with
  Spring Boot to provide load balancing, retries, observability, and security without changing business code.

### Difference between API Gateway and Service Mesh?

- API Gateway manages client-to-service traffic, handling routing and security. Service mesh manages service-to-service
  communication internally, providing retries, load balancing, and observability without touching service code.

### How do you implement observability in microservices?

- Observability involves logging, metrics, and tracing. Spring Boot Actuator exposes metrics, Sleuth adds trace IDs, and
  Prometheus/Grafana dashboards visualize system performance and bottlenecks.

### What is Chaos Engineering and How do you apply it?

- Chaos engineering intentionally introduces failures to test resilience. For Spring Boot, we can simulate downtime or
  network delays using tools like Chaos Monkey and monitor if services handle failures gracefully.

### How do you ensure backward compatibility in microservices?

- Backward compatibility ensures older clients continue working with new services. In Spring Boot, we version APIs (
  /api/v1/users) and avoid breaking changes in request/response structures.

========================================================================================================================

### How do you implement distributed transactions using Spring Boot?

- Distributed transactions ensure multiple services update consistently. In Spring Boot, we can use Saga Pattern or
  orchestration with events (Kafka). Each step has a compensating action to rollback in case of failure, keeping data
  consistent.

### What is Event Sourcing and How is it applied?

- Event sourcing stores every change as an event rather than the current state. In Spring Boot, we can persist events in
  Kafka or a database, and rebuild state by replaying events. It improves auditability and resilience.

### What is Domain-Driven Design (DDD) and its building blocks?

- DDD structures systems around business domains. Key building blocks are entities, value objects, aggregates, and
  bounded contexts. In Spring Boot, we map aggregates to services for clear boundaries and maintainable code

### What is Bounded Context in DDD?

- Bounded Context defines the boundaries where a model applies. For example, UserService and OrderService each have
  their own domain rules. Spring Boot microservices are natural fits for bounded contexts, allowing independent
  evolution.

### How do you handle multi-database or polyglot persistence in microservices?

- Different services can use different databases based on their needs. Spring Boot supports JPA for SQL, MongoTemplate
  for MongoDB, and RedisTemplate for caching. Each service manages its own persistence layer.

### How do you handle multi-region deployments?

- Multi-region deployments improve latency and availability. In Spring Boot, services can register with regional Eureka
  servers, and API Gateway or DNS routing can direct users to the nearest region.

### How do you ensure zero-downtime deployments?

- Zero-downtime deployments prevent service interruptions. Using Kubernetes, Spring Boot pods can be rolled out
  gradually, health checks ensure readiness, and API Gateway routes traffic only to healthy instances.

### What is Contract Testing and How do you implement it?

- Contract testing ensures services communicate correctly. Spring Boot uses tools like Pact or Spring Cloud Contract to
  define API expectations. Consumer tests ensure providers don’t break existing contracts.

### What is the difference between synchronous and asynchronous event processing in production?

- Synchronous blocks the caller until processing finishes; asynchronous allows the caller to continue. In Spring Boot,
  async processing uses Kafka, RabbitMQ, or @Async for long-running tasks.

### How do you implement security between microservices (mTLS)?

- Mutual TLS secures service-to-service calls by verifying certificates on both sides. In Spring Boot, we configure SSL
  keystores and use RestTemplate/WebClient with client certs for authentication.

### How do you manage secrets in microservices?

- Secrets like passwords or API keys must be protected. In Spring Boot, we use Spring Cloud Vault, Kubernetes secrets,
  or AWS Secrets Manager, and inject them into services at runtime instead of hardcoding.

### How do you handle retries and exponential backoff?

- Retries attempt failed calls again. Exponential backoff increases wait time between retries to avoid overload. In
  Spring Boot, Resilience4j @Retry can be configured with backoff intervals.

### How do you prevent retry storms?

- Retry storms happen when many services retry at the same time. Using jitter with exponential backoff in Resilience4j
  prevents synchronization of retries, reducing load spikes on downstream services.

### How do you implement traffic shadowing for testing?

- Traffic shadowing duplicates live traffic to a test service without affecting production. In Spring Boot, we can use
  Spring Cloud Gateway to route copies of requests to a shadow instance for testing new features safely.

### How do you monitor Kafka or messaging systems?

- Monitoring ensures message flow and system health. Spring Boot exposes metrics via Micrometer, which Prometheus can
  scrape. We track message lag, consumer health, and throughput to detect issues early.

### How do you ensure exactly-once message processing?

- Exactly-once ensures each message is processed only once. Spring Boot with Kafka achieves this using '
  enable.idempotence=true', consumer offsets, and idempotent handlers to prevent duplicates.

### How do you implement schema versioning and schema registry?

- Schema registry manages message schemas across services. With Avro or Protobuf, Spring Boot producers/consumers
  validate against the registry. Versioning prevents breaking changes in asynchronous communication.

### What is adaptive autoscaling and How do you implement it?

- Adaptive autoscaling adjusts service instances based on traffic. Kubernetes monitors CPU/memory and scales Spring Boot
  pods automatically. Horizontal Pod Autoscaler ensures services meet demand efficiently.

### How do you handle disaster recovery for microservices?

- Disaster recovery ensures service continuity during outages. We replicate databases, back up Kafka topics, and deploy
  Spring Boot services across multiple regions to minimize downtime and data loss.

### How do you implement API Gateway routing, filtering, and security with Spring Cloud Gateway?

- Spring Cloud Gateway routes requests based on paths or headers. Filters can authenticate JWT, log requests, or
  rate-limit traffic.
- For example, gateway.routes().route(r -> r.path("/orders/**").filters(f -> f.filter(jwtAuthFilter)).uri("lb:
  //ORDER-SERVICE"))."

### How do you integrate Spring Boot microservices with external third-party systems?

- We use REST clients (RestTemplate or WebClient) or messaging protocols. Resilience4j and retries handle temporary
  failures. For sensitive data, OAuth2 or API keys secure communication with third-party APIs.

### How do you handle high-volume traffic and backpressure?

- Backpressure prevents services from being overwhelmed. Spring Boot reactive WebFlux supports non-blocking processing.
  Kafka consumers can adjust batch sizes, and rate-limiting ensures stability during spikes.

### How do you implement distributed caching across services?

- Distributed caching stores shared data for multiple services. Spring Boot with Redis or Hazelcast caches user sessions
  or reference data, reducing DB load and improving performance.

### How do you handle performance bottlenecks and profiling?

- We profile services using JProfiler, Flight Recorder, or Spring Boot Actuator metrics. Bottlenecks can be fixed by
  optimizing DB queries, caching, async processing, or scaling instances.

### How do you implement observability with Prometheus and Grafana?

- Prometheus scrapes metrics from Spring Boot Actuator endpoints, and Grafana visualizes them. We track request latency,
  error rates, CPU, and memory to identify trends or performance issues.

### How do you apply Chaos Engineering in production safely?

- We simulate failures like service crashes or network latency on a small subset of traffic. Using tools like Chaos
  Monkey and monitoring with Grafana, we ensure Spring Boot services remain resilient.

### How do you implement event-driven architecture with Spring Boot?

- Event-driven architecture uses messages/events to trigger actions asynchronously. Spring Boot producers publish events
  to Kafka, and listeners with @KafkaListener react to changes, decoupling services effectively.

### How do you ensure SLA, SLO, and SLI in microservices?

- SLAs are contracts, SLOs are objectives, and SLIs are metrics. In Spring Boot, we monitor endpoints using Actuator and
  Prometheus, ensuring latency, uptime, and error rates meet defined targets.

### How do you perform capacity planning and scaling strategy?

- Capacity planning predicts resource needs for future loads. In Spring Boot microservices, we use historical metrics,
  Kubernetes HPA, and cloud scaling policies to ensure services handle peak traffic efficiently.

### How do you design a microservices system for reliability, scalability, and maintainability?

- We design microservices with clear boundaries, stateless services, separate databases, event-driven communication, and
  observability. Using Spring Boot with Eureka, Gateway, Resilience4j, and proper monitoring ensures reliability,
  scaling, and maintainability.