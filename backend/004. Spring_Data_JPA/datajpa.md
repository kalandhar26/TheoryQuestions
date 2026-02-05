### 1. What is Hibernate and why is it used?

- Hibernate is an ORM framework that maps Java objects to database tables. It reduces boilerplate JDBC code and handles
  SQL automatically. In Spring Boot, we just define entities with @Entity and Hibernate manages the persistence.

### 2. What is JPA and how does it relate to Hibernate?

- JPA is a specification for ORM in Java, defining how to map objects to relational databases. Hibernate is a popular
  implementation of JPA that provides extra features. In Spring Boot, we use spring-boot-starter-data-jpa to use
  Hibernate as the JPA provider.

### 3. Difference between Hibernate and JDBC?

- JDBC requires writing raw SQL queries and manually mapping results to objects. Hibernate automates this mapping,
  reduces SQL boilerplate, and provides caching and transaction management. Spring Boot integrates Hibernate, so we can
  focus on entities instead of SQL.

### 4. What is an Entity in JPA?

- An entity is a Java class mapped to a database table. Each entity represents a row in the table. In Spring Boot,
  we annotate it with @Entity and define primary keys with @Id.

### 5. What is @Entity annotation?

- @Entity marks a Java class as a JPA entity. Hibernate scans the class and creates a corresponding table in the
  database.
- For example:

```java

@Entity
public class User {
    @Id
    private Long id;
    private String name;
}

```

### 6. What is `@Table` annotation?

- `@Table` specifies the table name and schema for the entity. If omitted, Hibernate uses the class name as the table
  name. For example: `@Table(name=users)` maps `User` class to `users` table.

### 7. Difference between `@Id` and `@GeneratedValue`?

- `@Id` defines the primary key field, while `@GeneratedValue` tells Hibernate to generate values automatically. You can
  choose strategies like `AUTO`, `IDENTITY`, or `SEQUENCE` for auto-generation.

### 8. What are the different strategies for `@GeneratedValue`?

- `AUTO` lets Hibernate pick the best strategy. `IDENTITY` uses auto-increment columns, `SEQUENCE` uses a DB sequence,
  and `TABLE` uses a separate table to generate IDs. In Spring Boot, `IDENTITY` is commonly used with MySQL.

### 9. What is `@Column` annotation used for?

- `@Column` customizes column properties like name, length, nullable, and unique. Example:

```java

@Column(name = email, nullable = false, unique = true)
private String email;
```

- It tells Hibernate how to map the field to the DB column.

### 10. Difference between @Transient and @Basic?

- @Transient tells Hibernate to ignore the field and not persist it. @Basic marks a simple persistent field, though
  it’s optional because all non-annotated fields are considered basic by default.

### 11. What is @Embedded and @Embeddable?

- @Embeddable marks a class whose fields will be part of the owning entity. @Embedded includes it in the entity. For
  example, an Address object can be embedded inside User without a separate table.

### 12. What is @Enumerated and how is it used?

- @Enumerated maps a Java enum to a database column. By default, it stores ordinal values, but using EnumType.STRING
  stores the enum name. Example:

```java

@Enumerated(EnumType.STRING)
private Status status;
```

### 13. Difference between LAZY and EAGER fetching?

- LAZY loads associated entities only when needed; EAGER loads them immediately. For
  example, `@OneToMany(fetch = FetchType.LAZY)` avoids loading huge collections until accessed, improving performance.

### 14. What is `@OneToOne` relationship and how is it mapped?

- `@OneToOne` defines a one-to-one relationship between entities. Use `@JoinColumn` to specify the foreign key.
  Example:

```java

@OneToOne
@JoinColumn(name = address_id)
private Address address;
```

### 15. What is `@OneToMany` relationship?

- `@OneToMany` maps a parent to multiple child entities. Usually combined with `@ManyToOne` in the child. Example: a
  `User` has many `Orders`.

### 16. What is `@ManyToOne` relationship?

