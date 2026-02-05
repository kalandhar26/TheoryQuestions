### 1. Why Constructor Injection is preferred over Setter Injection?

- Construction Injection enables Immutability and ThreadSafe as it enables final fields. objects become immutable
  after construction. prevents accidental modification after initialization.
- Constructor guarantees all dependencies are provided. Constructor injection fails fast if circular dependencies exist

### 2. Why Spring Boot Over Spring?

#### Simplified Configuration:

- Spring requires extensive XML or Java-based configuration
- Spring Boot uses convention over configuration. Auto-configuration based on classpath dependencies, reducing
  boilerplate code.

#### Embedded Servers:

- Spring applications typically require an external server (e.g., Tomcat, Jetty) to be configured and deployed.
- Spring Boot includes embedded servers (Tomcat, Jetty, or Undertow by default), allowing applications to run
  standalone with a simple java -jar command.

#### Starter Dependencies:

- Spring requires manual dependency management, which can lead to version conflicts.
- Spring Boot provides starter POMs (e.g., spring-boot-starter-web, spring-boot-starter-data-jpa) that bundle
  compatible dependencies, simplifying dependency management.

#### Production-Ready Features:

- Traditional Spring requires manual setup for such features.
    - Spring Boot includes Spring Boot Actuator, offering built-in monitoring, health checks, and metrics for production
      environments.

#### Rapid Development:

- Spring’s manual configuration slows down initial development.
- Spring Boot’s auto-configuration and starters enable faster setup and prototyping.

#### Microservices Support:

- Traditional Spring requires additional configuration for microservices patterns.
- Spring Boot is designed with microservices in mind, offering tools like Spring Cloud for distributed systems.

### 3. Springboot 2.x vs Springboot 3.x?

#### Upgrading from Spring Boot 2.x to 3.x requires careful planning:

- Java 17 Upgrade: Ensure your codebase is compatible with Java 17.
- Jakarta EE Migration: Update imports from javax.# to jakarta.#.
- Dependency Updates: Use compatible versions of libraries (e.g., Hibernate, Spring Data).
- AOT and Native Images: Refactor code to support AOT compilation if targeting GraalVM.
- Testing: Update tests for new APIs and Testcontainers integration.
- Micrometer 1.10+ & Observability API (replaced Sleuth, supports OpenTelemetry).
- Declarative HTTP Interface (replaces RestTemplate/Feign).

### 4. How Springboot Auto Configuration Works internally?

- Springboot uses @EnableAutoConfiguration and spring.factories file to load auto-configuration classes using
  AutoConfigurationImportSelector.

### 5. Can you tell me about @SpringBootApplication annotation?

- @SpringBootApplication is a meta annotation that includes @ComponentScan, @Configuration and @Enable Configuration.

### 6. How do you customize auto configuration?

- We can use @ConditionalOnProperty, @ConditionalOnClass in custom configuration classes?

### 7. How do you override default properties in Springboot?

- use application.properties, application.yml or pass as JVM arguments.
- It also loads external configuration properties
  using application.properties , JVM arguments, command line args and @PropertySource.

### 8. Explain Springboot actuators and its use cases? How do you implement custom actuator endpoints?

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

### 9. Define Spring Dependency Injection?

- Dependency Injection (DI) is a design pattern used in object-oriented programming to implement Inversion of Control (
  IoC), where the control of creating and managing dependencies is transferred from the class to an external framework
  or container.
- A container (e.g., Spring’s IoC container) manages the creation, configuration, and lifecycle of objects (beans).
- The container injects dependencies into a class at runtime, based on configuration (e.g., annotations, XML, or Java
  config).

### 10. What is Inversion Of Control?

- Instead of a class creating its own dependencies (e.g., using the new keyword), the dependencies are provided ("
  injected") by an external entity, typically a framework like Spring.

### 17.How do Spring Profiles work ?

- Use @Profile annotation and application-{Profile}.properties to configure environments.

### 18.How do you secure a Springboot Rest API using JWT Token?

- We use filters to intercept requests and validate JWT Tokens using libraries like jjwt.

### 19. difference between @ConfigurationProperties and @Value?

- @Value is for single value injection.
- @ConfigurationProperties binds an entire POJO to configuration.

### 20. How do you customize embedded Tomcat server in springboot?

- We need to Implement WebServerFactoryCustomizer

```java

@Bean
public WebServerFactoryCustomizer<TomcatServletWebServerFactory> customizer() {
    return factory -> factory.setPort(8080);
}
```

### 21. How do you create a custom starter in Springboot?

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

### 22. How do you handle circular dependencies in sprinboot?

- Spring boot tries to resolve circular dependencies via setter injection or @Lazy annotation.
- Construction injection with circular dependencies will fail fast.
- spring.main.allow-circular-references=true in properties (this is not recommended for production lead to runtime
  issues)

### 24. How will you reduce springboot startup time?

- use lazy initialization (spring.main.lazy-initialization=true)
- Remove unused starters
- Enable parallel classpath scanning
- Profile slow beans via actuator.

### 25. How do you implement a scheduled task with dynamic cron expression?

- Use @Scheduled with a dynamic expression from a bean or DB using ##SchedulingConfigurer##

### 26. Interceptors Vs Filters

- Interceptors (from Spring MVC) and Filters (from Servlet API) allow pre/post-processing of HTTP requests, but they
  operate at different layers and serve different purpose.
- Filters operate at the lowest level (Servlet container, before the request reaches Spring).
- Filters can modify requests/responses (headers, body, etc.).
- Filters cannot access to Spring context (e.g., @Autowired beans).
- Inceptor operate after Filters but before Controllers.
- Inceptors have access to Spring context (e.g., @Autowired dependencies).
- Interceptors can modify the model/view (but not the raw request/response).

### 27. How does spring manage thread safety of its beans?

- Spring manages bean thread safety based on their scope:
- Singleton (default): One instance shared across the app. Not thread-safe if stateful; developers must use
  synchronization or make them stateless for safety.
- Prototype: New instance per request, generally thread-safe as each thread gets its own copy.
- Request/Session: Web-specific scopes create instances per HTTP request or session, safe within their context.
- Spring encourages stateless beans, which are inherently thread-safe. For stateful beans, use prototype scope or
  synchronization. Spring's core container and tools like RequestContextHolder or @Transactional are thread-safe, but
  developers must ensure thread safety for mutable bean state.

### 28. How to get number of beans in project?

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

### 1. Why Constructor Injection is preferred over Setter Injection?

- Constructor injection is favored in Spring (and dependency injection frameworks in general) because it enforces
  dependencies at the time of object creation, ensuring the object is always fully initialized and in a valid state from
  the moment it's instantiated.
- This prevents partially constructed objects that could lead to runtime errors or
  inconsistent behavior. For example, if a service requires a repository to function, constructor injection guarantees
  the repository is provided immediately, making the class immutable if fields are declared as `final`. This
  immutability
  enhances thread-safety, as the object's state cannot change post-construction, reducing risks in concurrent
  environments.

- In contrast, setter injection allows objects to be created without dependencies, which can result in "zombie" objects
  that fail later when methods are called. Constructor injection also promotes better design by failing fast—if a
  required
  dependency is missing, the application startup fails early with a clear error, aiding debugging. While setter
  injection
  is useful for optional dependencies or circular references, constructor injection aligns with principles like
  immutability and explicit contracts, making it the default recommendation in modern Spring applications.

### 2. Why Spring Boot over Spring Framework?

- Spring Boot simplifies development on top of the core Spring Framework by minimizing boilerplate code through
  autoconfiguration and opinionated defaults. In plain Spring, developers must manually configure beans, data sources,
  and web servers, often leading to verbose XML or Java config files. Spring Boot's starters (e.g.,
  `spring-boot-starter-web`) bundle commonly used dependencies like Spring MVC, Jackson, and Tomcat, ensuring version
  compatibility and reducing "dependency hell."

