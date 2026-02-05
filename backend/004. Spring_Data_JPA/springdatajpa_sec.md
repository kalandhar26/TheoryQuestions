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