- `@ManyToOne` defines a child entity pointing to a single parent. Example: `Order` has `@ManyToOne User user;` so many
  orders belong to one user.

### 17. What is `@ManyToMany` relationship?

- `@ManyToMany` defines a many-to-many relationship. Usually requires a join table. Example:

```java

@ManyToMany
@JoinTable(
        name = student_course,
        joinColumns = @JoinColumn(name = student_id),
        inverseJoinColumns = @JoinColumn(name = course_id))
private Set<Course> courses;
```

### 18. How do you map bidirectional relationships in Hibernate?

- Use mappedBy on one side to tell Hibernate the owner of the relationship. Example: `@OneToMany(mappedBy=user)` in
  `User` avoids duplicate foreign keys.

### 19. What is `@JoinColumn`?

- `@JoinColumn` specifies the foreign key column for relationships. It tells Hibernate which column to use to join two
  tables.

### 20. Difference between `session.save()` and `session.persist()`?

- Both persist an entity, but `save()` returns the generated ID immediately, while `persist()` doesn’t return anything
  and only guarantees persistence at flush/commit.

### 21. Difference between `session.update()` and `session.merge()`?

- `update()` requires a detached entity and fails if another instance with the same ID exists in session. `merge()`
  copies state and returns a managed instance, avoiding exceptions.

### 22. What is `session.saveOrUpdate()`?

- It either saves a new entity or updates an existing one depending on whether the ID is null or present.

### 23. What is `session.delete()`?

- Deletes the entity from the database. In Spring Boot, `deleteById()` in `JpaRepository` internally uses Hibernate to
  remove the record.

### 24. Difference between `get()` and `load()` in Hibernate?

- `get()` hits the database immediately and returns null if not found. `load()` returns a proxy and throws
  `ObjectNotFoundException` if accessed and not present.

### 25. What is the difference between `persist()` and `merge()`?

- `persist()` only makes a transient entity persistent; `merge()` copies state from detached entity into the current
  persistence context and returns a managed instance.

### 26. What is HQL (Hibernate Query Language)?

- HQL is an object-oriented query language that works on entities instead of tables. Example:
  `from User u where u.name='John'`.

### 27. Difference between HQL and SQL?

- HQL works on entities (Java classes), SQL works on tables. HQL is database-agnostic and allows using object
  relationships directly.

### 28. What is `@NamedQuery`?

- `@NamedQuery` defines a static HQL query with a name. Example:

```java

@NamedQuery(name = User.findByName, query = from
User u
where u.name=:name)
```

### 29. What is `@Query` in Spring Data JPA?

- `@Query` defines a custom query on a repository method. Example:

```java

@Query(select
u from
User u
where u.email=?1)

User findByEmail(String email);
```

### 30. How do you define repository interfaces in Spring Data JPA?

- We extend `JpaRepository<Entity, ID>` or `CrudRepository<Entity, ID>` and Spring Boot provides implementations
  automatically. Example: `public interface UserRepository extends JpaRepository<User, Long>`.

### 31. Difference between `CrudRepository` and `JpaRepository`?

- CrudRepository provides basic CRUD methods; JpaRepository extends it with pagination, sorting, and more advanced
  JPA-specific methods.

### 32. What is the difference between `findById` and `getOne`?

- `findById` immediately hits the database and returns Optional. `getOne` returns a lazy proxy and only queries DB when
  accessed.

### 33. How do you use `@Modifying` and `@Transactional` in custom queries?

- For update/delete queries, annotate the repository method with `@Modifying` and `@Transactional`. Example:

```java
@Modifying
@Transactional
@Query(update
User u
set u.status=:
status where
u.id=:id)

int updateStatus(@Param(id) Long id, @Param(status) Status status);
```

### 34. What is `@GeneratedValue(strategy = GenerationType.IDENTITY)`?

- Tells Hibernate to use the database’s auto-incremented column for ID generation. Commonly used with MySQL or
  PostgreSQL.

### 35. How do you configure Hibernate in Spring Boot?