- It also embeds servers like Tomcat, allowing applications to run as executable JARs without external deployment
  setups,
  which speeds up development and testing. Production features like Spring Boot Actuator provide built-in monitoring (
  health checks, metrics) and externalized configuration, making apps ready for deployment out of the box. Overall,
  Spring
  Boot accelerates prototyping, reduces setup time, and follows the "convention over configuration" philosophy, while
  still allowing full customization—ideal for microservices and cloud-native apps.

### 3. Difference between Spring Boot 2.x and 3.x?

- Spring Boot 3.x, released in late 2022, marks a significant evolution from 2.x by requiring Java 17 as the baseline (
  up
  from Java 8 in 2.x), enabling modern language features like records, sealed classes, and pattern matching. A key
  namespace shift occurred: dependencies and APIs migrated from `javax.*` (e.g., `javax.persistence`) to `jakarta.*` to
  align with the Eclipse Foundation's Jakarta EE, necessitating updates in code, build tools (e.g., Maven/Gradle
  plugins),
  and third-party libraries.

- Observability improved with native integration of Micrometer 1.10+ and OpenTelemetry for distributed tracing,
  replacing
  some legacy metrics approaches. Deprecated features from Spring Framework 6 (e.g., certain XML support, old security
  modules) were removed, so migration involves auditing code for removals, updating tests, and handling breaking changes
  in areas like caching and validation. Tools like the Spring Boot Migrator help, but thorough refactoring and
  compatibility testing are essential for a smooth upgrade.

### 4. How does Spring Boot Auto-Configuration work internally?

- Spring Boot's autoconfiguration is powered by the `@EnableAutoConfiguration` annotation (part of
  `@SpringBootApplication`), which conditionally loads beans based on the application's classpath. At startup, Spring
  Boot scans for autoconfiguration classes in `META-INF/spring.factories` (or via `@AutoConfiguration` imports in 3.x+),
  prioritizing them by `@AutoConfigureOrder` or precedence.

- Each auto-config class uses `@Conditional*` annotations (e.g., `@ConditionalOnClass`, `@ConditionalOnMissingBean`) to
  check conditions like the presence of dependencies (e.g., if H2 is on the classpath, an in-memory database is
  auto-configured). Matching conditions trigger bean creation, such as a `DataSource` for JPA. This "convention over
  configuration" detects setups (e.g., web vs. batch) and applies sensible defaults, but users can exclude classes via
  `@SpringBootApplication(exclude = ...)` or properties like `spring.autoconfigure.exclude`. Internally, it's a
  sophisticated matching engine that ensures minimal intervention while allowing overrides.

### 5. What is `@SpringBootApplication`?

- `@SpringBootApplication` is a convenience meta-annotation that combines three core annotations:
  `@SpringBootConfiguration` (which extends `@Configuration` for defining beans), `@EnableAutoConfiguration` (for
  conditional bean loading based on classpath), and `@ComponentScan` (to automatically detect and register `@Component`,
  `@Service`, etc., in the base package and subpackages).

- Placed on the main class (e.g., with `SpringApplication.run()`), it serves as the entry point, triggering the entire
  Spring context bootstrap. For example:

```java

@SpringBootApplication
public class MyApp {
    public static void main(String[] args) {
        SpringApplication.run(MyApp.class, args);
    }
}
```

- This scans for components, enables auto-config, and starts the embedded server if applicable. It's customizable via
  attributes like `scanBasePackages` or `exclude`. Without it, you'd need to annotate separately, increasing
  boilerplate—making it essential for concise, idiomatic Spring Boot apps.

### 6. How do you customize auto-configuration?

