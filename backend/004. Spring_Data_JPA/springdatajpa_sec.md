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

- Hibernate solves the impedance mismatch between Java objects and relational tables. With JDBC, you manually write SQL,
  handle result sets, and map rows to objects. Hibernate automates this mapping, manages transactions, caching, and
  reduces boilerplate. It also provides portability across databases, while JDBC ties you to vendor-specific SQL.

## 1.2 What is ORM and why is it risky in banking systems if misunderstood?

- ORM (Object-Relational Mapping) maps Java objects to database tables. In banking, misuse can be risky—wrong mappings
  or lazy loading can cause inconsistent balances, performance bottlenecks, or even double debits. If developers treat
  ORM as a “black box,” they may overlook SQL behavior, leading to compliance and financial risks.

## 1.3 Difference between Hibernate and JPA.

- JPA is a specification (like an interface) defining ORM standards. Hibernate is an implementation of JPA, with extra
  features beyond the spec. “JPA tells you what to do, Hibernate shows you how to do it.”

## 1.4 Why Spring Data JPA is a wrapper, not a replacement for Hibernate?

- Spring Data JPA is not a replacement—it’s a convenience layer. It generates repositories, query methods, and reduces
  boilerplate, but internally it still relies on Hibernate (or another JPA provider). Think of it as a productivity
  wrapper, not a new ORM engine.

## 1.5 What are the costs of ORM abstraction?

- ORM hides SQL, but abstraction comes at a cost: performance overhead, unexpected queries (N+1 problem), difficulty in
  fine-tuning, and loss of control over execution plans. In banking, these costs can translate into slow transaction
  processing or missed SLAs.

## 1.6 When should you avoid ORM and use native SQL in banking?

- Use native SQL when performance, precision, or compliance is critical—like reconciliation jobs, reporting, or batch
  salary credits. ORM is great for CRUD, but for complex joins, aggregations, or high-volume operations, native SQL
  ensures predictability and efficiency.

# 2. Entity Mapping Basics

## 2.1 Difference between @Entity, @Table, and @MappedSuperclass.

- @Entity: Marks a class as a persistent entity.
- @Table: Specifies the actual DB table name.
- @MappedSuperclass: Provides reusable mappings (like audit fields) but isn’t a table itself.

## 2.2 How does Hibernate map Java objects to relational tables?

- Hibernate uses metadata (annotations/XML) to map class fields to table columns. It translates object graphs into SQL
  INSERT/UPDATE/DELETE statements and reconstructs objects from result sets.

## 2.3 What is a primary key and why is it critical in banking entities?

- Primary keys uniquely identify rows. In banking, they prevent duplicate accounts or transactions. Without a reliable
  PK, reconciliation and audit trails break down, risking financial integrity.

## 2.4 Difference between @Id, @EmbeddedId, and @IdClass.

- @Id: Single-column primary key.
- @EmbeddedId: Composite key using an embeddable object.
- @IdClass: Composite key using a separate class.
- In banking, composite keys are common for transaction IDs + account IDs.

## 2.5 Why UUID vs sequence-based IDs – which is safer in distributed banking?

- UUIDs are safer in distributed systems since they avoid collisions across nodes. Sequences are faster and smaller but
  require central coordination. In banking microservices, UUIDs often win for scalability, though sequences are better
  for
  ordered reporting.

## 2.6 How do you map legacy banking tables to entities?

- Legacy banking tables may lack proper PKs or normalization. Hibernate allows mapping with @IdClass, custom column
  names, and even views. Sometimes you need DTOs instead of entities to avoid breaking legacy constraints.

# 3. Entity Lifecycle & Persistence Context

## 3.1 What are entity states (Transient, Persistent, Detached, Removed)?

- Transient: Not yet persisted.
- Persistent: Managed by Hibernate.
- Detached: Exists but not tracked.
- Removed: Scheduled for deletion.

## 3.2 What is Persistence Context and why does it matter?

- It’s Hibernate’s first-level cache. It ensures that within a transaction, the same entity instance is reused, avoiding
  duplicate queries and ensuring consistency.

## 3.3 How does Hibernate ensure first-level cache consistency?

- Hibernate tracks entities in the persistence context. Any change is auto-detected (dirty checking) and synchronized
  with the DB at flush/commit.

## 3.4 What happens when you modify a managed entity without calling save()?

- If you change a managed entity, Hibernate auto-detects and updates it at flush—no need to call save(). This is
  convenient but can cause unintended updates.

## 3.5 What is dirty checking and why can it cause unexpected updates?

- Dirty checking compares snapshots and updates changed fields. If you unintentionally modify an entity, Hibernate may
  issue unexpected SQL, leading to performance or data integrity issues.

## 3.6 How does entity detachment affect transaction safety?

- Detached entities aren’t tracked. Updates on them won’t persist unless re-attached. In banking, this can cause missed
  updates or stale balances if developers assume they’re still managed.

# 4. Transactions & Consistency

## 4.1 How does Hibernate integrate with Spring transactions?

- Hibernate integrates with Spring via @Transactional. Spring manages transaction boundaries, while Hibernate ensures
  entity changes are flushed at commit.

## 4.2 What happens if a transaction rolls back after entity changes?