- In Spring Boot, just add `spring-boot-starter-data-jpa` and configure `spring.datasource.url`, username, password, and
  `spring.jpa.hibernate.ddl-auto=update` in `application.properties`.

### 36. What is the difference between merge() and update() in Hibernate?

- In Hibernate, update() reattaches a detached entity but fails if another instance with the same ID exists in the
  session. merge() is safer because it copies the state into a managed entity and returns that instance, which avoids
  session conflicts.

### 37. What are the states of a Hibernate entity?

- Hibernate entities go through four states: transient (new object, not saved), persistent (attached to session),
  detached (session closed), and removed (marked for deletion). Understanding these helps avoid issues like data not
  getting updated.

### 38. How does Hibernate manage the first-level cache?

- The first-level cache is session-scoped and enabled by default. Hibernate stores entities in the session, so repeated
  reads within the same transaction don’t hit the database again.

### 39. What is the second-level cache in Hibernate?

- Second-level cache is shared across sessions and helps reduce database calls. It’s optional and typically implemented
  using tools like Ehcache or Redis in Spring Boot projects.

### 40. How do you enable caching in Spring Boot with Hibernate?

- We enable second-level cache via properties and add a cache provider like Ehcache. Entities are annotated with
  @Cacheable and configured with @Cache(usage = CacheConcurrencyStrategy.READ_WRITE).

### 41. What are Hibernate Query Hints?

Query hints provide extra instructions to Hibernate, like caching or fetch size. In Spring Data JPA, we use @QueryHints
to optimize query execution.

### 42. Difference between fetch join and normal join?

- A fetch join loads related entities in a single query, avoiding extra selects. Normal joins don’t load associations
  automatically, often causing N+1 issues.

### 43. What is @BatchSize and why is it used?

- @BatchSize tells Hibernate to load collections or entities in batches instead of one by one. It improves performance
  when dealing with large relationships.

### 44. What is the N+1 select problem and how do you solve it?

- N+1 occurs when one query loads parent records and multiple queries load child records. We solve it using fetch joins,
  @EntityGraph, or batch fetching.

### 45. How does Spring Data JPA implement pagination?

- Pagination is implemented using Pageable and Page<T>. Spring automatically adds LIMIT and OFFSET to SQL queries based
  on page number and size.

### 46. How does sorting work in Spring Data JPA?

- Sorting is done using the Sort object or directly inside Pageable. Spring Data automatically applies ORDER BY to
  generated SQL queries.

### 47. What are projections in Spring Data JPA?

- Projections fetch only required fields instead of full entities. This improves performance and reduces memory usage,
  especially in reporting queries.

### 48. Difference between JPQL and Criteria API?

- JPQL is string-based and easier to read, while Criteria API is type-safe and dynamic. Criteria is useful when queries
  are built at runtime.

### 49. How do you use Criteria API in Spring Boot?

- We use EntityManager and CriteriaBuilder to create dynamic queries. It’s commonly used when filters change based on
  user input.

### 50. How do you handle optimistic locking in Hibernate?

- Optimistic locking uses the @Version annotation to detect concurrent updates. If two users update the same record,
  Hibernate throws an exception.

### 51. How do you handle pessimistic locking in Hibernate?

- Pessimistic locking locks the database row using LockModeType.PESSIMISTIC_WRITE. It’s used when data conflicts must be
  prevented strictly.

### 52. What is @Version annotation used for?

- @Version maintains a version column that Hibernate checks during updates. It helps prevent lost updates in concurrent
  environments.

### 53. What is dirty checking in Hibernate?

- Hibernate automatically tracks changes to managed entities. At transaction commit, it updates only modified fields
  without explicit update calls.

### 54. What are cascading operations in Hibernate?

- Cascade operations automatically propagate actions like save, update, or delete from parent to child entities.
  Example: CascadeType.ALL.

### 55. Difference between CascadeType.ALL and specific cascade types?