- Customization occurs through conditional annotations that fine-tune when and how auto-config beans are loaded,
  ensuring
  flexibility without disabling entire features. For instance,
  `@ConditionalOnProperty(name = "app.feature.enabled", havingValue = "true")` loads a bean only if a specific property
  is
  set in `application.properties`. Other conditionals include `@ConditionalOnClass` (checks for a class presence, e.g.,
  for optional integrations) or `@ConditionalOnWebApplication` (for web-specific configs).

- You can also create custom auto-config classes by placing them in a `META-INF/spring` directory with an
  `AutoConfiguration.imports` file listing them. To override defaults, define a bean with higher precedence (e.g., via
  `@Primary`) or exclude via properties (`spring.autoconfigure.exclude=org.example.MyConfig`). This approach maintains
  the "sensible defaults" while allowing environment-specific tweaks, like disabling database auto-config in tests.

### 7. How do you override default properties in Spring Boot?

- Spring Boot's externalized configuration follows a hierarchical override mechanism, prioritizing sources from most to
  least specific: command-line arguments (e.g., `--server.port=8081`) override environment variables (e.g.,
  `SERVER_PORT=8081`), which override `application.yml/properties` files. Profiles add layers, like
  `application-dev.yml`
  for development.

- Files can be in `src/main/resources`, packaged in the JAR, or external (e.g., in `/config` directory). YAML offers
  nested structures for readability (e.g., `server: port: 8081`), while properties is key-value flat. For dynamic
  overrides, use `@Value("${property:default}")` in code or `Environment` bean. This design supports 12-factor app
  principles, enabling config changes without recompilation—crucial for cloud deployments where secrets (e.g., via
  Vault)
  are injected at runtime.

### 8. What are Spring Boot Actuators and use cases?

- Spring Boot Actuator exposes production-ready endpoints for introspection and management, accessible via `/actuator` (
  e.g., `/actuator/health` for app status, `/actuator/metrics` for JVM/HTTP stats). It integrates with Micrometer for
  observability, allowing export to Prometheus, Grafana, or cloud tools like AWS CloudWatch.

- Use cases include monitoring (track CPU/memory usage), health checks (Kubernetes liveness/readiness probes to detect
  failures), auditing (info endpoint for build/version details), and debugging (loggers endpoint to adjust levels
  dynamically). Security is configurable via `management.endpoints.web.exposure.include=*` and Spring Security. Custom
  endpoints extend this:

```java

@Component
@Endpoint(id = "custom")
public class CustomEndpoint {
    @ReadOperation
    public String data() {
        return "Custom data";
    }
}
```

- Actuator transforms apps from development artifacts to observable, resilient services.

### 9. What is Dependency Injection in Spring Boot?

- Dependency Injection (DI) is a core Spring principle where objects receive their required dependencies (e.g.,
  services,
  repositories) from an external source—the Inversion of Control (IoC) container—rather than creating them internally
  via
  `new`. This decouples code, making it modular and testable (e.g., mock dependencies in unit tests).

- In Spring Boot, the container (ApplicationContext) scans for `@Component`-annotated classes and injects via
  constructors, setters, or fields (e.g., `@Autowired`). Benefits include loose coupling (change implementations without
  touching consumers), reusability, and maintainability. For example, a controller injects a service:
  `@Autowired private UserService userService;`. DI enables scalable architectures like microservices, where wiring is
  declarative and centralized.

### 10. What is Inversion of Control (IoC)?

