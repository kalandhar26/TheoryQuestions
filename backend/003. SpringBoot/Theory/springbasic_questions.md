## 1. Why Constructor Injection is preferred over Setter Injection?

- Construction Injection enables Immutability and ThreadSafe as it enables final fields. objects become immutable
  after construction. prevents accidental modification after initialization.
- Constructor guarantees all dependencies are provided. Constructor injection fails fast if circular dependencies exist

## 2. Why Spring Boot Over Spring?

### Simplified Configuration:

- Spring requires extensive XML or Java-based configuration
- Spring Boot uses convention over configuration. Auto-configuration based on classpath dependencies, reducing
  boilerplate code.

### Embedded Servers:

- Spring applications typically require an external server (e.g., Tomcat, Jetty) to be configured and deployed.
- Spring Boot includes embedded servers (Tomcat, Jetty, or Undertow by default), allowing applications to run
  standalone with a simple java -jar command.

### Starter Dependencies:

- Spring requires manual dependency management, which can lead to version conflicts.
- Spring Boot provides starter POMs (e.g., spring-boot-starter-web, spring-boot-starter-data-jpa) that bundle
  compatible dependencies, simplifying dependency management.

### Production-Ready Features:

- Traditional Spring requires manual setup for such features.
    - Spring Boot includes Spring Boot Actuator, offering built-in monitoring, health checks, and metrics for production
      environments.

### Rapid Development:

- Spring’s manual configuration slows down initial development.
- Spring Boot’s auto-configuration and starters enable faster setup and prototyping.

### Microservices Support:

- Traditional Spring requires additional configuration for microservices patterns.
- Spring Boot is designed with microservices in mind, offering tools like Spring Cloud for distributed systems.

## 3. Springboot 2.x vs Springboot 3.x?

### Upgrading from Spring Boot 2.x to 3.x requires careful planning:

- Java 17 Upgrade: Ensure your codebase is compatible with Java 17.
- Jakarta EE Migration: Update imports from javax.# to jakarta.#.
- Dependency Updates: Use compatible versions of libraries (e.g., Hibernate, Spring Data).
- AOT and Native Images: Refactor code to support AOT compilation if targeting GraalVM.
- Testing: Update tests for new APIs and Testcontainers integration.
- Micrometer 1.10+ & Observability API (replaced Sleuth, supports OpenTelemetry).
- Declarative HTTP Interface (replaces RestTemplate/Feign).

## 4. How Springboot Auto Configuration Works internally?

- Springboot uses @EnableAutoConfiguration and spring.factories file to load auto-configuration classes using
  AutoConfigurationImportSelector.

## 5. Can you tell me about @SpringBootApplication annotation?

- @SpringBootApplication is a meta annotation that includes @ComponentScan, @Configuration and @Enable Configuration.

## 6. How do you customize auto configuration?

- We can use @ConditionalOnProperty, @ConditionalOnClass in custom configuration classes?

## 7. How do you override default properties in Springboot?

- use application.properties, application.yml or pass as JVM arguments.
- It also loads external configuration properties
  using application.properties , JVM arguments, command line args and @PropertySource.

## 8. Explain Springboot actuators and its use cases? How do you implement custom actuator endpoints?

- Actuator provides production ready features like metrics, health checks and info end points.
- custom end point

```java

@Component
@Endpoint(id = "custom")
public class CustomEndPoint {
    @ReadOperation
    public String getData() {
        return "Custom Endpoint Data";
    }
} 
```

## 9. Define Spring Dependency Injection?

- Dependency Injection (DI) is a design pattern used in object-oriented programming to implement Inversion of Control (
  IoC), where the control of creating and managing dependencies is transferred from the class to an external framework
  or container.
- A container (e.g., Spring’s IoC container) manages the creation, configuration, and lifecycle of objects (beans).
- The container injects dependencies into a class at runtime, based on configuration (e.g., annotations, XML, or Java
  config).

## 10. What is Inversion Of Control?

- Instead of a class creating its own dependencies (e.g., using the new keyword), the dependencies are provided ("
  injected") by an external entity, typically a framework like Spring.


## 17.How do Spring Profiles work ?

- Use @Profile annotation and application-{Profile}.properties to configure environments.

## 18.How do you secure a Springboot Rest API using JWT Token?

- We use filters to intercept requests and validate JWT Tokens using libraries like jjwt.

## 19. difference between @ConfigurationProperties and @Value?

- @Value is for single value injection.
- @ConfigurationProperties binds an entire POJO to configuration.

## 20. How do you customize embedded Tomcat server in springboot?

- We need to Implement WebServerFactoryCustomizer

```java

@Bean
public WebServerFactoryCustomizer<TomcatServletWebServerFactory> customizer() {
    return factory -> factory.setPort(8080);
}
```

## 21. How do you create a custom starter in Springboot?

- Create a library module
- Add META-INF/spring.factories or spring/org.springframewrok.boot.configure.AutoConfiguration.imports
- provide autoconfiguration classes

```java

@Configuration
public class MyLibraryAutoConfiguration {
    @Bean
    public MyService myService() {
        return new MyService();
    }
}
```

- spring.factories:

```properties
org.springframework.boot.autoconfigure.EnabledAutoConfiguration=\com.example.MyLibraryAutoConfiguration
```

## 22. How do you handle circular dependencies in sprinboot?

- Spring boot tries to resolve circular dependencies via setter injection or @Lazy annotation.
- Construction injection with circular dependencies will fail fast.
- spring.main.allow-circular-references=true in properties (this is not recommended for production lead to runtime
  issues)



## 24. How will you reduce springboot startup time?

- use lazy initialization (spring.main.lazy-initialization=true)
- Remove unused starters
- Enable parallel classpath scanning
- Profile slow beans via actuator.

## 25. How do you implement a scheduled task with dynamic cron expression?

- Use @Scheduled with a dynamic expression from a bean or DB using ##SchedulingConfigurer##

## 26. Interceptors Vs Filters

- Interceptors (from Spring MVC) and Filters (from Servlet API) allow pre/post-processing of HTTP requests, but they
  operate at different layers and serve different purpose.
- Filters operate at the lowest level (Servlet container, before the request reaches Spring).
- Filters can modify requests/responses (headers, body, etc.).
- Filters cannot access to Spring context (e.g., @Autowired beans).
- Inceptor operate after Filters but before Controllers.
- Inceptors have access to Spring context (e.g., @Autowired dependencies).
- Interceptors can modify the model/view (but not the raw request/response).

## 27. How does spring manage thread safety of its beans?

- Spring manages bean thread safety based on their scope:
- Singleton (default): One instance shared across the app. Not thread-safe if stateful; developers must use
  synchronization or make them stateless for safety.
- Prototype: New instance per request, generally thread-safe as each thread gets its own copy.
- Request/Session: Web-specific scopes create instances per HTTP request or session, safe within their context.
- Spring encourages stateless beans, which are inherently thread-safe. For stateful beans, use prototype scope or
  synchronization. Spring's core container and tools like RequestContextHolder or @Transactional are thread-safe, but
  developers must ensure thread safety for mutable bean state.

## 28. How to get number of beans in project?

- o get the number of beans managed by the Spring Boot application context, you can use the ApplicationContext interface
  which provides access to all Spring beans
- Using Actuator Endpoints If using Spring Boot Actuator, you can check bean info via
  HTTP (http://localhost:8080/actuator/beans)

```java

@Component
public class BeanCounter {

    @Autowired
    private ApplicationContext applicationContext;

    public int getNumberOfBeans() {
        // Returns the count of all bean definition names in the context
        return applicationContext.getBeanDefinitionNames().length;
    }
} 
```