- If rollback occurs, all changes in persistence context are discarded. This prevents partial updates—critical in
  banking to avoid half-completed transfers.

## 4.3 Difference between @Transactional at service vs repository layer.

- put @Transactional at service layer. Repository methods are too granular; services define business boundaries like
  “transfer funds.”

## 4.4 Why should transaction boundaries not be placed at controller level?

- Controllers should remain stateless. Transactions at controller level risk long-lived sessions, lazy loading issues,
  and poor scalability.

## 4.5 How does isolation level affect Hibernate behavior?

- Isolation defines how concurrent transactions interact. For example, READ_COMMITTED avoids dirty reads, while
  SERIALIZABLE ensures strict consistency but reduces throughput. Banking often requires stricter isolation.

## 4.6 Can Hibernate manage transactions across microservices? Why not?

- Hibernate cannot manage distributed transactions across microservices. Each service owns its DB. For cross-service
  consistency, you need Saga or 2PC patterns, not ORM.

# 5. Fetching Strategies & Performance

## 5.1 Difference between EAGER and LAZY fetching.

### Question : A new backend developer joined the team and changed almost all @OneToMany and @ManyToOne relationships from FetchType.LAZY to FetchType.EAGER because “it’s more convenient and avoids LazyInitializationException”. The team lead immediately rejected the PR. Why was this change considered dangerous?

#### EAGER :

- EAGER tells Hibernate to load the association immediately, whether you need it or not. Every time Customer is fetched,
  all Accounts (and possibly their Transactions) are loaded. Developers assume only the parent entity is queried, but
  Hibernate silently executes additional SQL. This becomes deadly when relationships are deep or collections are
  large. EAGER can cause unnecessary joins and memory usage.
- EAGER fetching almost always leads to:
- loading 5–10× more data than needed
- Cartesian product / multiple bag fetching problems
- Unexpected SELECT N+1 even on single-entity findById()
- Much higher memory usage and GC pressure
- Slower response times
- Harder-to-predict query performance
- EAGER should be used only when the association is small, mandatory, and always required (very rare in banking domain).

#### LAZY :

- LAZY avoids this by loading data on demand, keeping initial queries lightweight. LAZY is like giving only what’s
  requested, keeping performance efficient. LAZY avoids over-fetching and keeps queries lean.
- Almost everything should be LAZY by default, and you explicitly control fetching only where needed (EntityGraph, JOIN
  FETCH, projections).
- In real systems, EAGER breaks the principle of pay only for what you use. Defaulting to LAZY gives you control instead
  of surprises. EAGER looks convenient but removes query predictability. In banking, unpredictability equals risk.

## 5.2 Why EAGER fetching is dangerous in banking apps?

### During a production incident review, the team discovered that a simple endpoint /api/accounts/{id} was consuming 1.2 GB heap and taking 7–12 seconds under moderate load — even though it was supposed to return only basic account info. The developer used EAGER fetching everywhere “to make development easier”. Why is this especially dangerous in banking applications?

- Banking systems usually deal with very large object graphs (Customer → Accounts → Transactions → Cards →
  Beneficiaries → KYC docs → Audit logs → …)
- high-concurrency environments (thousands RPS during salary day / festive season)
- strict latency SLAs (< 200–300 ms for most reads)
- EAGER fetching creates unbounded data loads.
- In banking, entities like Account can have thousands or millions of transactions.
- EAGER blindly loads everything into memory, even if the API only needs account balance.
- This leads to memory pressure, GC thrashing, and eventually crashes. Worse, EAGER cascades — one EAGER relationship
  triggers another.
- Under load, DB connections stay open longer, thread pools saturate, and latency spikes across services.
- This violates SLAs and can block critical operations like payments.
- Banking systems require deterministic performance, and EAGER is inherently non-deterministic.
- That’s why seasoned teams ban EAGER in code reviews. Convenience today becomes an incident tomorrow.
- Conclusion: in banking EAGER is considered harmful by default — explicit fetching control is mandatory.

## 5.3 What is N+1 query problem and how does it occur?

### A performance test showed that calling customerRepository.findByPan(pan) (which returns one customer) generates 101 SQL SELECT statements instead of 1–3. The team is confused: “We only fetched one customer — why so many queries?” What happened?

- Imagine a dashboard showing 100 customer accounts and their transactions.
- Hibernate first runs 1 query to fetch all accounts. (Select * from Account ).
- For each account, it runs N queries to fetch transactions. That’s 101 queries instead of 1 optimized join. (Account
  has Transactions so When Account is fetched associated Transactions also fetched). This is called the N+1 problem.
- It happens when associations are lazily loaded without optimization.
- In banking, this can cripple performance when showing transaction history.
- Each account triggers multiple DB hits, slowing down response.
- It wastes DB resources and increases latency.
- The solution is to prefetch associations using JOIN FETCH or EntityGraph.
- Always monitor queries to detect N+1 issues early.

## 5.4 How do @EntityGraph and JOIN FETCH solve N+1?

### The team wants to fix the N+1 issue on the endpoint that returns 20–80 customers with their primary KYC document and main account number, but they don’t want to load full Account and Kyc entities. Two suggestions appeared: @EntityGraph and JOIN FETCH. What’s the difference and when to prefer each?

