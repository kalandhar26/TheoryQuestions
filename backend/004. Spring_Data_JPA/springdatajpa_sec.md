## 1. How do you handle data base migrations in your application?

- I use Flyway or Liquibase with Spring Boot to manage database migrations, running them via Kubernetes init containers
  before the main pod starts, with credentials from AWS Secrets Manager injected via Helm, ensuring backward-compatible,
  automated updates. Rollbacks are handled with Helm rollback and Flyway repair or Liquibase tagged rollbacks.

### Flyway Setup

- You’re using Flyway to manage database changes in your Spring Boot microservices. Here’s how it works:

1. **Adding Flyway:**

    - You include the spring-boot-starter-flyway dependency in your Spring Boot project, This pulls in Flyway and
      integrates it with Spring Boot.

2. **Where Migration Files Live:**

    - Your database migration scripts are stored in the src/main/resources/db/migration folder.
    - You use SQL files (e.g., V1__create_users_table.sql, V2__add_email_column.sql) for schema changes.
    - You also place Java files (for more complex migrations) in the same folder, alongside the SQL files.

3. **How Migrations Run:**

    - Spring Boot automatically runs Flyway migrations when your microservice starts. It checks the database, compares
      it to
      the migration scripts, and applies any new ones in order (based on version numbers like V1, V2, etc.).
    - You make sure all migrations are backward-compatible (e.g., adding a new column without breaking existing code)
      and idempotent (can be run multiple times without causing errors).

4. **Kubernetes Setup:**

    - Instead of relying on Spring Boot to run migrations during startup, you use a Kubernetes init container. This is a
      special container that runs a flyway migrate command before the main microservice container starts.
    - The init container ensures the database is updated before your application starts handling requests.

5. **Credentials:**

    - Database credentials (like username and password) are stored securely in AWS Secrets Manager.
    - You use Helm (a Kubernetes package manager) to inject these credentials into the init container and main container
      as environment variables. For example, the database URL, username, and password are passed to Flyway securely.

6. **Rollback:**

    - If something goes wrong, you can roll back the deployment using Helm rollback to revert to the previous version of
      the application.
    - For the database, you run flyway repair to fix any issues in Flyway’s schema history table (e.g., if a migration
      failed and needs to be retried).

7. **Packaging:**

    - All migration scripts (SQL and Java) are packaged inside the microservice’s JAR file (built by Spring Boot). This
      means you don’t run migrations manually—everything is automated and shipped with the application.

### Liquibase Setup

    - You also use Liquibase as an alternative for some microservices. Here’s how it works:

1. **Adding Liquibase:**

    - You include the spring-boot-starter-liquibase dependency in your Spring Boot project to enable Liquibase.

2. **Changelog Files:**

    - Your database changes are defined in a master changelog file,
      src/main/resources/db/changelog/db.changelog-master.xml.
    - Each change (like creating a table or adding a column) is written as a change-set with a unique ID and a
      checksum (to ensure the change hasn’t been modified).

3. **How Migrations Run:**

    - Similar to Flyway, Spring Boot can automatically run Liquibase migrations on startup, applying all new change-sets
      in the changelog.
    - You use the same Kubernetes init container approach, where the init container runs liquibase update to apply
      migrations before the main application container starts.

4. **Tagging Releases:**

    - After applying migrations in production, you tag the database with a label like prod-2024-08-08 using liquibase
      tag.
    - If you need to roll back, you can run liquibase rollback prod-2024-08-08, and Liquibase will undo changes up to
      that tag. This makes rollbacks simple and precise.

5. **Credentials:**

    - Like Flyway, database credentials come from AWS Secrets Manager and are injected as environment variables using
      Helm.

6. **Packaging:**

    - The Liquibase changelog files are included in the microservice’s JAR file, so migrations are fully automated and
      shipped with the application.

### Common Points for Both Flyway and Liquibase

- Automation: Both tools integrate with Spring Boot, so migrations can run automatically on startup, but you prefer
  using Kubernetes init containers for better control.
- Packaging: Migration scripts (SQL/Java for Flyway, XML for Liquibase) are bundled inside the microservice’s JAR file,
  ensuring everything is self-contained.
- No Manual Execution: You don’t run migrations manually. They’re either triggered by Spring Boot or the init container
  during deployment.
- Kubernetes and AWS:
    - The init container pattern ensures migrations happen before the application starts, avoiding race conditions.
      Helm manages the deployment and injects credentials from AWS Secrets Manager securely.
- Rollback:
    - For Flyway, you use helm rollback for the application and flyway repair for database issues.
    - For Liquibase, you use helm rollback and liquibase rollback with tagged releases for precise database rollbacks.

# 1. ORM Fundamentals

## 1.1 What problem does Hibernate solve compared to JDBC?

## 1.2 What is ORM and why is it risky in banking systems if misunderstood?

## 1.3 Difference between Hibernate and JPA.

## 1.4 Why Spring Data JPA is a wrapper, not a replacement for Hibernate?

## 1.5 What are the costs of ORM abstraction?

## 1.6 When should you avoid ORM and use native SQL in banking?

# 2. Entity Mapping Basics

## 2.1 Difference between @Entity, @Table, and @MappedSuperclass.

## 2.2 How does Hibernate map Java objects to relational tables?

## 2.3 What is a primary key and why is it critical in banking entities?

## 2.4 Difference between @Id, @EmbeddedId, and @IdClass.

## 2.5 Why UUID vs sequence-based IDs – which is safer in distributed banking?

## 2.6 How do you map legacy banking tables to entities?

# 3. Entity Lifecycle & Persistence Context