- Inversion of Control (IoC) flips the traditional flow: instead of a class controlling its dependencies' lifecycle (
  e.g.,
  manually instantiating collaborators), the framework (Spring's IoC container) takes responsibility for creating,
  configuring, and managing objects (beans). This "inverts" control from the application code to the container.

- In practice, you define beans via annotations (`@Component`) or config (`@Bean`), and Spring handles instantiation,
  injection, and destruction. Benefits: reduced boilerplate, better modularity, and easier testing. For instance,
  without
  IoC, you'd write `UserService service = new UserService(new RepositoryImpl())`; with IoC, Spring wires it
  automatically.
  Spring Boot enhances this with auto-wiring and profiles, making IoC the foundation for enterprise apps.

### 11. What are Spring Boot Starter dependencies?

- Starters are pre-configured dependency management POMs (for Maven) or Gradle plugins that bundle compatible libraries
  for common use cases, eliminating manual version alignment. For example, `spring-boot-starter-web` includes Spring
  MVC,
  Tomcat, Jackson, and validation—everything for a REST API—while `spring-boot-starter-data-jpa` adds Hibernate and
  Spring
  Data.

- Declared in `pom.xml` as
  `<dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>`,
  they follow the "just enough" principle: core starters like `spring-boot-starter` provide logging and auto-config.
  This
  speeds up setup, ensures consistency, and reduces transitive dependency conflicts, making Spring Boot accessible for
  beginners while scalable for experts.

### 12. What is Embedded Server in Spring Boot?

- An embedded server is a lightweight web container bundled within the Spring Boot JAR, eliminating the need for
  external
  installs like Apache Tomcat or Jetty. Spring Boot defaults to Tomcat but supports swaps via
  `spring-boot-starter-jetty`
  or `spring-boot-starter-undertow`.

- Configuration is via properties (e.g., `server.port=8080`), and the app runs via `java -jar myapp.jar`. This enables "
  fat JARs" for easy deployment to containers (Docker/Kubernetes) or cloud platforms, with features like hot-swapping in
  dev. Benefits: faster CI/CD, no server management overhead, and portability—ideal for microservices where each service
  is self-contained.

### 13. What is CommandLineRunner?

- `CommandLineRunner` is a functional interface for executing custom logic after the Spring context is fully loaded but
  before the app fully starts (e.g., post-auto-config). Implement it as a `@Bean` or `@Component`:

```java

@Component
public class MyRunner implements CommandLineRunner {
    @Override
    public void run(String... args) throws Exception {
        System.out.println("App started with args: " + Arrays.toString(args));
    }
}
```

- Use cases: seeding databases, caching warm-up, or one-time migrations. It receives raw `String[]` args from `main()`.
  Multiple runners execute in bean order; it's simple for batch-like init in web or non-web apps.

### 14. What is ApplicationRunner?

- Similar to `CommandLineRunner`, `ApplicationRunner` runs post-context initialization but provides parsed, structured
  arguments via `ApplicationArguments` (e.g., options like `--debug=true` as a map). Implement as:

```java

@Bean
public ApplicationRunner runner() {
    return args -> {
        if (args.containsOption("debug")) {
            System.out.println("Debug mode enabled");
        }
    };
}
```

- It's preferred for CLI-heavy apps needing argument validation/parsing, while `CommandLineRunner` suits simple string
  handling. Both promote separation of startup logic from the main class.

### 15. What is Spring Boot DevTools?

- Spring Boot DevTools is an optional module (`spring-boot-devtools` dependency) that enhances development workflows
  with
  features like automatic classpath restarts (recompiles trigger full context reload in ~2-5 seconds) and live reload (
  updates CSS/JS in browser without refresh via WebSocket).

- It also disables template caching for instant view changes and provides a `/restart` endpoint. Exclusions (e.g.,
  `/static/**`) prevent unwanted restarts. Install via IDE plugins (e.g., Spring Tool Suite). Drawbacks: not for
  production (increases memory); it's a productivity booster, cutting iteration time from minutes to seconds.

### 16. What is application.yml vs application.properties?

- `application.properties` uses a flat, key-value format (e.g., `server.port=8080`), ideal for simple configs or legacy
  compatibility—easy to parse but verbose for nesting.

- `application.yml` (YAML) supports hierarchical structures (e.g., `server: port: 8080`), lists, and anchors for DRY
  configs, making it more readable for complex setups like multi-profile data sources. Both coexist (YAML overrides
  properties if same key), loaded from `classpath:/application.yml`. Choose YAML for maintainability in team
  environments;
  properties for minimalism or scripting.

### 17. What are Spring Profiles?

- Profiles enable environment-specific configurations, activating beans or properties based on active profiles (e.g.,
  `dev`, `prod`). Set via `spring.profiles.active=dev` in properties or `--spring.profiles.active=prod` on command line.

- Annotate classes: `@Profile("dev") @Component public class DevDataSource {}`—only loads in dev. Or use
  profile-specific
  files: `application-dev.yml`. This supports multi-tenancy, testing (e.g., `@ActiveProfiles("test")` in
  `@SpringBootTest`), and cloud portability by externalizing env diffs, reducing "if-else" pollution in code.

### 18. How does Spring Boot load configuration properties?

- Loading follows a predictable order (highest to lowest priority): command-line args > SP EL expressions in config > OS
  env vars > Java system props > profile-specific configs > default `application.properties/yml` (from JAR or external
  dirs like `./config`).

- The `Environment` abstraction aggregates these, with `PropertySource` loaders (e.g., for YAML, JNDI). Randomized ports
  or placeholders (e.g., `${random.int}`) add dynamism. This "externalized configuration" aligns with 12FA, allowing
  runtime tweaks without rebuilds—e.g., database URLs via env vars in Docker.

### 19. Difference between @Value and @ConfigurationProperties?

- `@Value` injects individual properties into fields/methods/params (e.g.,
  `@Value("${app.name:default}") private String name;`), supporting SpEL and defaults. It's simple but scattered for
  related props, lacking type conversion or validation.

- `@ConfigurationProperties(prefix = "app")` binds a prefix group to a POJO (e.g.,
  `public class AppProps { private String name; }`), enabling `@Validated` for constraints and relaxed binding (e.g.,
  `appName` matches `app.name`). Use `@EnableConfigurationProperties` to register. `@ConfigurationProperties` promotes
  type-safety and encapsulation for config classes; `@Value` for one-offs.

### 20. What is @EnableConfigurationProperties?

- `@EnableConfigurationProperties` registers `@ConfigurationProperties` classes with the container when they're not
  auto-detected (e.g., not `@Component`). Add to a `@Configuration` class:

```java

@Configuration
@EnableConfigurationProperties(AppProps.class)
public class AppConfig {
}
```

- It enables binding and validation without scanning overhead. In Spring Boot 2+, many are auto-registered via starters,
  but it's essential for custom or external props classes, ensuring they're instantiated and populated early.

### 21. What is @RestController?

- `@RestController` is a stereotype annotation combining `@Controller` (marks as MVC handler) and `@ResponseBody` (
  serializes return values to HTTP body, e.g., JSON via Jackson). Used for RESTful services:

```java

@RestController
@RequestMapping("/users")
public class UserController {
    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) { ...}
}
```

- It simplifies API development by assuming non-view responses, integrating with auto-config for message converters.
  Ideal
  for microservices returning data, not HTML.

### 22. Difference between @Controller and @RestController?

- `@Controller` handles web requests, typically returning view names (e.g., "home") resolved to templates like
  Thymeleaf,
  for MVC apps serving HTML.

- `@RestController` extends this for APIs, applying `@ResponseBody` to all methods, so returns are direct bodies (
  JSON/XML). Use `@Controller` for traditional web UIs; `@RestController` for stateless services. Both support mappings,
  but `@RestController` reduces annotation clutter in API-heavy projects.

### 23. What is @RequestMapping?

- `@RequestMapping` is a versatile annotation for mapping HTTP requests to handler methods, specifying path (e.g.,
  `/users`), method (GET/POST), headers, params, and consumes/produces media types:

```java
@RequestMapping(value = "/users", method = RequestMethod.GET, produces = "application/json")
```

- It's foundational; specialized variants like `@GetMapping` are shorthand. Supports URI templates (e.g., `/users/{id}`)
  and regex for flexible routing in controllers.

### 24. Difference between @GetMapping and @PostMapping?

- `@GetMapping` handles idempotent, read-only GET requests (e.g., retrieving data), caching-friendly and safe for
  bookmarks—maps to `@RequestMapping(method = GET)`.

- `@PostMapping` processes non-idempotent create/submit actions (e.g., form data), as it can change server state—maps to
  POST. Follow REST conventions: GET for queries, POST for mutations. Both support path vars/params, but misuse (e.g.,
  POST for reads) harms SEO/scalability.

### 25. What is @PathVariable?

- `@PathVariable` binds URI template variables to method params (e.g.,
  `@GetMapping("/users/{id}") public User get(@PathVariable Long id)` extracts "123" from `/users/123` as `id=123L`).

- Required by default; use `required=false` for optionals. Supports names (e.g., `@PathVariable("userId")`) and regex (
  e.g., `@PathVariable @Pattern(regexp="\\d+")`). Essential for REST resource identification, like
  `/orders/{orderId}/items`.

### 26. What is @RequestParam?

- `@RequestParam` extracts query string params (e.g.,
  `@GetMapping("/users") public List<User> search(@RequestParam String name)` from `/users?name=John`), with defaults (
  `defaultValue="all"`) and optionals (`required=false`).

- Handles collections (e.g., `@RequestParam List<String> tags`) and types (auto-converts strings). Use for
  filters/sorts;
  contrasts `@PathVariable` (path) by being appendable, non-hierarchical.

### 27. What is @RequestBody?

- `@RequestBody` deserializes the HTTP request body (e.g., JSON) into a Java object using `HttpMessageConverter` (
  Jackson
  default): `@PostMapping("/users") public User create(@RequestBody User user)`.

- Specify `consumes = MediaType.APPLICATION_JSON`. For large payloads, tune limits. Vital for PUT/POST in REST, assuming
  UTF-8; errors if unparseable (e.g., wrong type).

### 28. What is @ResponseEntity?

- `@ResponseEntity` wraps HTTP responses for full control over status, headers, and body:
-

`@GetMapping("/users/{id}") public ResponseEntity<User> get(@PathVariable Long id) { return ResponseEntity.ok(user); }`.

- Supports builders (`.status(404).build()`) and generics. Use for conditional responses (e.g., 201 Created with
  Location
  header); plain returns imply 200 OK.

### 29. What is @ExceptionHandler?

- `@ExceptionHandler` catches exceptions within a controller, mapping to responses:

```java

@ControllerAdvice // or in controller
@ExceptionHandler(UserNotFoundException.class)
public ResponseEntity<String> handle(UserNotFoundException e) {
    return ResponseEntity.notFound().build();
}
```

- Local to class if in controller; centralizes per-module error handling, improving readability over try-catch.

### 30. What is @ControllerAdvice?

- `@ControllerAdvice` makes a class a global advisor for exception handling, model binding, etc., across all
  controllers (
  scoped via `basePackages`). Combines `@ExceptionHandler`, `@InitBinder`, `@ModelAttribute`.

- E.g., global 404s or validation errors. Use `@RestControllerAdvice` for REST. Enhances maintainability by extracting
  cross-cutting concerns from controllers.

### 31. How do you customize embedded Tomcat?

Customize via `WebServerFactoryCustomizer<TomcatServletWebServerFactory>` bean:

```java

@Bean
public WebServerFactoryCustomizer<TomcatServletWebServerFactory> customizer() {
    return factory -> {
        factory.setPort(8081);
        factory.addConnectorCustomizers(connector -> connector.setProperty("compression", "on"));
    };
}
```

Or properties (`server.tomcat.port=8081`, `server.tomcat.threads.max=200`). For SSL, add connectors. This programmatic
approach suits dynamic configs; properties for static.

### 32. How do you enable HTTPS in Spring Boot?

- Configure `application.yml`:

```yaml
server:
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: password
    key-store-type: PKCS12
```

- Generate keystore via `keytool`. Redirect HTTP to HTTPS with `server.http2.enabled=true` or custom filters.
  Auto-enables
  on port 8443; use for secure APIs, integrating with cert managers in prod.

### 33. How do you reduce Spring Boot startup time?

- Enable lazy init: `spring.main.lazy-initialization=true` (defers non-web beans).
- Audit/trim starters: remove unused (e.g., no JPA? drop data starter).
- Profile with Actuator: `@Timed` or `spring.boot.startup-time` metrics; use async init for heavy beans.
- Optimize scans: limit `scanBasePackages`.
  Target <5s; tools like Spring Boot 3's virtual threads help further.

### 34. What is lazy initialization?

- Lazy initialization (`@Lazy` or global `spring.main.lazy-initialization=true`) creates beans only on first use, not at
  startup. Reduces initial load time by skipping unused components (e.g., optional services).
- Drawbacks: first-call delays, harder debugging. Use for large contexts; web beans remain eager for readiness.

### 35. What is spring.main.allow-bean-definition-overriding?

- This property (`true` by default in Boot 2.1+) allows redefining beans with the same name (e.g., tests overriding prod
  beans). Set to `false` for strictness, preventing accidental overrides in prod—enhances safety but may break tests
  needing mocks.

### 36. What are Filters in Spring Boot?

- Filters implement `Filter` interface, executing at Servlet container level before/after requests (e.g., CORS, auth via
  `HttpServletRequest` wrapping). Register via `@Bean FilterRegistrationBean` or `WebMvcConfigurer`.

- Chainable; order via `@Order`. For logging: log request/response bodies.

### 37. What are Interceptors?

- Interceptors (`HandlerInterceptor`) hook into Spring MVC pipeline: pre-handle (validate), post-handle (modify model),
  after-completion (cleanup). Implement and add via `WebMvcConfigurer#addInterceptors()`.

- Access `HandlerMethod`; Spring-aware, e.g., for auditing executed methods.

### 38. Filter vs Interceptor?

- Filters operate at Servlet spec level (all requests, including static), unaware of Spring—good for low-level (
  security,
  compression).

- Interceptors are MVC-specific, post-filter, with handler/model access—ideal for business logic (locale, logging).
  Filters first, then interceptors.

### 39. What is OncePerRequestFilter?

- Extends `GenericFilterBean` to guarantee one execution per request (avoids forwarding loops). Common for auth (e.g.,
  JWT
  validation) or tracing:

```java
public class AuthFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(...) { ...}
}
```

- Register in config; prevents duplicates in async/error paths.

### 40. What is Bean Scope in Spring Boot?

- Bean scope defines instance lifecycle/sharing: singleton (default, one per context), prototype (new per request),
  request/session (web, per HTTP scope). Set via `@Scope("prototype")`.
- Promotes reuse; mismatches cause memory leaks or inconsistency.

### 41. What are different bean scopes?

- **Singleton**: Shared, default—thread-safe if stateless.
- **Prototype**: New instance per injection—stateful, expensive.
- **Request**: Per HTTP request (needs web context).
- **Session**: Per user session.
- **Application**: ServletContext-wide.
- **Websocket**: Per session.
- Use wisely; most services singleton.

### 42. How does Spring manage thread safety?

- Encourages stateless design (singletons without shared mutable state). For stateful, use prototype or synchronize.
  `@Scope("prototype")` or thread-local storage. Concurrency via `@Async` or `TaskExecutor`. Avoid statics; test with
  `ThreadPoolExecutor`.

### 43. What is @Primary?

- `@Primary` designates a bean as preferred when multiple match (e.g., two `DataSource` impls).
- `@Autowired public void setDataSource(@Primary DataSource ds)` picks it. Resolves ambiguity without `@Qualifier`.

### 44. What is @Qualifier?

- `@Qualifier("specificBeanName")` disambiguates injections: `@Autowired @Qualifier("mockRepo") Repository repo`. Names
  or types; finer than `@Primary`.

### 45. What is @DependsOn?

- `@DependsOn("otherBean")` enforces init order: ensures "otherBean" before this one. For legacy or explicit deps;
  auto-wiring usually suffices.

### 46. What is @Lazy?

- `@Lazy` defers creation until first use (proxy wraps). Global via prop. Breaks circular deps; trades startup speed for
  runtime delay.

### 47. How does Spring Boot handle circular dependencies?

- Constructor injection fails fast (error at startup—preferred). Setter/field allows via proxies (3rd call breaks).
  Avoid
  via redesign; `spring.main.allow-circular-references=true` permits but risks. Use `@Lazy` for one side.

### 48. What is ApplicationContext?

- `ApplicationContext` is Spring's advanced IoC container, extending `BeanFactory`: loads configs, manages lifecycle,
  resolves deps, publishes events. Boot's `AnnotationConfigApplicationContext` variant. Access via
  `SpringApplication.run()` return.

### 49. How to get all beans in application?

- `String[] names = applicationContext.getBeanDefinitionNames();` or
- `Map<String, Object> beans = applicationContext.getBeansOfType(Object.class);`. Iterate for inspection; useful in
  actuators or debug.

### 50. What is Environment in Spring Boot?

- `Environment` abstracts profiles/properties: `environment.getActiveProfiles()`, `environment.getProperty("key")`.
  Inject
- `@Autowired Environment env;`. Resolves placeholders; key for conditional logic.

### 51. What is @PropertySource?

- `@PropertySource("classpath:custom.properties")` loads extra files into `Environment`. On `@Configuration`; multiple
  via
  array. For non-standard locations; Boot auto-loads app props.

### 52. How does Spring Boot handle logging?

- Defaults to SLF4J + Logback (`logback-spring.xml` for patterns). Levels via `logging.level.root=INFO` or
  `logging.level.com.example=DEBUG`. Console/file appenders; integrates Actuator for dynamic changes. Colored output in
  IDEs.

### 53. What is spring.factories?

- `META-INF/spring.factories` (properties file) registers entries like
  `EnableAutoConfiguration=org.example.MyAutoConfig`
  for discovery. Boot scans it for auto-config ordering. In 3.x, prefer `AutoConfiguration.imports`.

### 54. What is auto-restart?

- DevTools feature: monitors classpath (via `FileSystemWatcher`), restarts context on changes (e.g., Java recompiles).
- Excludes static/resources; ~5s vs. full rebuild. Toggle via prop; boosts dev velocity.

### 55. What is graceful shutdown?

- Enabled via `server.shutdown=graceful` (Boot 2.3+): completes in-flight requests during shutdown (timeout via
  `spring.lifecycle.timeout-per-shutdown-phase=30s`). Tomcat/Jetty support; prevents data loss in deploys.

### 56. How does Spring Boot support externalized configuration?

- Via 12FA: props from CLI/env/JNDI/files (YAML/props/profiles/random). `ConfigData` API in 2.4+ for custom sources (
  e.g.,Consul). `@RefreshScope` for runtime reloads; cloud-ready (e.g., Config Server).

### 57. What is @Configuration?

- `@Configuration` marks Java class as bean definition source (like XML <beans>): methods with `@Bean` create instances.
- Proxy-wrapped for lite mode. ProxyMode for performance; core for programmatic config.

### 58. Difference between @Component and @Bean?

- `@Component` (and stereotypes like `@Service`) enables auto-scanning/detection in packages.
- `@Bean` on `@Configuration` methods for explicit, imperative creation (e.g., conditional logic). `@Component`
  declarative; `@Bean` for factories/third-party.

### 59. What is @Conditional?

- `@Conditional(Condition.class)` loads bean if `matches()` true (checks env/classpath/etc.). Composable; base for
- `@ConditionalOn*`. For toggles: profile-based without `@Profile`.

### 60. What is @ConditionalOnMissingBean?

- Loads if no bean of type/name exists: `@Bean @ConditionalOnMissingBean(DataSource.class)`. User overrides auto-config;
  e.g., custom DB if none.

### 61. What is @ConditionalOnProperty?

- `@ConditionalOnProperty(name="app.enabled", havingValue="true", matchIfMissing=false)`: checks prop existence/value.
- Prefix/matchers; for feature flags.

### 62. What is @EventListener?

- `@EventListener` on methods to handle pub-sub events:
- `@EventListener public void on(ApplicationReadyEvent event) { ... }`. Async optional; decouples components.

### 63. What is ApplicationReadyEvent?

- Published after context ready, embedded server started (but before runners). Listen for post-start tasks (e.g., cache
  preload). Differs from `ContextRefreshedEvent` (pre-server).

### 64. What is spring.main.banner-mode?

- Controls ASCII art banner: `console` (default, print), `off` (hide), `log` (to log file). Custom via `banner.txt`; fun
  for branding, suppresses in tests.

### 65. How do you disable specific auto-configuration?

- `@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})` or
- `spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration`. Per-class; for
  tests, `@AutoConfigureAfter`.

### 66. What is health check in Spring Boot?

- Actuator's `/actuator/health` aggregates indicators (DB, disk) into UP/DOWN status (JSON). Custom via
  `HealthIndicator`:
  `return Health.up().withDetail("custom", value).build();`. For orchestration (K8s probes).

### 67. What is readiness vs liveness probe?

- **Readiness**: `/actuator/health/readiness`—checks if accepting traffic (e.g., DB connected); DOWN removes from load
  balancer.
- **Liveness**: `/actuator/health/liveness`—if DOWN, restarts pod. Configure thresholds; separates stability from
  startup.

### 68. How do you create custom health indicators?

Implement `HealthIndicator`:

```java

@Component
public class CustomHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        // Check logic
        return Health.up().withDetail("status", "ok").build();
    }
}
```

- Auto-aggregates; groups via `health.<group>.include`.

### 69. How do you version REST APIs?

- **URI**: `/v1/users` vs `/v2/users`.
- **Header**: `Accept: application/vnd.myapp.v2+json`.
- **Query**: `/users?version=2`.
- URI simplest for routing; headers for clients. Deprecate old, migrate gradually.

### 70. What is statelessness in REST?

No client state stored server-side (use tokens/JWT for auth). Each request self-contained; scales horizontally (add
servers freely). Cookies/sessions violate; enables CDN/caching.

### 71. How does Spring Boot handle JSON?

- Jackson (`@JsonComponent`) auto-serializes via `HttpMessageConverter`. Customize: `@JsonIgnore`, `ObjectMapper` bean.
  Boot 3+ supports records; error handling via `@JsonInclude`.

### 72. What is HttpMessageConverter?

- Converts between HTTP body and Java objects (e.g., `MappingJackson2HttpMessageConverter` for JSON). Registered in
  `HttpMessageConverters`; custom via `WebMvcConfigurer`. Handles XML too.

### 73. How do you handle global exceptions?

- `@ControllerAdvice` with `@ExceptionHandler`: central `@ResponseStatus` or `ResponseEntity`. `@RestControllerAdvice`
  for bodies. Logs stack; consistent 4xx/5xx.

### 74. What is ProblemDetail (Spring 6+)?

- RFC 7807 standard for errors: `ProblemDetail` object with `title`, `detail`, `type` URI. Auto-generated for
  `ResponseEntityExceptionHandler`; e.g.,
  `return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, "User not found");`. Interoperable for APIs.

### 75. How do you enable CORS?

- `@CrossOrigin(origins = "http://localhost:3000")` on controller/method, or global:

```java

@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**").allowedOrigins("*");
    }
}
```

- Filter-based; secure origins/methods for FE-BE.

### 76. How do you schedule tasks?

- `@EnableScheduling` + `@Scheduled(fixedRate = 5000)` on methods (cron too). Thread pool via `TaskScheduler`. For
  batches; `@Async` for non-blocking.

### 77. How do you use dynamic cron?

- Implement `SchedulingConfigurer`:

```java

@Configuration
@EnableScheduling
public class SchedulerConfig implements SchedulingConfigurer {
    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        taskRegistrar.addCronTask(() -> myTask(), "0 */5 * * * ?");
    }
}
```

- Runtime changes via props/Actuator; flexible for envs.

### 78. What is @Async?

- `@Async` offloads methods to thread pool (non-blocking): return `CompletableFuture`. Caller continues; exceptions via
  `AsyncUncaughtExceptionHandler`.

### 79. How do you enable async?

- `@EnableAsync` on config; custom `TaskExecutor` bean (e.g., `@Bean ThreadPoolTaskExecutor`). Timeout via
  `AsyncConfigurer`. For I/O-heavy; monitor pool size.

### 80. What is TaskExecutor?

- `TaskExecutor` (extends `Executor`) manages async threads: `SimpleAsyncTaskExecutor` (new per task) or
  `ThreadPoolTaskExecutor` (pooled). Inject for manual submits; `@Async` uses it.

### 81. How do you handle graceful shutdown?

- `server.shutdown=graceful` + timeout prop. Hooks via `SmartLifecycle`; completes tasks. Jetty/Tomcat support; for
  zero-downtime deploys.

### 82. How do you expose metrics?

- Actuator `/actuator/metrics` (Micrometer): JVM, HTTP, custom via `MeterRegistry` (
  `Counter.builder("requests").increment()`). Export to Prometheus: add starter.

### 83. How do you monitor memory usage?

- Actuator metrics: `jvm.memory.used` (heap/non-heap). Custom:
  `Gauge.builder("heap", () -> Runtime.getRuntime().totalMemory()).register(meterRegistry);`. Alerts via Grafana.

### 84. What is spring.main.web-application-type?

- Sets type: `servlet` (default, MVC), `reactive` (WebFlux), `none` (batch). Auto-detects; explicit for hybrids. Affects
  starters/auto-config.

### 85. What is @RestControllerAdvice?

- `@RestControllerAdvice` + `@ExceptionHandler` for global REST errors (JSON `ProblemDetail`). Applies `@ResponseBody`;
  for API-only apps.

### 86. What is @Validated?

- Triggers validation on params/fields (JSR-303): `@Validated @RequestMapping public void method(@Valid User user)`.
  Groups via `groups`; integrates Hibernate Validator.

### 87. How does Spring Boot handle validation?

- `spring-boot-starter-validation` + Bean Validation API. `@Valid` on bodies/params; errors to `BindingResult` or global
  handler. Custom validators via `Validator`.

### 88. What is BindingResult?

- Post-`@Valid` param: captures errors (`if (result.hasErrors()) ...`). Access fields (
  `result.rejectValue("name", "error")`). For conditional processing.

### 89. What is @InitBinder?

- Customizes binding per controller:
  `@InitBinder public void init(WebDataBinder binder) { binder.addValidators(custom); }`. Formats dates, excludes
  fields.

### 90. What is WebMvcConfigurer?

- Interface for MVC customizations: add formatters, interceptors, view resolvers (
  `@Override public void addViewControllers(ViewControllerRegistry registry) { ... }`). Non-invasive extension.

### 91. How do you disable Actuator endpoints?

- `management.endpoints.web.exposure.exclude=health,info` or per-role via Security. Sensitive ones (env, beans) default
  hidden; secure all.

### 92. What is spring.main.allow-circular-references?

- `true` permits circular deps via proxies (default false in 2.6+). Discourages; use for legacy, but redesign preferred.

### 93. How do you handle large file uploads?

- `spring.servlet.multipart.max-file-size=10MB`, `max-request-size=50MB`. CommonsMultipartResolver bean; stream to avoid
  OOM.

### 94. What is MultipartResolver?

- Handles `multipart/form-data`: `StandardServletMultipartResolver` (default). Register bean; for file uploads,
  integrates with `@RequestParam MultipartFile`.

### 95. What is ResponseStatusException?

- Throws for HTTP errors: `throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Not found");`. Body optional;
  handler-free.

### 96. How do you implement API documentation?

- Springdoc OpenAPI (`springdoc-openapi-starter-webmvc-ui`): auto-generates Swagger UI at `/swagger-ui.html` from
  annotations (`@Operation`, `@ApiResponse`). Custom via `OpenAPI` bean; Boot 3 compatible.

### 97. What is spring.config.import?

- Boot 2.4+: `spring.config.import=optional:consul:` loads remote configs (file/classpath/vault). Fallbacks; for
  dynamic, secure props.

### 98. How do you test Spring Boot apps?

- `@SpringBootTest` loads full context; slice tests (`@WebMvcTest` for controllers, `@DataJpaTest` for repos).
  `TestRestTemplate` or `MockMvc` for integration.

### 99. What is @MockBean?

- Mocks/replaces real beans in tests: `@MockBean private UserService service;`. Auto-wires; verifies interactions via
  Mockito.

### 100. How do you prepare Spring Boot app for production?

- Secure: HTTPS, Actuator secured, validation.
- Monitor: Actuator/Micrometer, logging (ELK), health/readiness.
- Config: Externalize, profiles, graceful shutdown.
- Deploy: JAR/Docker, lazy init, no DevTools.
- Test: Coverage, perf/load. Use CI/CD for resilience.

### 101. How would you handle inter-service communication in a microservice architecture using springboot?

- For simple and direct communication, I would use RestTemplate, which allows services to send requests and receive
  responses like a two-way conversation.
- For more complex communication, I would use Feign, which is a declarative web service client. It allows you to define
  interfaces and annotations to describe your service interactions, and Feign will handle the rest, including making the
  HTTP requests and parsing the responses.
- For asynchronous communication, where immediate responses are not necessary, I would use message brokers like RabbitMQ
  and Kafka. They acts like community boards, where services can post messages that other services read and act upon
  later. This approach ensures a robust, flexible communication system between microservices.

### 102. Can you explain the caching mechanisms available in springboot?

- Caching is a technique used to store data in a temporary location so that it can be quickly accessed later.
- Spring Boot provides several caching mechanisms, including:
    - In-memory caching: Spring Boot uses the SimpleCacheManager by default, which stores cache data in memory. This is
      suitable for small-scale applications or for caching data that doesn't change frequently.
    - Distributed caching: Spring Boot supports distributed caching using various technologies such as Redis, Memcached,
      and Ehcache. These caching solutions store cache data in a shared location, making them suitable for large-scale
      applications or for caching data that changes frequently.
    - Caching with Redis: Redis is an in-memory data structure store that can be used as a database, cache, and message
      broker. Spring Boot provides support for Redis caching using the Spring Data Redis library. To enable Redis
      caching, you need to add the `spring-boot-starter-data-redis` dependency to your project and configure the Redis
      connection details in your `application.properties` or `application.yml` file.

#### Implementation

- Add the caching dependency, like spring-boot-starter-cache
- Add a '@EnableCaching' on main class to enable caching.
- Create a cache configuration class to define cache settings.
- Use '@Cacheable' annotation on methods whose results we wanted to cache them.
- We can also customize cache behaviour with annotations like '@CacheEvict' and '@CachePut'
- We can Spring provided cache manager implementations like ConcurrentMapCacheManager, CaffeineCacheManager, etc.
- We can also use customized cache providers like (EhCache or HazelCast or Redis).