- Suppose you need to display accounts with their transactions in one screen.
- Instead of fetching accounts first and then transactions separately, you use JOIN FETCH.
- Hibernate generates a single SQL join to fetch both in one query.
- JOIN FETCH modifies the query to fetch associations in a single SQL join, eliminating per-row queries.
- It’s explicit and powerful but can produce large result sets if overused.
- JOIN FETCH is sharper — use it when you fully control the query shape.

- Alternatively, @EntityGraph lets you declaratively specify which associations to load.
- @EntityGraph is cleaner — it defines fetch plans outside the entity, giving per-query control.
- This annotation defines a "fetch plan," specifying that the transactions association should be loaded eagerly for this
  specific query.
- Your entities remain configured with LAZY fetching by default, preserving overall performance, while this particular
  operation is optimized. Hibernate then generates the appropriate SQL join behind the scenes, based on your graph
  definition.
- EntityGraphs are safer for evolving systems.
- They ensure predictable SQL and efficient data retrieval.
- This is critical for high-volume banking systems.

- This avoids N+1 queries and reduces DB round-trips.
- In banking, this ensures dashboards load quickly.
- It also prevents hidden performance bottlenecks.

- JOIN FETCH is explicit in JPQL, while EntityGraph is annotation-driven.
- Both give developers control over fetch plans.
- You fix performance locally, not globally.

## 5.5 When should you use projections instead of entities?

### You’re building a dashboard showing account number, and balance. The API is read-only and hit thousands of times per minute. Why would using entities be a bad idea?

- Imagine a report showing only account numbers and balances for 1 million accounts.

- Entities are stateful and heavy. Entities are designed for domain logic, not high-volume reads.
- They bring persistence context overhead, dirty checking, proxies, and relationships you don’t need.
- If you fetch full entities, Hibernate loads all fields, associations, and lifecycle overhead.
- That’s wasteful when you only need two columns.
- For read-only use cases, this is pure waste.

- Projections fetch only required columns, reducing memory, CPU, and DB I/O.
- Projections (DTOs or interfaces) fetch only required fields.
- They also avoid accidental LAZY loading during serialization.
- This reduces memory usage and speeds up queries.
-
- In banking, projections are ideal for reporting, dashboards, and analytics.
- Entities are better for transactional updates where full state is needed.
- Projections avoid lazy-loading traps.
- They also prevent exposing sensitive fields unintentionally.
- Using projections improves read performance significantly.
- Always choose projections for read-heavy queries.
- If you don’t plan to update entity, don’t load an entity.

## 5.6 How do you fetch large datasets without killing memory?

### A regulatory report requires exporting 10 million transactions. A naive JPA query crashes the service. How do you fetch large datasets safely?

### Compliance team needs to export 1.2 million transaction records (last 24 months) for a regulatory audit. When the developer tried transactionRepository.findAll() the JVM ran out of memory after ~180k records. How can we safely fetch huge datasets?

- Suppose you’re running a reconciliation job to process 10 million transactions.
- Loading all into memory will crash the JVM. Fetching everything at once is amateur hour. You must stream or paginate.
- Instead, use pagination to fetch chunks (e.g., 1000 at a time). Use pagination with reasonable page sizes to control
  memory.
- For very large exports, use Hibernate ScrollableResults or Spring Data streaming queries Or use streaming with
  Hibernate’s scrollable results.Disable second-level cache and avoid entity graphs.
- Flush and clear persistence context regularly to free memory. Prefer projections or JDBC for bulk reads. Flush and
  clear the persistence context periodically to prevent memory leaks.
- Avoid EAGER fetching—fetch only required columns.
- Use batch size tuning to reduce DB round-trips.
- In banking, long-running jobs must be back-pressure aware. One job should never starve the system. If the dataset is
  massive, JPA might not even be the right tool — sometimes plain JDBC wins or Native SQL may be better for massive
  datasets. Stability beats elegance.
- Always monitor memory and DB load during batch jobs.
- The goal is to process safely without killing performance.

# 6. Associations & Relationships

## 6.1 One-to-One, One-to-Many, Many-to-One, Many-to-Many – banking examples.

### You’re modeling a banking system with Customer, Account, Transaction, and Branch. Wrong relationship choices cause duplicate rows, wrong joins, and broken reports. How do you map relationships correctly?

- One-to-One: Account ↔ AccountKYC (one account, one KYC record). Rare, use sparingly.
- One-to-Many: Account → Transactions (one account, many transactions).
- Many-to-One: Transaction → Account (many transactions belong to one account). This is the most common mapping in
  banking.
- Many-to-Many: Customer ↔ Account (joint accounts). Dangerous if modeled naively.

#### Imagine modeling relationships in a banking system:

- These mappings reflect real-world banking structures. Choosing the right relationship ensures data integrity. For
  example, transactions must always point to a single account (many-to-one). Misusing these mappings can cause
  duplication or missing links. Correct modeling is critical for compliance and reporting.
- Banking data is asymmetric — most relationships point towards Account. Overusing One-to-One or Many-to-Many leads to
  schema rigidity and performance issues. Many-to-One scales best and keeps queries predictable. If you start with
  Many-to-Many everywhere, you’re designing for confusion, not scale.

## 6.2 Owning side vs inverse side – why it matters?