## 3.1 What are entity states (Transient, Persistent, Detached, Removed)?

## 3.2 What is Persistence Context and why does it matter?

## 3.3 How does Hibernate ensure first-level cache consistency?

## 3.4 What happens when you modify a managed entity without calling save()?

## 3.5 What is dirty checking and why can it cause unexpected updates?

## 3.6 How does entity detachment affect transaction safety?

# 4. Transactions & Consistency

## 4.1 How does Hibernate integrate with Spring transactions?

## 4.2 What happens if a transaction rolls back after entity changes?

## 4.3 Difference between @Transactional at service vs repository layer.

## 4.4 Why should transaction boundaries not be placed at controller level?

## 4.5 How does isolation level affect Hibernate behavior?

## 4.6 Can Hibernate manage transactions across microservices? Why not?

# 5. Fetching Strategies & Performance

## 5.1 Difference between EAGER and LAZY fetching.

## 5.2 Why EAGER fetching is dangerous in banking apps?

## 5.3 What is N+1 query problem and how does it occur?

## 5.4 How do @EntityGraph and JOIN FETCH solve N+1?

## 5.5 When should you use projections instead of entities?

## 5.6 How do you fetch large datasets without killing memory?

# 6. Associations & Relationships

## 6.1 One-to-One, One-to-Many, Many-to-One, Many-to-Many – banking examples.

## 6.2 Owning side vs inverse side – why it matters?

## 6.3 Why bidirectional mappings are dangerous if misused?

## 6.4 Cascade types – when NOT to use CascadeType.ALL.

## 6.5 Orphan removal – what problem does it solve?

## 6.6 How do you model joint accounts safely?

# 7. Spring Data JPA Repositories

## 7.1 What problem do JPA repositories solve?

## 7.2 Difference between CrudRepository, JpaRepository, PagingAndSortingRepository.

## 7.3 How does Spring generate query methods from method names?

## 7.4 Why long derived queries are a code smell?

## 7.5 When should you use @Query instead?

## 7.6 How do projections improve read performance?

# 8. Querying Techniques

## 8.1 JPQL vs native SQL – tradeoffs in banking.

## 8.2 Criteria API – when is it useful?

## 8.3 How do you implement dynamic search filters?

## 8.4 Pagination vs streaming – which suits transaction history?

## 8.5 How do you optimize count queries?

## 8.6 How do you prevent SQL injection with JPA?

# 9. Locking & Concurrency Control

## 9.1 Why is concurrency control critical in banking?

## 9.2 Optimistic vs pessimistic locking – differences.

## 9.3 How does @Version prevent lost updates?

## 9.4 When should you use PESSIMISTIC_WRITE?

## 9.5 How does Hibernate behave under high contention?

## 9.6 What happens if two transfers update same account row?

# 10. Batch Processing & Bulk Operations

## 10.1 How does Hibernate handle batch inserts/updates?

## 10.2 Why should you flush and clear persistence context in batches?

## 10.3 Bulk JPQL updates – what’s the risk?

## 10.4 How do bulk operations bypass Hibernate cache?

## 10.5 How do you process millions of records safely?

# 11. Caching with Hibernate

## 11.1 First-level vs second-level cache differences.

## 11.2 Should second-level cache be used for banking data?

## 11.3 What entities are safe to cache (reference data)?

## 11.4 How does Hibernate integrate with Redis/Ehcache?

## 11.5 Why caching entities with balances is dangerous?

# 12. Auditing & Compliance

## 12.1 How do you implement audit fields (createdBy, updatedAt)?

## 12.2 Hibernate Envers – how does it help auditing?

## 12.3 How do you ensure immutability of audit logs?

## 12.4 How do you track who changed what and when?

## 12.5 How do you handle regulatory audits with ORM data?

# 13. Schema Management & Migrations

## 13.1 Why ddl-auto=update is dangerous in production?

## 13.2 Flyway vs Liquibase – which is safer for banking?

## 13.3 How do you manage schema evolution without downtime?

## 13.4 How do you version database changes?

## 13.5 How do you rollback schema changes safely?

# 14. Error Handling & Debugging

## 14.1 Common Hibernate exceptions and root causes.

## 14.2 How do you handle LazyInitializationException properly?

## 14.3 Why does Hibernate throw NonUniqueObjectException?

## 14.4 How do you debug slow Hibernate queries?

## 14.5 How do you log SQL safely in production?

# 15. Microservices & JPA

## 15.1 Why each microservice should own its database?

## 15.2 How do you avoid cross-service entity sharing?

## 15.3 How do you handle joins across services?

## 15.4 How does eventual consistency affect ORM usage?

## 15.5 Should entities be exposed in REST APIs? Why not?

# 16. Real-World Banking Scenarios

## 16.1 Fund transfer – how do you ensure atomic debit and credit?

## 16.2 High-volume salary credit – how do you optimize JPA writes?

## 16.3 Reconciliation job – how do you detect mismatches efficiently?

## 16.4 How do you handle historical transaction data archiving?

## 16.5 How do you design read-optimized vs write-optimized entities?

# 17. Testing Hibernate & JPA

## 17.1 How do you unit test repositories?

## 17.2 @DataJpaTest vs full context – when to use what?

## 17.3 How do you test transactional rollbacks?

## 17.4 How do you test concurrency issues?

## 17.5 How do you test database-specific behavior?

## 18. Anti-Patterns & Failure Stories

## 18.1 Why entities should not contain business logic?

## 18.2 Why exposing entities directly in APIs is dangerous?

## 18.3 How EAGER fetching caused production outage.

## 18.4 How missing @Version caused double debit.

## 18.5 How improper cascade deleted critical banking data.