- ALL applies all operations, while specific types like PERSIST or REMOVE give finer control. Using specific types
  avoids accidental deletes.

### 56. What is orphan removal in Hibernate?

- Orphan removal deletes child entities when they are removed from the parent collection. It ensures database
  consistency automatically.

### 57. Difference between EntityManager and Session?

- EntityManager is the JPA standard interface, while Session is Hibernate-specific. In Spring Boot, we mostly use
  EntityManager for portability.

### 58. How do you use @Transactional in Spring Boot with JPA?

- @Transactional manages database transactions automatically. It ensures commit on success and rollback on exceptions.

### 59. What is flush() in Hibernate?

- Flush synchronizes the persistence context with the database. It doesn’t commit the transaction but sends SQL
  statements to DB.

### 60. Difference between refresh() and clear()?

- refresh() reloads entity state from DB, while clear() removes all entities from the persistence context.

### 61. How do you implement soft delete in Spring Data JPA?

- Soft delete uses a flag like is_deleted instead of removing records. Hibernate filters or custom queries ensure only
  active data is fetched.

### 62. What is Specification in Spring Data JPA?

- Specifications allow building dynamic, reusable queries using Criteria API. They are useful for advanced filtering
  logic.

### 63. How do you write dynamic queries using Spring Data JPA?

- Dynamic queries are built using Specifications, Criteria API, or QueryDSL. This avoids writing multiple hardcoded
  queries.

### 64. What are native queries in Spring Data JPA?

- Native queries use database-specific SQL. They are useful for complex joins or performance-critical operations.

### 65. How do you handle composite primary keys in Hibernate?

- Composite keys are handled using @EmbeddedId or @IdClass. @EmbeddedId is more commonly used for clean design.

### 66. How do you map @ElementCollection in Hibernate?

- @ElementCollection maps non-entity collections like List of Strings. Hibernate creates a separate table automatically.

### 67. How do you configure multiple datasources in Spring Boot with JPA?

- We define multiple DataSource, EntityManagerFactory, and TransactionManager beans. Each datasource is mapped to
  specific entities.

### 68. Difference between @EntityGraph and fetch joins?

- @EntityGraph is cleaner and declarative, while fetch joins are written in queries. Entity graphs are easier to
  maintain.

### 69. How do you handle enum mapping in Hibernate?

- Enums are mapped using @Enumerated(EnumType.STRING) to avoid issues when enum order changes.

### 70. How does Hibernate manage LazyInitializationException?

- LazyInitializationException occurs when a lazy-loaded entity is accessed outside a transaction. We solve it using
  @Transactional, fetch joins, DTO projections, or @EntityGraph to load data within the session.

### 71. How do you solve N+1 select problem in production?

- In production, we avoid N+1 using fetch joins, @EntityGraph, batch fetching, and proper query tuning. We also monitor
  SQL logs to detect such issues early.

### 72. How do you implement multi-tenancy in Hibernate?

- Hibernate supports multi-tenancy using separate schemas, databases, or discriminator columns. In Spring Boot, we
  configure a MultiTenantConnectionProvider and CurrentTenantIdentifierResolver.

### 73. How do you implement database sharding with JPA?

- Sharding is handled at application level by routing requests to different datasources. Spring Boot uses routing
  datasources based on user or tenant context.

### 74. Difference between optimistic and pessimistic locking in production?

- Optimistic locking is preferred for high-read systems using @Version. Pessimistic locking is used when data
  consistency is critical and conflicts must be prevented.

### 75. How do you tune Hibernate performance for large datasets?

- We use pagination, batch inserts, projections, and streaming queries. Second-level caching and query optimization also
  play a key role.

### 76. How do you integrate Hibernate with Redis or second-level cache?

- We configure Redis as a second-level cache using Hibernate cache providers. Entities are marked cacheable to reduce
  database load.

### 77. How do you write complex dynamic queries using Criteria API?

- Criteria API allows building queries dynamically with conditions added at runtime. This is useful for advanced search
  screens with multiple filters.