### You save a Customer with associated Accounts. No exception is thrown, but the join column remains null in DB. What went wrong?

- You updated the inverse side, not the owning side.
- JPA only persists relationships from the owning side — the side with the foreign key.
- The inverse side (mappedBy) is ignored for SQL generation.
- Developers assume updating both sides is optional — it’s not.
- If the owning side isn’t set, the DB won’t reflect the relationship.
- In banking systems, this silently causes data inconsistency.
- Owning side decides truth, inverse side is just a mirror.
- If you don’t know which side owns the relationship, you don’t control persistence. That’s a dangerous blind spot.

- Suppose you model a customer and their accounts.
- The owning side controls the foreign key (e.g., Account has customer_id).
- The inverse side is just a mirror for navigation (Customer has accounts).
- If you misunderstand this, Hibernate may not persist relationships correctly.
- For example, adding an account to a customer but not setting the owning side means the DB won’t update.
- In banking, this can cause orphaned accounts without proper linkage. Always ensure the owning side is updated to
  maintain referential integrity.

## 6.3 Why bidirectional mappings are dangerous if misused?

### A REST API returning Customer data suddenly crashes during JSON serialization. Logs show infinite recursion between entities. Why?

- This is bidirectional mapping abuse.
- Customer → Account → Customer → Account creates an endless object graph.
- Serialization frameworks walk both directions and never stop.
- Even if serialization is fixed, bidirectional mappings encourage accidental LAZY loading.
- One toString() or log statement can trigger dozens of DB queries.
- In banking apps, this can expose sensitive linked data unintentionally.
- Bidirectional mappings should exist only when navigation is truly needed both ways.
- Otherwise, keep mappings unidirectional. Convenience today becomes production chaos tomorrow.

- Imagine a REST API that returns customer and account details.
- If you use bidirectional mapping (Customer ↔ Account), serialization may cause infinite loops.
- For example, Customer → Accounts → Customer → Accounts endlessly.
- This can crash APIs or expose sensitive data.
- In banking, leaking transaction details unintentionally is a compliance risk. Bidirectional mappings also complicate
  cascade operations. If misused, deleting a customer could cascade into
  deleting accounts. Best practice: use unidirectional mappings unless bidirectional is truly required.

## 6.4 Cascade types – when NOT to use CascadeType.ALL.

### A developer deletes a Customer entity. Suddenly, accounts and transactions vanish from the database. Root cause?

- CascadeType.ALL was used blindly. Cascade ALL includes REMOVE, which propagates deletes.
- In banking, entities like Transaction, AuditLog, and LedgerEntry must be immutable.
- Cascading delete violates regulatory and audit requirements. Cascades are safe for aggregate boundaries, not for
  financial records.
- Use PERSIST and MERGE selectively. Never cascade REMOVE across core financial entities.
- If delete propagation surprises you, your domain boundaries are wrong. Cascade is a sharp knife — not a default
  setting.

#### Suppose you delete a customer entity.

- With CascadeType.ALL, Hibernate may also delete all linked accounts and transactions.
- In banking, this is catastrophic—transactions must never be deleted.
- Cascade should be used selectively: PERSIST for saving linked entities, MERGE for updates. Avoid cascading deletes on
  critical entities.
- Otherwise, you risk losing audit trails and financial records. Always think carefully before applying cascade in
  banking systems.

## 6.5 Orphan removal – what problem does it solve?

### You removed a beneficiary from an account (e.g., account.getBeneficiaries().remove(beneficiary) or you set beneficiary.setAccount(null)), saved/committed the changes, but the row in the beneficiaries table still exists in the database — often with the foreign key (account_id) either null or still pointing to the old account (creating a dangling reference). You remove a beneficiary from an account, but the DB row still exists with a dangling foreign key. Why, and how do you fix it?

### You remove a credit card / beneficiaries from an account, but the DB row still exists with a dangling foreign key. Why, and how do you fix it?

- This is exactly what orphan removal solves.

- Without it, removing a child from a collection only breaks the in-memory relationship — not the DB row.
- Orphan removal ensures that when a child is no longer referenced by its parent, it’s deleted automatically.
- In banking, this is useful for dependent entities like nominees, linked devices, or temporary limits.
- It prevents data rot and orphaned records. However, orphan removal implies ownership — the child cannot exist
  independently.
- If that assumption is wrong, you’ll delete valid data. Use it only when lifecycle dependency is absolute.

- Imagine a customer closes a credit card linked to their account.
- Without orphan removal, the card record remains in DB, even though it’s no longer linked.
- This creates “orphaned” records that clutter data.
- With orphan removal, Hibernate deletes the child when removed from parent.
- In banking, this ensures clean data—closed cards or inactive beneficiaries don’t remain dangling. It improves
  consistency and prevents confusion during audits. However, orphan removal should not be used for transactional
  records, which must remain for compliance.

## 6.6 How do you model joint accounts safely?

### A joint account can have multiple holders, each with different permissions (operate, view-only, nominee). How do you model this safely?

#### Consider two customers sharing a joint savings account.

- This is a Many-to-Many relationship: multiple customers ↔ multiple accounts.
- You model it with a join table (e.g., customer_account).
- Each entry links a customer to an account with roles (primary holder, secondary holder).This ensures proper ownership
  and access control.
