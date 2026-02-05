# Spring Annotations Cheat Sheet

## Core Spring Annotations

| Annotation       | Purpose                                                          |
|------------------|------------------------------------------------------------------|
| `@Required`      | Enforces required property population on setter methods          |
| `@Autowired`     | Implicitly injects dependencies (fields, setters, constructors)  |
| `@Qualifier`     | Resolves ambiguity when multiple beans of the same type exist    |
| `@Configuration` | Defines a class as a source of bean definitions                  |
| `@ComponentScan` | Configures base packages for component scanning                  |
| `@Bean`          | Declares a method as a bean producer in `@Configuration` classes |
| `@Lookup`        | Enables dynamic bean injection (runtime overrides)               |
| `@Lazy`          | Delays bean initialization until first usage                     |
| `@Value`         | Injects property values or SpEL expressions                      |

## Stereotype Annotations

| Annotation    | Purpose                                                               |
|---------------|-----------------------------------------------------------------------|
| `@Component`  | Generic stereotype for Spring-managed beans                           |
| `@Service`    | Specialized `@Component` for service-layer classes                    |
| `@Repository` | Specialized `@Component` for DAO classes (auto exception translation) |
| `@Controller` | Marks a class as a Spring MVC controller                              |

## Spring Boot Annotations

| Annotation                 | Purpose                                                                    |
|----------------------------|----------------------------------------------------------------------------|
| `@SpringBootApplication`   | Combines `@Configuration`, `@EnableAutoConfiguration` and `@ComponentScan` |
| `@EnableAutoConfiguration` | Enables Spring Boot's auto-configuration                                   |
| `@SpringBootTest`          | Bootstraps full context for integration tests                              |
| `@JsonTest`                | Tests JSON serialization/deserialization                                   |
| `@AutoConfigureMockMvc`    | Auto-configures MockMvc for web tests                                      |

## Web/MVC Annotations

| Annotation           | Purpose                                    |
|----------------------|--------------------------------------------|
| `@RequestMapping`    | Maps HTTP requests to handler methods      |
| `@GetMapping`        | Shortcut for GET requests                  |
| `@PostMapping`       | Shortcut for POST requests                 |
| `@PutMapping`        | Shortcut for PUT requests                  |
| `@DeleteMapping`     | Shortcut for DELETE requests               |
| `@PatchMapping`      | Shortcut for PATCH requests                |
| `@RestController`    | Combines `@Controller` and `@ResponseBody` |
| `@RequestBody`       | Binds HTTP request body to parameter       |
| `@ResponseBody`      | Serializes return value to response body   |
| `@PathVariable`      | Extracts URI template variables            |
| `@RequestParam`      | Binds query parameters                     |
| `@RequestHeader`     | Binds HTTP headers                         |
| `@CookieValue`       | Extracts cookies from requests             |
| `@RequestPart`       | Handles multipart file uploads             |
| `@ResponseStatus`    | Customizes HTTP response status            |
| `@CrossOrigin`       | Enables CORS for handlers                  |
| `@SessionAttributes` | Stores model attributes in session         |
| `@ModelAttribute`    | Binds parameters to model attributes       |

## Data Access Annotations

| Annotation       | Purpose                                       |
|------------------|-----------------------------------------------|
| `@Entity`        | Marks class as JPA entity                     |
| `@Table`         | Specifies database table name                 |
| `@Id`            | Marks field as primary key                    |
| `@Column`        | Customizes column mapping                     |
| `@Transactional` | Defines transaction boundaries                |
| `@Repository`    | DAO specialization with exception translation |

## Caching Annotations

| Annotation     | Purpose                                   |
|----------------|-------------------------------------------|
| `@Cacheable`   | Caches method results                     |
| `@CachePut`    | Updates cache without method interference |
| `@CacheEvict`  | Removes cache entries                     |
| `@CacheConfig` | Shared cache configuration                |

## Scheduling & Async

| Annotation   | Purpose                             |
|--------------|-------------------------------------|
| `@Scheduled` | Executes methods at fixed intervals |
| `@Async`     | Executes methods asynchronously     |

## Testing Annotations

| Annotation              | Purpose                            |
|-------------------------|------------------------------------|
| `@DataJpaTest`          | Tests JPA with in-memory database  |
| `@WebMvcTest`           | Tests MVC with mocked services     |
| `@MockBean`             | Creates and injects Mockito mocks  |
| `@TestPropertySource`   | Overrides properties for tests     |
| `@DirtiesContext`       | Forces context reload after test   |
| `@Transactional` (Test) | Rolls back transactions after test |
| `@Commit`               | Commits test transaction           |
| `@Rollback`             | Rolls back test transaction        |
| `@Sql`                  | Executes SQL scripts for tests     |

## Exception Handling

| Annotation              | Purpose                                          |
|-------------------------|--------------------------------------------------|
| `@ExceptionHandler`     | Handles exceptions at controller level           |
| `@ControllerAdvice`     | Global exception handling                        |
| `@RestControllerAdvice` | Combines `@ControllerAdvice` and `@ResponseBody` |
| `@ResponseStatus`       | Customizes HTTP response status                  |