### 78. How do you implement auditing in Spring Boot with JPA?

- Auditing is implemented using @CreatedDate, @LastModifiedDate, and @EntityListeners(AuditingEntityListener.class).
  Spring Data automatically manages audit fields.

### 79. What are JPA callbacks and how are they used?

- JPA callbacks like @PrePersist and @PreUpdate allow executing logic before or after entity operations. They’re used
  for audit or validation logic.

### 80. How do you implement soft deletes and audit logs together?

- Soft deletes mark records inactive using flags, while audit logs track changes in separate tables. Hibernate filters
  ensure only active records are fetched.

### 81. How do you handle schema evolution in production?

- We use Flyway or Liquibase to version database changes. This ensures schema updates are controlled and backward
  compatible.

### 82. How do you use DTO projections for performance optimization?

- DTO projections fetch only required columns instead of full entities. This reduces memory usage and improves query
  performance.

### 83. How do you avoid Cartesian products in @ManyToMany relationships?

- We avoid unnecessary eager fetching and use join tables carefully. Fetching data in stages or using DTOs prevents
  large result sets.

### 84. How do you handle database migrations in JPA projects?

- We use Flyway or Liquibase integrated with Spring Boot. Migrations are executed automatically during application
  startup.

### 85. How do you implement native SQL queries safely?

- Native queries are written with parameter binding to avoid SQL injection. We avoid string concatenation and use named
  parameters.

### 86. How do you handle bulk updates and deletes efficiently?

- Bulk operations use JPQL or native queries with @Modifying. We clear persistence context after execution to avoid
  stale data.

### 87. How do you configure Hibernate batch inserts and updates?

- Batching is enabled using properties like hibernate.jdbc.batch_size. It significantly improves performance for bulk
  operations.

### 88. How do you implement multi-level caching with Hibernate?

- We use first-level cache by default and second-level cache with Redis or Ehcache. Query cache further improves
  read-heavy workloads.

### 89. How do you optimize entity graphs for performance?

- Entity graphs control which relationships are fetched. They help avoid unnecessary joins and reduce query execution
  time.

### 90. How do you implement read/write separation with multiple datasources?

- Read/write separation uses separate master and replica datasources. Spring routes read queries to replicas and writes
  to master.

### 91. How do you handle soft deletes combined with multi-tenancy?

- Soft deletes use flags while tenant isolation ensures data separation. Filters and tenant resolvers work together to
  enforce constraints.

### 92. How do you monitor Hibernate SQL queries in production?

- We enable SQL logging carefully and use tools like APM or database logs. Slow queries are optimized using indexes and
  query tuning.

### 93. How do you handle optimistic locking conflicts?

- When conflicts occur, Hibernate throws an exception. The application retries or informs the user to reload the latest
  data.

### 94. How do you design repositories for high-performance reporting?

- We use read-only transactions, DTO projections, native queries, and indexes. Reporting repositories are separated from
  transactional ones.

### 95. How do you implement custom repository methods beyond JpaRepository?

- We create custom repository interfaces and implementations using EntityManager. Spring automatically wires them
  together.

### 96. How do you use EntityManager for dynamic native queries?

- EntityManager allows executing native SQL dynamically with parameter binding. It provides more control for complex
  queries.

### 97. How do you prevent LazyInitializationException in complex services?

- We use transaction boundaries, fetch joins, or DTO mapping. Avoiding open-session-in-view is recommended for clean
  architecture.

### 98. How do you handle cascading deletes in deep hierarchies safely?

- We carefully configure cascade types and avoid CascadeType.ALL blindly. Manual deletes are preferred for complex
  hierarchies.

### 99. How do you implement read-only entities for reporting?

- Entities are marked read-only using transaction settings or database views. This prevents accidental updates.

### 100. How do you combine Specifications, Criteria API, and native queries?

- We use Specifications for filtering, Criteria for dynamic conditions, and native queries for performance-critical
  cases. Each is chosen based on use case.