- In banking, joint accounts must enforce rules like “both signatures required” or “either holder can transact.”
- Modeling with Many-to-Many plus role attributes ensures safety. It prevents unauthorized access and maintains
  compliance.

- Never use a raw @ManyToMany between Customer and Account. That design cannot store metadata like role, limits, or
  authorization level.
- Instead, introduce a join entity like AccountHolder. Customer → AccountHolder ← Account
- This converts Many-to-Many into two Many-to-One relationships, which are easier to control.
- You can now store holder type, signing authority, and validity dates. This model enforces auditability and
  extensibility — both mandatory in banking. Many-to-Many hides business rules; join entities expose them.
- If your joint account design doesn’t support future compliance rules, it’s already broken.

# 7. Spring Data JPA Repositories

## 7.1 What problem do JPA repositories solve?

### Your banking service has 50 entities. Without repositories, every DAO repeats EntityManager, transactions, exception handling, and CRUD logic. What problem do JPA repositories actually solve?

- Imagine you’re building a banking system with dozens of entities: Customer, Account, Transaction, Loan.
- Traditionally, you’d write DAOs with boilerplate CRUD methods. JPA repositories eliminate this repetitive code.
- They provide ready-made methods like save(), findById(), delete(). They standardize CRUD, pagination, sorting, and
  transaction participation without handwritten DAOs. This speeds up development and reduces human error.
- In banking, where reliability is critical, fewer lines of custom DAO code means fewer bugs.
- Repositories also integrate seamlessly with Spring transactions, auditing, and security.
- They allow developers to focus on business logic (like fund transfers) instead of plumbing.
- Query derivation and pagination come built-in. They reduce boilerplate but don’t remove responsibility — bad queries
  are still bad queries.
- This abstraction makes banking apps more maintainable.
- Repositories are a productivity layer, not a performance guarantee.
- If you think repositories “optimize” your queries automatically, you’re fooling yourself. They solve repetition, not
  bad design.

## 7.2 Difference between CrudRepository, JpaRepository, PagingAndSortingRepository.

### A service starts with CrudRepository. Later, you need pagination, batch operations, and flush control. What’s the real difference between repository types?

### A junior developer extends JpaRepository everywhere by default. Under load, memory and performance degrade. Why does repository choice matter?

- CrudRepository: Bare minimum CRUD. No pagination, no flushing control. Good for tiny services only.
- PagingAndSortingRepository: Adds pagination and sorting. Still limited.
- JpaRepository: Full power — batch operations, flush(), saveAll(), pagination, sorting.

- In real banking apps, JpaRepository is the default choice because requirements always grow.
- Starting with CrudRepository is false minimalism. Migrating later touches many interfaces and tests.
- JpaRepository gives you escape hatches when performance tuning becomes necessary.
- Choosing a weaker interface rarely saves you anything long-term.
- JpaRepository brings more power with more cost.
- In read-heavy banking systems, not every repository needs full JPA features.
- Choosing the largest interface by default is lazy design. Use the least powerful abstraction that meets the need.
- JpaRepository is better for accounts and transactions where batch updates matter.
- PagingAndSortingRepository is ideal for transaction history queries.

## 7.3 How does Spring generate query methods from method names?

### You write findByAccountNumberAndStatusAndCreatedDateBetween() and it just works. How does Spring pull this off?

- Spring Data parses method names using a domain-specific grammar.
- It splits the method into property names and operators, validates them against entity metadata, and generates JPQL at
  startup.
- Property names map to entity fields, keywords map to operators (And, Or, Between, In, etc.). At runtime, this JPQL
  becomes SQL via Hibernate.
- Keywords like And, Or, Between, In, Like map to query fragments. This happens once, not at runtime per call.
- It’s powerful, but brittle. Rename a field and your query breaks silently at startup. Complex conditions quickly
  become unreadable.

- Imagine you need to fetch all active accounts for a customer.
- Instead of writing SQL, you define findByCustomerIdAndStatus(Long id, String status).
- Spring parses the method name and generates the query.
- This saves time and reduces errors.
- In banking, it’s useful for common queries like findByAccountNumber or findByTransactionDateBetween.
- It enforces consistency across the codebase.
- Developers don’t need to manually write repetitive queries.
- It’s declarative and readable.
- However, it should be used for simple queries only.
- Complex queries should use @Query or Criteria API.
- This balance keeps banking apps efficient and maintainable.

## 7.4 Why long derived queries are a code smell?

### Your repository contains methods like 'findByCustomerIdAndAccountTypeAndStatusAndBranchCodeAndCreatedDateAfterAndBalanceGreaterThan' It works. Why is this a problem?

- Long derived queries hide business logic inside method names.
- They are hard to modify, hard to review, and easy to break during refactoring. One field rename can silently change
  behavior. They also discourage reuse — every new variation becomes a new method.
- Adding one more condition explodes the method name.
- In banking, query logic changes frequently due to regulations.
- Long derived queries increase change risk and regression probability.
- These method names lock logic into signatures instead of queries. If your method name reads like a sentence, you’re
  abusing the feature.
- Long derived queries are brittle and error-prone.
- They reduce clarity for new developers.
- Better approach: use @Query or Specifications.
- Keep repository methods short and meaningful.
- Complex logic belongs in the service layer.
    - This separation ensures clean architecture in banking apps.

## 7.5 When should you use @Query instead?

### A report query keeps evolving: joins added, conditions optional, performance tuning needed. Derived query methods are becoming unreadable. What should you do?

#### Imagine you need to fetch all accounts with transactions above a threshold in the last 30 days.

- This is when you switch to @Query.
- Derived queries can’t handle this complexity. Derived queries are for simple lookups, not core logic.
- Use @Query with JPQL or native SQL. It allows joins, fetch strategies, subqueries, and DB-specific optimizations.
- It gives explicit control over joins and conditions.
- In banking, this is critical for compliance reports.
- @Query ensures readability and maintainability.
- It avoids overly long method names.
- Native queries can leverage DB-specific optimizations.
- JPQL keeps queries portable across databases.
- Developers must choose based on performance needs.
- @Query is the right tool for complex banking queries.

## 7.6 How do projections improve read performance?

### A read-only API is hit thousands of times per minute. It only returns a few fields, yet CPU and memory usage are high. Why, and how do projections help?

- Projections fetch only required columns, not entire entities. This reduces object creation, memory usage, and GC
  overhead.
- They also avoid persistence context tracking and lazy-loading traps. In read-heavy systems like banking dashboards,
  projections turn JPA into a read-optimized tool.
- They also protect APIs from entity changes — adding a new field doesn’t impact projection queries. Projections align
  with CQRS-style read models.
- If your API is read-only, and you’re still returning entities, you’re paying for features you don’t use. That’s wasted
  performance.

- Suppose you’re generating a report of account balances for regulators.
- You only need account number and balance, not full entity details.
- Fetching full entities loads unnecessary fields and associations.
- Projections fetch only required columns.
- This reduces memory usage and speeds up queries.
- In banking, projections are ideal for dashboards, reports, and analytics.
- They prevent lazy-loading traps.
- They also avoid exposing sensitive fields unintentionally.
- DTO projections give strong control over data returned.
- Interface projections are lightweight and flexible.
- Using projections improves read performance significantly in large-scale banking systems.

# 8. Querying Techniques

## 8.1 JPQL vs native SQL – tradeoffs in banking.

### A regulatory report query with multiple joins and aggregations runs fine in SQL but performs poorly when rewritten in JPQL. Should you stick to JPQL or switch to native SQL?

- JPQL lets you query entities in an object-oriented way, portable across databases.
- JPQL operates on entities, not tables, which limits advanced SQL features like window functions, hints, and
  vendor-specific optimizations.
- It’s great for CRUD operations like fetching accounts or transactions. But JPQL hides SQL details, limiting
  fine-tuning.
- JPQL is safer for portability, but slower for complex queries.
- Native SQL gives full control over joins, indexes, and DB-specific optimizations. lets you tune indexes, hints, and
  execution plans directly.
- In banking, reconciliation jobs or regulatory reports often need native SQL.
- Native SQL can leverage DB features like partitioning or window functions.
- Tradeoff: JPQL = simplicity, Native SQL = performance.
- Best practice: use JPQL for day-to-day operations, transactional workflows, Performance-critical banking queries
  deserve native SQL , native SQL for heavy reporting, analytics and batch jobs.
- This balance ensures both maintainability and efficiency.

## 8.2 Criteria API – when is it useful?

### A search screen allows filtering by account number, customer ID, date range, amount range, and status — all optional. Hardcoding queries explodes combinatorially. Where does Criteria API fit?

- Criteria API exists for dynamic query construction, not developer happiness.
- Many teams prefer Specifications or QueryDSL for readability. Criteria API is a tool of necessity, not elegance.
- If your query logic is dynamic by nature, Criteria is acceptable pain.

- Suppose you’re building a search screen for transactions.
- Customers may filter by date, amount, account type, or status.
- Writing static JPQL queries for every combination is impractical.
- Criteria API allows building queries dynamically at runtime. This is useful when filters are optional and
  combinatorial.
- It’s type-safe and avoids string concatenation.
- In banking, this is useful for flexible search portals.
- It ensures queries adapt to user input without rewriting code.
- Criteria API integrates well with Specifications in Spring Data.
- It reduces risk of SQL injection since parameters are bound safely.
- However, Criteria API is verbose and hard to read. , it’s powerful for dynamic queries.
- Ideal for advanced search features in banking apps.

## 8.3 How do you implement dynamic search filters?

### Users want Google-like filtering on transactions: date ranges, amount thresholds, text search, multiple statuses. How do you implement this cleanly?

- You don’t use derived query methods — that’s a dead end. Use Specifications, Criteria API, or QueryDSL.
- Specifications allow composable predicates that can be combined dynamically. This keeps each filter small, testable,
  and reusable.
- For banking systems, this avoids massive conditional logic and keeps queries predictable.
- Native SQL with dynamic fragments is risky and harder to secure. The key is separating filter intent from query
  execution.
- Dynamic search is about composition, not conditionals. If your repository method has 10 parameters, your design is
  already broken.

- Imagine a customer wants to filter transactions by multiple optional fields.
- You can’t predict which filters they’ll use.
- Implement dynamic filters using Criteria API or Spring Data Specifications.
- Build predicates conditionally based on user input.
- Example: if amount is provided, add amount > ?; if date is provided, add date BETWEEN ?.
- This avoids writing dozens of static queries.
- In banking, this supports flexible reporting dashboards.
- It ensures queries remain efficient and secure.
- Dynamic filters improve user experience by allowing custom searches.
- They also reduce code duplication and complexity.

## 8.4 Pagination vs streaming – which suits transaction history?

### A customer views transaction history spanning years. Should you paginate results or stream them?

- Pagination is for interactive user flows. Streaming is for batch processing.
- For transaction history UI, pagination is mandatory — users don’t need everything at once.
- Streaming holds DB connections open and is dangerous under concurrent load.
- In banking, open cursors under load can starve the connection pool.
- Streaming is suitable for exports, reconciliation jobs, or regulatory reports.
- Pagination provides back-pressure and predictable memory usage.
- If someone suggests streaming for UI APIs, they’re ignoring operational reality. Choose based on access pattern, not
  elegance.

- Suppose a customer requests their last 10 years of transactions.
- Loading all at once will overwhelm memory and slow response.
- Pagination fetches data page by page (e.g., 50 records per page).
- This suits customer-facing transaction history screens.
- Streaming fetches records sequentially, useful for backend batch jobs.
- In banking, pagination is for UI, streaming is for reconciliation or audits.
- Pagination improves responsiveness and user experience.
- Streaming ensures large datasets can be processed safely.
- Both prevent memory overload and DB strain.
- Choosing depends on whether the use case is interactive or batch.

## 8.5 How do you optimize count queries?

### A paginated API runs two queries: one for data, one for count. The count query is slow on large transaction tables. How do you fix this?

- Count queries are often more expensive than data queries.
- First, avoid unnecessary counts — users don’t always need total pages.
- Second, use simplified count queries that skip joins. Spring Data allows custom count queries for this reason.
- Third, cache counts for static datasets. In extreme cases, approximate counts are acceptable for UI.
- In banking, correctness matters — but not always exact pagination numbers. Blindly accepting default count queries is
  lazy.
- Every count query must be reviewed like a production query, not a helper.

- Imagine generating a report of total transactions per branch.
- A naive SELECT COUNT(*) on millions of rows is slow.
- Optimize by counting indexed columns instead of full rows.
- Use approximate counts for dashboards where exact precision isn’t critical.
- In banking, regulators may require exact counts—then indexes are essential.
- Partitioning tables by date can speed up counts.
- Materialized views can pre-compute totals for faster queries.
- Avoid counting on unindexed large tables.
- Always analyze execution plans to detect bottlenecks.
- Optimized counts reduce DB load significantly.
- This ensures reports run within SLA and compliance deadlines.

## 8.6 How do you prevent SQL injection with JPA?

### Your system handles financial data and is a prime attack target. How do you ensure SQL injection is impossible with JPA?

- JPA prevents SQL injection only if used correctly. Parameter binding (:param) ensures values are not treated as
  executable SQL.
- JPQL and Criteria API are safe by default. Injection risk appears when developers concatenate strings in native
  queries.
- Even then, bind parameters instead of appending input. Never build SQL from raw user input.
- In banking, native queries must be code-reviewed aggressively.
- Security doesn’t come from the framework — it comes from discipline.
- JPA reduces risk, but it doesn’t eliminate stupidity.

- Suppose a customer searches transactions by description.
- If you concatenate input directly into JPQL, attackers can inject SQL.
- Example: description = 'abc' OR 1=1.
- JPA prevents this with parameter binding (:param).
- Criteria API also binds parameters safely.
- In banking, SQL injection could expose sensitive data or alter balances.
- Always avoid string concatenation in queries.
- Use prepared statements or JPA’s binding mechanisms.
- Validate user input before passing to queries.
- Security is non-negotiable in banking apps.
- Proper binding ensures compliance and safety.

# 9. Locking & Concurrency Control

## 9.1 Why is concurrency control critical in banking?

### Your transfer logic is correct, validations pass, and DB transactions are used. Still, reconciliation reports show balance mismatches. Why is concurrency control critical in banking?

- Banking systems are stateful and concurrent by nature. Thousands of transactions hit the same accounts simultaneously.
- Without proper concurrency control, race conditions occur: two threads read the same balance, both deduct money, and
  both write back stale results. The system doesn’t crash — it silently corrupts data. That’s the worst failure mode.
- Banking requires serializable effects, even under parallel execution. ACID alone isn’t enough; isolation and locking
  strategy matter.
- Money must never be “eventually consistent” inside a ledger. If concurrency is mishandled, trust is broken, audits
  fail, and regulators get involved. This is not a performance concern — it’s a correctness mandate.

- Imagine two customers transferring money from the same account at the same time.
- Without concurrency control, both transfers might read the same balance.
- Each transaction could debit funds independently, leading to overdrafts.
- Banking systems must ensure balances are consistent and accurate.
- Concurrency control prevents race conditions and lost updates.
- It ensures atomicity—only one transaction succeeds at a time.
- This protects customer trust and regulatory compliance.
- Without it, double debits or phantom credits could occur.
- Concurrency control is the backbone of financial integrity.
- It ensures every transaction reflects the true state of the account.
- In short: concurrency control prevents financial chaos.

## 9.2 Optimistic vs pessimistic locking – differences.

### You must protect account balance updates. One approach blocks users, another occasionally fails transactions. What’s the real difference between optimistic and pessimistic locking?

#### Suppose multiple transfers hit the same account.

- Optimistic locking assumes conflicts are rare.
- It uses a version field to detect changes at commit time.
- It allows concurrent reads and detects conflicts only at update time.
- If another transaction updated the row, one fails with an error.
- Optimistic locking improves throughput but shifts conflict handling to the application layer.

- Pessimistic locking assumes conflicts are common.
- It locks the row immediately, preventing others from updating.
- Optimistic is lightweight, good for low contention.
- Pessimistic is heavier, but safer under high contention.

- In banking, read-heavy flows like reporting favor optimistic locking, while balance updates and fund transfers often
  require pessimistic control.
- The mistake is treating this as a technical choice — it’s a business concurrency model.
- Choose wrong and either performance collapses or data becomes inconsistent. There is no universally correct choice.

## 9.3 How does @Version prevent lost updates?

### Two requests read the same account balance and both update it successfully. No exception, no rollback. How does @Version stop this?

- @Version adds a version column to the entity. Every update includes the version in the WHERE clause.
- If another transaction updates the row first, the version changes and the second update affects zero rows.
- Hibernate detects this and throws an OptimisticLockException. This converts silent data corruption into a visible
  failure.
- The application can retry or reject the operation. @Version doesn’t prevent concurrency — it detects conflicts
  deterministically.
- In banking, failing fast is better than being wrong silently. If you update money without a version column, you’re
  gambling.

- Imagine two members updating the same account balance.
- Hibernate adds a version column to the entity.
- Each update checks the version before committing.
- If another update occurred, the version mismatch triggers an error.
- This prevents overwriting someone else’s changes.
- In banking, it stops double debits or missed credits.
- @Version ensures updates are atomic and consistent.
- It’s a simple but powerful safeguard.
- Without it, concurrent updates silently overwrite each other.
- With it, conflicts are detected and handled safely.
- This is critical for transactional integrity.

## 9.4 When should you use PESSIMISTIC_WRITE?

### During peak hours, two transfers hit the same account simultaneously. Optimistic locking causes frequent retries. When should you use PESSIMISTIC_WRITE?

- Use PESSIMISTIC_WRITE when contention is high and correctness is non-negotiable.
- It locks the row at read time, blocking other writers until the transaction completes. This is suitable for balance
  updates, ledger entries, or limit enforcement. The cost is reduced concurrency and potential wait times.
- In banking, blocking is acceptable — inconsistency is not. However, pessimistic locks must be short-lived. Holding
  locks across network calls or remote services is a design failure. Use them only around critical sections. If you lock
  wide and long, your system will deadlock itself.

- Suppose multiple salary credits hit the same account simultaneously.
- Optimistic locking may cause too many retries.
- PESSIMISTIC_WRITE locks the row immediately.
- Other transactions must wait until the lock is released.
- This ensures only one update happens at a time.
- In banking, use it for high-value transfers or high contention accounts.
- It prevents race conditions and ensures correctness.
- But it reduces throughput due to waiting.
- Use it sparingly, only when conflicts are guaranteed.
- It’s a tradeoff between safety and performance.
- Critical for scenarios like fund transfers or loan disbursements.

## 9.5 How does Hibernate behave under high contention?

### At peak hours, response times spike, threads block, and DB CPU rises. Hibernate logs show lock waits. What’s happening under high contention?

- Under contention, Hibernate delegates locking behavior to the database.
- Threads block waiting for row locks. Connection pools get exhausted because blocked transactions still hold
  connections.
- This creates back-pressure amplification — slow DB causes slow app, which causes more retries, which causes more DB
  load.
- Hibernate itself isn’t smart here; it doesn’t resolve contention, it exposes it.
- Poor transaction boundaries make it worse. In banking, contention is expected — systems must be designed for it.
- Short transactions, minimal locked rows, and clear isolation levels are mandatory. Hibernate won’t save a bad
  concurrency design.

- Imagine thousands of transfers hitting the same account.
- Hibernate tries to manage locks via DB.
- With optimistic locking, many transactions fail and retry.
- With pessimistic locking, many transactions wait, causing bottlenecks.
- High contention leads to deadlocks or timeouts.
- Hibernate relies on DB isolation levels to resolve conflicts.
- In banking, this can slow down transaction throughput.
- Proper retry logic and queueing are essential.
- Monitoring contention hotspots is critical.
- Hibernate alone cannot solve high contention—it needs DB tuning.
- Scalability requires careful design of concurrency strategies.

## 9.6 What happens if two transfers update same account row?

### Transfer A and Transfer B both debit the same account concurrently. Walk through what happens with and without proper locking.

- Suppose two transfers debit ₹500 from the same account with ₹1000 balance.
- Both read balance = 1000.
- Without locking, both subtract 500 → final balance = 500 (instead of 0).
- This is a lost update problem.
- With optimistic locking, one transaction fails due to version mismatch.
- With pessimistic locking, one waits until the other completes.
- Correct balance is maintained.
- In banking, this ensures no double debit occurs.
- Without concurrency control, customers lose money.
- With proper locking, transactions remain safe and consistent.

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