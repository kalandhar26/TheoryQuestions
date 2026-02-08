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

### A nightly job inserts millions of transaction rows. CPU is low, DB is fine, yet throughput is terrible. How does Hibernate actually handle batch inserts/updates?

- Imagine a payroll system crediting salaries to 50,000 employees.
- If Hibernate inserts each record individually, performance suffers.
- Batch processing groups multiple inserts/updates into a single DB round-trip.
- Hibernate can group multiple SQL statements into a single batch operation using JDBC batching.
- This reduces network overhead and speeds up execution.
- Hibernate supports batching via hibernate.jdbc.batch_size.
- It reuses prepared statements for efficiency.
- In banking, this ensures salary credits finish within SLA.
- Without batching, jobs may take hours instead of minutes.
- Batch inserts also reduce DB contention.
- Proper batching is critical for high-volume financial operations.
- Instead of sending each INSERT immediately, Hibernate buffers them. When the batch reaches the configured size (e.g.,
  20), it sends all statements in one network round-trip. This dramatically reduces network overhead and database
  parsing costs.

```text
hibernate.jdbc.batch_size – how many statements to batch together
hibernate.order_inserts=true – groups inserts by entity type for efficiency
hibernate.order_updates=true – groups updates by entity type
```

## 10.2 Why should you flush and clear persistence context in batches?

### A batch job processing millions of records crashes with Out Of Memory Error even though batch size is configured. Why do flush and clear matter?

- Suppose you’re processing millions of transactions in one job.
- Hibernate keeps all managed entities in the persistence context.
- If you don’t clear, memory usage grows until JVM crashes.
- Flush: Forces Hibernate to execute pending SQL (INSERTs/UPDATEs) to the database
- Clear: Detaches all entities from the persistence context, freeing memory
- In batch jobs, flush/clear after every chunk (e.g., 1000 records).This prevents OutOfMemoryErrors.
- Hibernate's first-level cache (the persistence context) stores every loaded or saved entity. During bulk operations,
  this grows unbounded and eventually causes OutOfMemoryError.
- In banking, it ensures reconciliation jobs run safely.
- It also avoids stale data in persistence context.
- Proper flush/clear strategy balances performance and memory.
- Without flush(), you risk losing data if the application crashes.
- Without clear(), memory keeps growing.
- Together, they create a sustainable "checkpoint" rhythm.
- Without it, batch jobs can bring down the system.
- SQL batching without context management is half a solution.

## 10.3 Bulk JPQL updates – what’s the risk?

### You run a JPQL bulk update to mark transactions as SETTLED. Later, APIs still show old status values. No errors. What went wrong?

- Bulk JPQL updates bypass the persistence context.
- Hibernate executes the SQL directly against the DB but does not update in-memory entities.
- Any managed entities now hold stale data. This causes logical inconsistency between DB state and application state.
- In banking, stale state is dangerous — decisions might be made on wrong data. After bulk updates, you must clear the
  persistence context or ensure the entities are not reused.
- Bulk updates are fast but unsafe if mixed with entity logic. Treat them like surgical operations, not normal updates.

- The Risk: Cache Inconsistency
- This executes as a single SQL UPDATE statement directly on the database. Hibernate does not know which entities
  changed.
- **Consequences:**
- Entities already in the second-level cache remain stale (old salary values)
- Entities in the current persistence context become out-of-sync with database
- Subsequent reads may return incorrect data,
- Developers must refresh or clear context after bulk updates.
- **Mitigation strategies:**
- Evict affected cache regions manually after bulk operations
- Use session.clear() before bulk updates to avoid stale entities in context
- Consider whether you truly need bulk operations, or if iterative processing is safer

## 10.4 How do bulk operations bypass Hibernate cache?

### After running a bulk operation, cached entities still return old values. How did Hibernate cache get bypassed?

- Bulk operations skip both first-level and second-level cache synchronization.
- Hibernate assumes you know what you’re doing. It does not invalidate or update cached entities automatically.
- This leads to stale reads until cache eviction occurs.
- In banking systems using second-level cache, this can cause severe inconsistencies.
- You must explicitly evict affected cache regions or avoid caching entities involved in bulk jobs.
- Cache and bulk operations are uneasy companions. If you mix them casually, you’ll ship inconsistent data to
  production.
-
- Suppose you run a bulk update to mark 1M transactions as “processed.”
- Hibernate executes SQL directly, skipping first-level cache.
- Entities already in persistence context won’t reflect changes.
- Second-level cache also isn’t updated.
- This creates stale data in memory.
- In banking, stale balances or statuses can mislead users.
- Developers must evict or refresh caches after bulk operations.
- Otherwise, queries may return outdated results.
- Bulk ops are efficient but dangerous if cache isn’t managed.
- Always clear persistence context after bulk updates.
- Cache bypass is a hidden risk in ORM abstraction.

```text
Your JPQL → SQL String → JDBC Driver → Database
     ↓              ↓
[SKIPS] Entity instantiation
[SKIPS] First-level cache checks
[SKIPS] Second-level cache checks
[SKIPS] Dirty checking
[SKIPS] Event listeners (usually)
```

## 10.5 How do you process millions of records safely?

### A regulatory requirement forces you to process 50 million records overnight. How do you do this without killing the system?

- First, question whether JPA is the right tool — sometimes it isn’t.
- If you use Hibernate, process records in chunks, paginate or stream carefully, and flush/clear aggressively.
- Use projections or DTOs instead of entities. Disable second-level cache. Avoid bidirectional mappings.
- Consider JDBC for pure data movement. Monitor memory, DB locks, and transaction duration.
- Break work into restartable chunks to handle failures. In banking, batch jobs must be idempotent and resumable.

- Imagine reconciling 10 million transactions overnight.
- Loading all into memory will crash the JVM.
- Use chunking (process 1000 records at a time).
- Use pagination or streaming for large datasets.
- Flush and clear persistence context regularly.
- Use batch inserts/updates to reduce DB round-trips.
- Consider native SQL for extreme performance.
- Use job schedulers like Spring Batch for orchestration.
- Monitor memory and DB load continuously.
- In banking, this ensures jobs finish before business hours.
- Safe processing avoids downtime and compliance issues.

# 11. Caching with Hibernate

## 11.1 First-level vs second-level cache differences.

### Within a single transaction, you load an Account entity twice by ID, but only one SQL query is executed. In another request, the same lookup hits DB again. Why?

- That’s the difference between first-level and second-level cache.
- First-level cache is the persistence context — it’s mandatory, scoped to a transaction/session, and always on.
- Hibernate guarantees identity: same entity, same object, no duplicate queries within the session.
- Second-level cache is optional, shared across sessions, and survives beyond a transaction.
- First-level cache is about correctness and identity; second-level cache is about performance.
- You cannot turn off first-level cache — and you shouldn’t want to. Second-level cache trades freshness for speed.
  Mixing the two mentally is where design mistakes begin.

- Suppose a teller queries the same customer account multiple times during a transaction.
- First-level cache is session-scoped, mandatory, and ensures repeated queries in the same transaction don’t hit the DB
  again. It lives inside the persistence context.
- Second-level cache is optional, shared across sessions, and stores entities globally. It reduces DB load for
  frequently accessed data.
- In banking, first-level cache ensures consistency within a transaction.
- Second-level cache improves performance for read-heavy operations, But second-level cache risks stale data if balances
  change frequently.
- First-level = safe for transactional consistency.
- Second-level = risky unless used for static reference data.

## 11.2 Should second-level cache be used for banking data?

### A team proposes enabling second-level cache globally to reduce DB load, including for Account entities. Should this ever be done in banking?

- No.
- Banking data is highly mutable and correctness-critical.
- Second-level cache introduces staleness windows, eviction races, and coherence complexity.
- A stale balance is not a minor bug — it’s a financial incident.
- Cache consistency under concurrent updates is hard even with strong eviction strategies.
- Performance problems should be solved with indexing, query optimization, or read/write separation — not caching
  volatile financial state.
- In banking, correctness beats latency every time. If your system needs cached balances to survive load, your
  architecture is already stressed. Second-level cache should be opt-in, not default.

- Imagine caching account balances in second-level cache.
- Customers may see outdated balances if cache isn’t refreshed.
- In banking, this is unacceptable—balances must always be real-time.
- Second-level cache is better suited for static data like branch codes.
- Using it for transactional data risks compliance violations.
- Regulators demand accurate, up-to-date financial records.
- Cache staleness could lead to double debits or missed credits.
- Second-level cache should be avoided for dynamic banking data.
- It’s safe only for non-volatile, reference-type entities.
- Always prioritize consistency over performance in banking.
- So: use second-level cache sparingly, never for balances.

## 11.3 What entities are safe to cache (reference data)?

### Entities like Currency, Country, BranchType, TransactionCode rarely change but are queried constantly. Is caching justified here?

- Yes — this is reference data, and it’s the right use case for second-level cache.
- Reference data is low-churn, small, and shared across services. Caching reduces repetitive DB hits without risking
  inconsistency. Even if stale for a short time, business impact is minimal. In banking, this includes ISO codes, charge
  types, error codes, and configuration tables. These entities are not part of transactional workflows. Cache them
  aggressively and evict on controlled updates. If you don’t cache reference data, you’re wasting DB capacity. If you
  cache transactional data, you’re risking integrity.

- Suppose your app frequently queries branch details or currency codes.
- These values rarely change. Caching them reduces DB load and improves performance.
- Safe entities include branch codes, IFSC codes, currency exchange rates, product types. They are read-heavy and
  write-light.
- In banking, caching reference data speeds up lookups. It doesn’t risk financial inconsistency.
- Audit and compliance are unaffected since data is static. This improves scalability without compromising accuracy.
  Always restrict caching to non-transactional entities.

## 11.4 How does Hibernate integrate with Redis/Ehcache?

### Your application integrates Redis as a cache provider. How does Hibernate actually use it for second-level caching?

- Hibernate doesn’t talk to Redis or Ehcache directly — it uses a cache provider abstraction.
- Entities marked as cacheable are stored via providers like Ehcache, Hazelcast, Infinispan, or Redis-backed
  implementations.
- Hibernate manages cache regions per entity and query. Reads may come from cache; writes trigger cache invalidation or
  update depending on strategy.
- This is not magic — eviction, TTLs, and consistency are your responsibility. In banking, Redis is often shared across
  services, increasing blast radius if misconfigured.
- Hibernate cache integration is powerful but dangerous without strict governance. If you don’t understand eviction
  semantics, don’t enable it.

- Imagine a banking app serving thousands of concurrent users.
- Hibernate can integrate with caching providers like Redis or Ehcache.
- Redis provides distributed caching across nodes.
- Ehcache is in-memory, good for single-node setups.
- Hibernate stores entities in these caches for faster retrieval.
- In banking, Redis is better for microservices needing shared cache.
- Ehcache suits monolithic apps with local caching needs.
- Integration reduces DB hits for reference data.
- But transactional data must bypass cache for accuracy.
- Proper configuration ensures safe caching strategies.
- Hibernate makes this integration seamless.

## 11.5 Why caching entities with balances is dangerous?

### Customers occasionally see incorrect balances that self-correct on refresh. Root cause points to cached entities. Why is caching balance-related entities dangerous?

- Balances change frequently, concurrently, and critically.
- Caching them introduces race conditions between DB commits and cache invalidation. Even milliseconds of staleness can
  show wrong data.
- Under concurrent transfers, cache invalidation storms can occur, degrading performance instead of improving it.
- Worse, stale balances may be used in downstream decisions like limit checks.
- In banking, balances are not just data — they are stateful truth. That truth must come from the database or a strongly
  consistent ledger.
- Caching balances turns strong consistency into probabilistic correctness. That’s unacceptable.

- Suppose you cache account balances in second-level cache.
- Customer A transfers money, DB updates balance. Cache still holds old balance.
- Customer B queries balance and sees outdated info. This leads to wrong decisions or double spending.
- In banking, stale balances are catastrophic. Regulators require real-time accuracy.
- Cache invalidation is complex and error-prone. Balances must always be fetched directly from DB.
- Caching balances risks financial integrity and compliance. Rule: never cache volatile transactional data

# 12. Auditing & Compliance

## 12.1 How do you implement audit fields (createdBy, updatedAt)?

### An auditor asks who created an account, who last modified it, and when. The system must answer reliably for years. How do you implement audit fields?

- Use mandatory audit columns on every persistent entity: createdAt, createdBy, updatedAt, updatedBy.
- Implement them centrally using Spring Data JPA Auditing or Hibernate listeners. Values must be set automatically, not
  by business code.
- Timestamps should be DB-based or standardized UTC to avoid timezone drift.
- User identity should come from the security context, not request headers. Audit fields must be non-null and
  write-protected after creation. In banking, manual audit updates are a red flag.
- If developers can forget to set audit fields, the design is already broken.

- Imagine a teller updates a customer’s address in the banking system.
- You must record who made the change and when.
- Implement audit fields like createdBy, createdAt, updatedBy, updatedAt.
- Use JPA entity listeners or Spring’s @CreatedDate and @LastModifiedDate.
- These fields are auto-populated during insert/update.
- In banking, this ensures accountability for every change.
- It helps track unauthorized modifications.
- Audit fields are critical for fraud detection.
- They also support compliance with regulatory audits.
- Without them, you lose traceability of sensitive updates.
- Audit fields are the foundation of secure banking data.

## 12.2 Hibernate Envers – how does it help auditing?

### Auditors request a full change history of an account: every field change, previous values, and timestamps. How does Hibernate Envers help?

- Hibernate Envers automatically maintains audit tables that store entity state per revision.
- Each update creates a new revision with metadata like timestamp and revision ID. You can reconstruct historical states
  without writing custom logic. This is ideal for compliance and investigations. However, Envers increases storage,
  write cost, and schema complexity. It’s not free.
- In banking, Envers is useful for slow-changing master data, not high-frequency transactional tables.
- Use it selectively. Auditing everything blindly will bloat the system and slow writes.

- Suppose a customer’s loan interest rate is updated.
- Regulators require a full history of changes.
- Hibernate Envers automatically creates audit tables.
- Each entity change is recorded with old and new values.
- This provides versioning of entities over time.
- In banking, Envers ensures you can reconstruct past states.
- It’s useful for disputes—customers can see when changes occurred.
- Envers integrates seamlessly with JPA entities.
- It reduces manual effort in maintaining audit logs.
- It’s a compliance-friendly solution for financial systems.
- Envers makes auditing transparent and reliable.

## 12.3 How do you ensure immutability of audit logs?

### How do you ensure audit logs cannot be modified or deleted, even accidentally?

- Audit data must be append-only. Enforce immutability at multiple layers.
- At the DB level, restrict UPDATE and DELETE privileges. Use separate schemas or databases for audit tables.
- Application code must never expose repositories for audit entities. Consider write-only APIs or DB triggers.
- In some banks, audit logs are shipped to WORM storage or external systems. ORM-level protection alone is insufficient.
- If audit data can be altered, it’s not an audit log — it’s a note.

- Imagine a fraudster tries to alter audit records to hide evidence.
- Audit logs must be immutable—never updated or deleted.
- Use append-only tables for audit entries.
- Restrict permissions so only inserts are allowed.
- In banking, immutability ensures trust in audit trails.
- Regulators demand tamper-proof logs.
- Implement checksums or digital signatures for extra safety.
- Immutable logs prevent cover-ups of unauthorized changes.
- They also support forensic investigations.
- Once written, audit records must remain permanent.
- This guarantees compliance and integrity.

## 12.4 How do you track who changed what and when?

### Auditors ask not just when a record changed, but which fields changed and their old values. How do you track this?

- Field-level tracking requires change data capture. Envers supports this by storing full entity snapshots per revision;
- diffs can be computed between revisions. Alternatively, store explicit change logs capturing field name, old value,
  new value, user, and timestamp.
- This is heavier but clearer for audits. For critical fields like limits or KYC status, explicit change logs are
  preferred.
- Relying on generic logging is insufficient. In banking, auditability must be queryable, not buried in logs.

- Suppose a customer’s account status changes from “Active” to “Dormant.”
- You must record who made the change, when, and what was changed.
- Use audit fields plus Envers or custom listeners.
- Store user ID, timestamp, old value, and new value.
- In banking, this ensures accountability for every update.
- It helps detect unauthorized or suspicious activity.
- Tracking changes supports fraud prevention.
- It also provides transparency for customers.
- Regulators require this level of detail for compliance.
- Without it, you cannot prove data integrity.
- Proper tracking is essential for secure banking operations.

## 12.5 How do you handle regulatory audits with ORM data?

### Regulators demand historical data, traceability, and proof of controls. How do you handle this with ORM-managed data?

- ORM is just a data access layer — compliance is an architecture concern.
- Ensure audit fields are enforced, history is retained per regulation, and data lineage is clear.
- Use immutable audit tables, retention policies, and documented access controls.
- Queries used for audits must be reproducible and validated. Never rely on application logs alone.
- ORM mappings should align with regulatory data models, not hide them.
- In banking, audits are not hypothetical — they are guaranteed. If you can’t answer auditors confidently, your system
  is already non-compliant.

- Imagine regulators audit all loan interest changes in the past year.
- ORM audit logs must be exportable and verifiable.
- Use Envers or custom audit tables to store history.
- Provide reports showing who changed what and when.
- Ensure logs are immutable and tamper-proof.
- Regulators expect clear traceability of financial data.
- ORM must integrate with reporting tools for audit readiness.
- In banking, failure to provide audit trails leads to penalties.
- Proper auditing ensures compliance with RBI, SEC, or other authorities.
- ORM data must be structured for easy retrieval.
- Handling audits well builds trust and avoids legal risks.

# 13. Schema Management & Migrations

## 13.1 Why ddl-auto=update is dangerous in production?

### A small code change is deployed with ddl-auto=update. No errors, but indexes disappear, columns change type, and performance collapses. Why is this dangerous?

- ddl-auto=update lets Hibernate guess how to evolve your schema. Guessing is unacceptable in banking.
- Hibernate doesn’t understand data volume, index strategy, constraints, or regulatory retention rules.
- It can drop columns, alter types, or rebuild tables silently. These changes may lock tables for minutes or hours under
  load.
- Worse, you don’t get a reproducible script — no audit trail. Production schema must be explicitly controlled,
  reviewed, and reversible.
- Auto-DDL removes human verification from the most sensitive asset you have: the database.
- If ddl-auto=update touches prod, that’s a process failure, not a config issue.

- Imagine a banking system where Hibernate auto-updates the schema (ddl-auto=update).
- A developer changes an entity field, Hibernate alters the DB automatically.
- This could drop columns, rename tables, or modify constraints unexpectedly.
- In production, such changes can corrupt live financial data.
- Banking systems require strict control over schema evolution.
- Regulators demand audit trails for every schema change.
- Auto-update bypasses versioning and approvals.
- It risks downtime and compliance violations.
- Best practice: disable ddl-auto in production.
- Use migration tools like Flyway or Liquibase instead.

## 13.2 Flyway vs Liquibase – which is safer for banking?

### Your team must choose between Flyway and Liquibase for a core banking system. Which is safer, and why?

- Both are safer than Hibernate auto-DDL, but Liquibase is usually preferred in banking.
- Flyway enforces linear, immutable migrations — once applied, scripts don’t change. This aligns with audit
  requirements.
- Liquibase supports rollbacks and dynamic change sets, which sounds powerful but increases complexity and misuse risk.
- Banks value predictability over flexibility. Flyway’s SQL-first approach makes DBAs comfortable and reviews easier.
- Liquibase is fine if governance is strict, but in practice, Flyway’s simplicity wins.
- Safety comes from discipline, not features. Pick the tool your process can enforce correctly.

- Suppose you need to manage schema changes across multiple banking environments.
- Flyway uses simple versioned SQL scripts. It’s lightweight and easy to adopt.
- Liquibase supports XML/JSON/YAML changelogs with rollback options. It’s more flexible and audit-friendly.
- In banking, Liquibase is often safer due to rollback and audit features.
- Flyway is simpler but less expressive.
- Both ensure controlled migrations instead of auto-update.
- Choice depends on complexity and compliance needs.
- Liquibase suits regulated environments, Flyway suits simpler setups.
- Either is safer than Hibernate auto-update.

## 13.3 How do you manage schema evolution without downtime?

### You must add a column and migrate data without stopping transactions. How do you evolve the schema safely?

- You use expand-and-contract strategy. First, add new nullable columns or tables without touching existing code paths.
- Deploy code that writes to both old and new structures. Backfill data in controlled batches.
- Switch reads to the new structure once validated. Only then remove old columns. Never do destructive changes in a
  single step.
- Banking systems run 24×7 — downtime is a last resort. Schema evolution must be backward-compatible across deployments.
- If your migration requires downtime, your design is too tight. Zero-downtime migrations are a discipline, not a
  feature.

- Imagine upgrading the transaction table while customers are actively transacting.
- Direct schema changes cause downtime.
- Use rolling updates with backward-compatible changes.
- Add new columns instead of altering existing ones.
- Deploy application changes gradually.
- Use feature flags to switch logic safely.
- Partition large tables to reduce migration impact.
- In banking, downtime is unacceptable.
- Schema evolution must be seamless.
- Zero-downtime migrations ensure continuous availability.
- Careful planning avoids service disruption.

## 13.4 How do you version database changes?

### Auditors ask for proof of when a column was added, who approved it, and which release introduced it. How do you version DB changes?

- Every schema change must be versioned, ordered, and traceable. Migration scripts live in version control alongside
  application code.
- Each script has a unique version, description, and checksum. CI pipelines apply migrations automatically and fail fast
  on mismatch.
- No manual SQL in production. Tags link DB versions to application releases.
- In banking, undocumented schema changes are unacceptable. Versioning is not just technical — it’s governance.
- If you can’t answer “why does this column exist?”, you’ve already failed an audit.

- Suppose you deploy schema changes across dev, test, and prod.
- Without versioning, environments drift apart. Migration tools assign version numbers to each change.
- Scripts are applied sequentially and tracked. In banking, versioning ensures reproducibility.
- Regulators require proof of controlled schema evolution. Versioning avoids accidental overwrites.
- It ensures all environments stay consistent. Developers can trace when and why changes occurred.
- Versioning is essential for compliance and stability. It’s the backbone of safe schema management.

## 13.5 How do you rollback schema changes safely?

### A migration passes tests but causes issues in production. How do you rollback safely?

- You don’t rely on blind rollbacks. Rollback strategy starts before deployment. Non-destructive changes are easier to
  recover from than drops or renames.
- Prefer forward-fix migrations over rollback when data is involved. If rollback is required, it must be scripted,
  tested, and idempotent. Backups are mandatory before risky changes.
- In banking, data loss is worse than downtime. Rollbacks must preserve data integrity and audit trails. If your
  rollback plan is “restore backup and hope”, you’re gambling. Safe rollback is engineered, not improvised.

- Imagine a migration adds a column but breaks reporting queries.You must rollback without losing data.
- Liquibase supports rollback scripts. Flyway requires manual rollback scripts.
- Always test rollback in staging before production.
- In banking, failed migrations can block transactions.
- Rollback must preserve financial records. Use backups before applying risky changes.
- Rollback should be automated and verifiable. Safe rollback ensures recovery from migration errors.
- It’s critical for compliance and business continuity.

# 14. Error Handling & Debugging

## 14.1 Common Hibernate exceptions and root causes.

### Your logs show LazyInitializationException, NonUniqueObjectException, OptimisticLockException, and ConstraintViolationException. What do these actually indicate?

- Hibernate exceptions are symptoms, not bugs in Hibernate.
- LazyInitializationException → accessing LAZY data outside transaction scope. Design leak.
- NonUniqueObjectException → same entity ID attached twice in one persistence context. Session misuse.
- OptimisticLockException → concurrent update detected. Missing retry strategy.
- ConstraintViolationException → DB constraint violated. Validation mismatch or race condition.
- In banking systems, these indicate boundary violations: transaction scope, identity management, or concurrency
  handling. Catching and retrying blindly is wrong. Fix the root cause, not the stack trace.

- Imagine a banking app processing customer transactions.
- LazyInitializationException: occurs when you access a lazy-loaded collection outside of a session.
- NonUniqueObjectException: happens when the same entity is loaded twice with the same ID in persistence context.
- ConstraintViolationException: triggered when DB constraints (like unique account number) are violated.
- OptimisticLockException: occurs when concurrent updates conflict on versioned entities.
- TransactionRequiredException: thrown when operations are attempted outside a transaction.
- In banking, these errors can cause failed transfers or duplicate accounts.
- Root causes are usually mismanaged sessions, incorrect mappings, or concurrency issues.
- Understanding these exceptions helps prevent outages.
- Each exception signals a deeper design or transaction boundary problem.

## 14.2 How do you handle LazyInitializationException properly?

### A REST API returns an entity with LAZY associations. Serialization fails with LazyInitializationException. How do you handle this correctly?

- Do not enable Open Session in View blindly. That hides the problem and creates uncontrolled DB access during
  serialization.
- The correct fixes are: fetch required data explicitly using JOIN FETCH or @EntityGraph, map entities to DTOs inside
  the transaction, or use projections for read APIs.
- Transactions should end before data leaves the service layer.
- In banking, uncontrolled lazy loading can trigger N+1 queries and leak sensitive data.
- LazyInitializationException is Hibernate telling you your boundaries are wrong. Listen to it.

- Suppose a customer’s account entity has lazy-loaded transactions.
- If you access transactions outside the persistence context, Hibernate throws LazyInitializationException.
- In banking, this can break APIs when fetching transaction history.
- Solutions include:
- Using fetch joins in JPQL.
- Applying @EntityGraph to prefetch associations.
- Using DTO projections instead of exposing entities.
- Carefully applying OpenSessionInView (but risky in banking).
- Best practice: load required data explicitly in service layer.
- This ensures APIs return complete data without lazy-loading errors.
- Proper handling avoids runtime failures in customer-facing apps.
- It also prevents exposing sensitive data unintentionally.

## 14.3 Why does Hibernate throw NonUniqueObjectException?

### Hibernate throws NonUniqueObjectException: a different object with the same identifier value was already associated with the session. Why?

- Hibernate enforces identity per persistence context.
- If you load an entity and later attach another instance with the same ID (via save, update, or deserialization),
  Hibernate refuses.
- This often happens when mapping DTOs directly to entities or mixing merge and update incorrectly.
- In banking systems, this leads to silent overwrites if not detected. Use merge for detached entities and avoid manual
  entity reconstruction.
- One ID → one object per session. Violating this breaks Hibernate’s consistency guarantees.

- Imagine two clerks updating the same account record.
- Hibernate loads the account entity twice with the same ID in persistence context.
- When you try to persist, Hibernate detects duplicate references.
- This triggers NonUniqueObjectException.
- In banking, this can occur during batch updates or reconciliation jobs.
- Root cause: mixing persist() and merge() incorrectly.
- Solution: use merge() for detached entities, avoid duplicate loads.
- Ensure transaction boundaries are clear.
- This prevents duplicate account records or failed updates.
- Proper entity management avoids this exception.
- It’s a common pitfall in high-volume banking systems.

## 14.4 How do you debug slow Hibernate queries?

### Under production load, response times spike. DB looks fine, but Hibernate queries are slow. How do you debug this?

- First, enable SQL logging temporarily with bind parameters. Look for N+1 queries, missing indexes, and cartesian
  joins.
- Analyze execution plans at the DB level — Hibernate does not optimize SQL.
- Measure query count per request, not just execution time. Check transaction duration and lock waits.
- Enable Hibernate statistics in non-prod to identify hotspots.
- In banking, slow queries often come from ORM misuse, not DB slowness.
- Hibernate hides SQL — debugging means pulling SQL back into the light.

- Suppose transaction history queries take minutes instead of seconds.
- Enable Hibernate SQL logging to see generated queries.
- Use tools like p6spy to monitor SQL execution.
- Check for N+1 query problems with associations.
- Analyze DB execution plans for missing indexes.
- In banking, slow queries can delay fund transfers.
- Optimize fetch strategies (use JOIN FETCH, projections).
- Tune batch sizes and caching where safe.
- Profile queries with DB tools like EXPLAIN.
- Debugging ensures queries meet SLA requirements.
- Performance tuning is critical for customer trust.

## 14.5 How do you log SQL safely in production?

### You need SQL logs in production for debugging, but logs may contain PII and financial data. How do you do this safely?

- Never enable full SQL + parameter logging permanently in production.
- Use structured, sampled, or masked logging. Log SQL shape, execution time, and row count — not raw values.
- Use DB-level slow query logs instead of app logs where possible.
- Enable detailed logging only under incident flags and for short durations.
- Mask account numbers and amounts. In banking, logs are part of the attack surface.
- Debugging must not compromise confidentiality. Observability without data leakage is the goal.

- Imagine regulators auditing transaction queries.
- Logging SQL helps debug issues, but must be safe.
- Never log sensitive parameters like account numbers or balances in plain text.
- Use masked logging for parameters.
- In banking, exposing raw SQL in logs risks compliance violations.
- Configure Hibernate to log SQL without sensitive values.
- Use tools like p6spy with masking enabled.
- Ensure logs are rotated and secured.
- Safe logging balances debugging with security.
- Regulators demand strict control over log data.
- Proper logging avoids leaks while supporting audits.

# 15. Microservices & JPA

## 15.1 Why each microservice should own its database?

### Two microservices read and write the same database tables because “it’s simpler”. Why should each microservice own its database?

- Shared databases create hard coupling at the worst possible layer.
- A schema change by one service can break another without warning.
- You lose independent deployments, independent scaling, and independent rollback.
- Transactions silently cross service boundaries, killing fault isolation.
- ORM entities become de-facto shared contracts that no one can evolve safely.
- In banking, this turns microservices into a distributed monolith with worse failure modes.
- Database ownership enforces service boundaries at the data level — without it, microservices are a lie.

- Imagine a banking system with separate services: Accounts, Transactions, Loans.
- If they all share one database, schema changes in one service can break others.
- Ownership ensures each service evolves independently.
- In banking, account service may use relational DB, transaction service may use event store.
- This separation avoids tight coupling.
- It also improves scalability and fault isolation.
- Regulatory audits are easier when each service has its own data boundary.
- Shared DBs risk cross-service corruption.
- Microservice autonomy ensures resilience.
- Each service owning its DB is a core principle of safe banking architecture.

## 15.2 How do you avoid cross-service entity sharing?

### Teams want to share entity JARs to avoid duplication. Why is cross-service entity sharing a bad idea?

- Sharing entities couples services to internal persistence models.
- A column rename becomes a breaking change across services. Lazy loading, cascade rules, and version fields leak into
  other bounded contexts.
- You also accidentally share business rules and assumptions.
- In microservices, entities are private implementation details.
- Contracts between services should be explicit: APIs, events, or schemas — not JPA annotations.
- Duplication is cheaper than tight coupling. If two services share entities, they’re not independent systems.

- Suppose the loan service needs customer details.
- If it directly uses the Customer entity from account service, coupling occurs.
- Schema changes in one service break the other.
- Instead, share data via APIs or events.
- In banking, customer service publishes events like “CustomerUpdated.”
- Loan service consumes these events to update its own copy.
- This avoids direct entity sharing.
- It ensures services remain independent.
- Cross-service entity sharing violates microservice boundaries.
- Proper isolation ensures compliance and scalability.
- Always use DTOs or events, never shared entities.

## 15.3 How do you handle joins across services?

### A report needs data from Accounts service and Transactions service. How do you handle joins across services?

- You don’t do DB joins across services. Ever.
- Options include API composition (one service calls another), asynchronous materialized views, or event-driven
  projections.
- For heavy reporting, build a read model or data warehouse fed by events.
- ORM joins assume strong consistency and single transaction scope — both are false in microservices.
- Cross-service joins create hidden runtime dependencies and cascading failures.
- In banking, reporting systems are intentionally decoupled from transactional systems for this reason.

- Imagine generating a report of customers with loans and transactions.
- You cannot join across service databases directly.
- Instead, use API composition: call each service and merge results.
- Or use CQRS read models: maintain a denormalized reporting DB.
- In banking, reporting DB aggregates data from multiple services.
- This avoids cross-service joins.
- It ensures transactional DBs remain isolated.
- Joins across services break autonomy and scalability.
- Reporting DBs provide safe, optimized queries.
- This pattern is essential for compliance reporting.
- Never join across microservice DBs directly.

## 15.4 How does eventual consistency affect ORM usage?

### A service reads stale data because updates arrive asynchronously. How does eventual consistency affect ORM usage?

- ORMs assume immediate consistency and transactional boundaries. Eventual consistency breaks that assumption.
- Entities may be temporarily out of sync with reality. Version fields don’t protect across services.
- You must design for retries, idempotency, and compensating actions. ORM entities should not encode cross-service
  invariants.
- In microservices, ORM is a persistence tool — not a consistency guarantee.
- Accept that data can be “wrong” for a while and design workflows accordingly.
- If your business logic requires strict consistency, it probably doesn’t belong in a microservice.

- Suppose a transfer updates account balance in one service and transaction record in another.
- ORM assumes immediate consistency.
- But microservices often rely on eventual consistency via events.
- This means balances may not reflect transactions instantly.
- In banking, this requires careful design.
- Customers must see consistent balances despite async updates.
- ORM cannot guarantee cross-service consistency.
- Use Saga or event-driven patterns instead.
- Eventual consistency is acceptable if properly communicated.
- ORM usage must be limited to within a single service.
- Cross-service consistency requires distributed patterns.

## 15.5 Should entities be exposed in REST APIs? Why not?

### A team returns JPA entities directly from REST controllers to save time. Why is this dangerous?

- Entities are not API contracts. They expose internal structure, lazy-loading behavior, and fields you didn’t intend to
  publish.
- Changes for persistence reasons become breaking API changes. Serialization can trigger lazy loading, N+1 queries, or
  even data leaks.
- Versioning becomes impossible without hacks. In banking, exposing entities risks leaking balances, audit fields, or
  internal IDs.
- APIs should return DTOs designed for consumers, not persistence. Convenience today becomes technical debt tomorrow.

- Imagine exposing Account entity directly in REST API.
- It may include sensitive fields like internal IDs or audit logs.
- Lazy-loading proxies can cause serialization errors.
- In banking, this risks leaking confidential data.
- Instead, use DTOs tailored for API responses.
- DTOs expose only required fields (e.g., account number, balance).
- Entities are persistence models, not API contracts.
- Exposing them couples API with DB schema.
- This makes future changes risky.
- DTOs ensure security, clarity, and compliance.
- Rule: never expose entities directly in REST APIs.

# 16. Real-World Banking Scenarios

## 16.1 Fund transfer – how do you ensure atomic debit and credit?

### How do you ensure atomic debit and credit during a fund transfer using JPA/Hibernate?

- Use a single database transaction with @Transactional
- Lock both source and destination account rows using PESSIMISTIC_WRITE
- Validate balance after acquiring the lock, not before
- Perform debit and credit updates in the same transaction
- Commit only if both operations succeed; rollback on any failure
- Use idempotency keys to prevent duplicate transfers
- Never split debit and credit into separate service calls
- Avoid distributed transactions for core transfers
- Rely on database ACID guarantees, not application logic
- This ensures money is never partially transferred

- Imagine a customer transfers ₹500 from Account A to Account B.
- Both debit (A - 500) and credit (B + 500) must happen together.
- Use a single transaction boundary to ensure atomicity.
- If debit succeeds but credit fails, rollback restores consistency.
- Hibernate integrates with Spring’s @Transactional to manage this.
- Optimistic or pessimistic locking prevents concurrent updates from corrupting balances.
- Database constraints ensure balances never go negative.
- In banking, atomicity is non-negotiable—partial transfers are unacceptable.
- Proper transaction isolation ensures no dirty reads.
- This guarantees customer trust and regulatory compliance.

## 16.2 High-volume salary credit – how do you optimize JPA writes?

### How do you optimize JPA writes for high-volume salary credit processing?

- Enable JDBC batching (hibernate.jdbc.batch_size)
- Disable auto-flush and unnecessary cascades
- Use bulk inserts with controlled batch sizes
- Flush and clear persistence context periodically
- Avoid entity relationships during bulk writes
- Use projections or native SQL where ORM overhead is high
- Keep transaction boundaries tight
- Use stateless sessions if supported
- Avoid per-record validation queries
- This prevents memory pressure and DB overload

- Suppose a bank credits salaries for 50,000 employees.
- Writing each record individually is slow and memory-intensive.
- Use batch inserts/updates with hibernate.jdbc.batch_size.
- Flush and clear persistence context after chunks (e.g., 1000 records).
- Disable auto-flush to avoid unnecessary DB hits.
- Consider native SQL for extreme performance.
- Use Spring Batch for orchestration and retry logic.
- Index salary tables to speed up inserts.
- In banking, this ensures payroll completes within SLA.
- Optimized writes prevent downtime during peak load.
- Efficiency here directly impacts customer satisfaction.

## 16.3 Reconciliation job – how do you detect mismatches efficiently?

### How do you efficiently detect balance mismatches during reconciliation jobs?

- Push aggregation logic to the database
- Use SUM, GROUP BY, and HAVING clauses
- Fetch only mismatched records
- Use DTO projections instead of entities
- Process reconciliation in batches
- Avoid loading entire transaction history into memory
- Prefer native queries for heavy analytical logic
- Use indexes on reconciliation keys
- Run jobs in read-only transactions
- This keeps reconciliation fast and scalable
-
-
- Imagine reconciling transactions between core banking and payment gateway.
- Full entity loads are too heavy for millions of records.
- Use projections to fetch only IDs and amounts.
- Compare datasets using batch jobs or streaming.
- Use hash checksums for quick mismatch detection.
- Partition data by date to reduce query scope.
- In banking, reconciliation must be fast and accurate.
- Native SQL often outperforms ORM for such jobs.
- Detect mismatches early to prevent financial loss.
- Efficient reconciliation ensures compliance with regulators.
- It’s a critical safeguard against fraud and system errors.

## 16.4 How do you handle historical transaction data archiving?

### How do you archive historical transaction data without impacting live performance?

- Separate hot and cold data using archive tables
- Partition tables by date or fiscal year
- Keep archived entities read-only
- Exclude archived data from normal ORM queries
- Use background jobs for data movement
- Avoid cascading deletes on archive data
- Restrict ORM access to active data only
- Index archive tables for audit queries
- Never mix archive and live data writes
- This keeps live tables lean and fast

- Suppose you store 10 years of transaction history.
- Keeping all in active tables slows queries.
- Archive old data into separate tables or databases.
- Use partitioning by year/month for efficient access.
- ORM should not load archived data into active contexts.
- Provide reporting DBs for auditors and regulators.
- In banking, archiving balances performance with compliance.
- Customers see recent history, auditors access full history.
- Archiving reduces storage costs and query times.
- It also ensures active DBs remain lean.
- Proper archiving strategy is essential for scalability.

## 16.5 How do you design read-optimized vs write-optimized entities?

### How do you design read-optimized and write-optimized entities in banking systems?

- Write-optimized entities are normalized and minimal
- They focus on correctness, constraints, and locking
- Read-optimized models are denormalized
- Use DTOs, views, or projections for reads
- Avoid heavy relationships in write models
- Avoid writes on read models
- Do not reuse write entities for reporting
- Separate transactional and reporting concerns
- This aligns with CQRS principles
- It improves performance and safety

- Imagine handling transaction history vs fund transfers.
- Write-optimized entities: normalized, strict constraints, transactional safety.
- Example: Transaction entity with account linkage and versioning.
- Read-optimized entities: denormalized, projections, faster queries.
- Example: Reporting entity with flattened customer + account + transaction info.
- In banking, writes must prioritize accuracy, reads must prioritize speed.
- CQRS pattern separates read and write models.
- Read DBs can be replicated for analytics.
- Write DBs remain authoritative for transactions.
- This design balances performance and integrity.
- It’s essential for large-scale banking systems.

# 17. Testing Hibernate & JPA

## 17.1 How do you unit test repositories?

### How do you unit test JPA repositories without pulling the full application context?

- Use @DataJpaTest
- Load only JPA components (EntityManager, repositories)
- Use embedded DB (H2/Testcontainers)
- Preload data using SQL or TestEntityManager
- Verify CRUD behavior and query correctness
- Assert generated SQL results, not business logic
- Rollback after each test by default
- Avoid mocking repositories (pointless)
- Focus on query correctness and mappings
- Repository tests validate persistence, not workflows

- Imagine you’re testing the AccountRepository in a banking app.
- You want to verify that findByAccountNumber() returns the correct account.
- Use an in-memory DB like H2 for unit tests.
- Load minimal test data with @DataJpaTest.
- Test CRUD operations (save, find, delete).
- Ensure constraints like unique account numbers are enforced.
- In banking, this prevents duplicate accounts or invalid saves.
- Unit tests validate repository logic without hitting production DB.
- They ensure queries behave as expected.
- Proper repository tests catch bugs early.
- This builds confidence in financial data integrity.

## 17.2 @DataJpaTest vs full context – when to use what?

### When should you use @DataJpaTest instead of loading the full Spring Boot context?

- Use @DataJpaTest for repository-level testing
- It loads only JPA-related beans
- Faster startup and isolated failures
- Ideal for query methods and mappings
- Use full context (@SpringBootTest) for integration flows
- Full context is needed for security, messaging, transactions
- Repository logic does not need controllers or services
- Mixing both slows test suite unnecessarily
- Wrong choice increases CI time
- Separation keeps tests focused and fast

- Suppose you’re testing transaction queries.
- @DatapaTest loads only JPA components, making tests fast.
- It’s ideal for repository-level unit tests.
- Full context loads the entire Spring application.
- Use full context when testing integration with services or transactions.
- In banking, @DataJpaTest suits isolated repository tests.
- Full context suits end-to-end scenarios like fund transfers.
- Choosing the right scope avoids slow or bloated tests.
- It ensures tests remain focused and efficient.
- Both approaches complement each other.
- Use @DataJpaTest for repositories, full context for workflows.

## 17.3 How do you test transactional rollbacks?

### How do you verify that a transaction rolls back correctly when an exception occurs?

- Wrap test logic inside a transactional service call
- Trigger a runtime exception deliberately
- Assert database state after method execution
- Use separate transaction to verify rollback
- Avoid relying on in-memory entity state
- Check row count or balance values from DB
- Do not catch the exception inside the service
- Use @Transactional at service layer
- Rollback must be DB-visible, not JVM-visible
- This ensures data integrity under failures

- Imagine a fund transfer fails midway.
- Debit succeeds, but credit fails due to DB error.
- You must ensure rollback restores balance.
- In tests, wrap methods in @Transactional.
- Simulate exceptions during transaction.
- Assert that DB state remains unchanged.
- In banking, rollback prevents partial transfers.
- Tests validate atomicity of transactions.
- They ensure compliance with financial integrity rules.
- Without rollback tests, silent data corruption may occur.
- Proper rollback testing is critical for trust.

## 17.4 How do you test concurrency issues?

### How do you test concurrent updates and locking behavior in JPA?

- Use multiple threads in test
- Snchronize start using CountDownLatch
- Execute concurrent transactions against same row
- Assert version conflicts or lock timeouts
- Use real database (not H2 for locking tests)
- Test optimistic locking via @Version
- Test pessimistic locking via PESSIMISTIC_WRITE
- Expect exceptions like OptimisticLockException
- Avoid mocking concurrency
- Concurrency bugs only appear with real DB behavior

- Suppose two transfers hit the same account simultaneously.
- You must test optimistic and pessimistic locking.
- Simulate concurrent threads updating the same entity.
- With optimistic locking, one update should fail.
- With pessimistic locking, one should wait.
- In banking, this prevents double debits.
- Tests validate concurrency control mechanisms.
- They ensure system behaves correctly under load.
- Concurrency tests catch race conditions early.
- They are essential for high-volume transaction systems.
- Proper concurrency testing ensures financial safety.

## 17.5 How do you test database-specific behavior?

### How do you test database-specific behavior like locking, indexes, and SQL functions?

- Use Testcontainers with actual DB (Postgres, MySQL, Oracle)
- Avoid relying solely on H2
- Run tests against same DB engine as production
- Validate native queries and vendor-specific SQL
- Test lock behavior and isolation levels
- Verify index usage via execution plans if needed
- Separate DB-specific tests from unit tests
- Expect slower but more accurate tests
- This catches production-only failures early
- Banking systems cannot afford DB surprises

- Imagine deploying to Oracle in production but using PostgreSQL in dev.
- Queries may behave differently across DBs.
- Use Testcontainers to spin up real DB instances in tests.
- Validate queries against production-like DB.
- In banking, DB-specific behavior can affect compliance reports.
- Indexing, constraints, and functions vary by DB.
- Testing ensures portability and correctness.
- It avoids surprises during deployment.
- DB-specific tests are critical for regulated environments.
- They ensure queries meet SLA across all environments.
- This builds confidence in multi-DB banking systems.

## 18. Anti-Patterns & Failure Stories

## 18.1 Why entities should not contain business logic?

### Why is it dangerous to put business logic inside JPA entities in banking systems?

- Entities are persistence models, not domain services
- Entity methods execute outside transactional awareness
- Lazy-loaded data may not be available inside entity logic
- Business logic inside entities is hard to test in isolation
- Entities get reused unintentionally across use cases
- Leads to side effects during serialization/deserialization
- Breaks separation of concerns
- Makes auditing and validation inconsistent
- Encourages anemic vs over-bloated domain confusion
- Banking rules belong in service/domain layers, not ORM models

- Imagine an Account entity that directly calculates overdraft fees.
- Entities should represent state, not business rules.
- Mixing logic with persistence couples DB schema to business workflows.
- In banking, fee rules change often—updating entities risks breaking persistence.
- It also makes testing harder since entities depend on DB context.
- Business logic belongs in service or domain layers.
- Entities should remain lightweight and focused on mapping.
- Otherwise, you risk bloated models that are hard to maintain.
- Clean separation ensures flexibility and scalability.
- In banking, this separation is critical for compliance and audits.
- Entities = state, services = rules.

## 18.2 Why exposing entities directly in APIs is dangerous?

### Why should JPA entities never be exposed directly through REST APIs?

- Exposes internal schema structure
- Triggers unintended lazy loading
- Causes N+1 queries during serialization
- Breaks backward compatibility on schema change
- Allows accidental updates through JSON binding
- Security risk: hidden fields may leak
- Tight coupling between API and database
- No control over response size
- Makes versioning nearly impossible
- DTOs exist to prevent all of this

- Suppose you expose the Customer entity in a REST API.
- It may include sensitive fields like internal IDs, audit logs, or lazy proxies.
- Lazy-loaded associations can cause serialization errors.
- In banking, this risks leaking confidential data like PAN or KYC details.
- Entities are persistence models, not API contracts.
- Exposing them couples API with DB schema, making changes risky.
- DTOs should be used to expose only required fields.
- DTOs also allow masking sensitive data.
- This ensures compliance with data privacy regulations.
- Exposing entities directly is a security and design anti-pattern.
- Always use DTOs for safe API responses.

## 18.3 How EAGER fetching caused production outage.

### How can EAGER fetching lead to a real production outage in banking applications?

- EAGER loads entire object graph automatically
- A simple query triggers massive joins
- Memory usage spikes unexpectedly
- DB connections stay open longer
- Serialization explodes response payload size
- Thread pools get exhausted
- GC pressure increases drastically
- One API call fans out into thousands of queries
- Happens silently without code change
- Result: DB slowdown → API timeout → outage

- Imagine a dashboard showing customer details.
- The entity had EAGER fetching for accounts, transactions, and loans.
- Querying one customer loaded thousands of linked records.
- Under load, memory overflow crashed the system.
- In banking, this caused downtime during peak hours.
- EAGER fetching pulled unnecessary data, overwhelming DB and JVM.
- Lazy fetching with selective joins would have prevented this.
- Outage highlighted the danger of uncontrolled fetch strategies.
- Lesson: always default to LAZY and fetch explicitly.
- EAGER fetching can silently kill performance in production.

## 18.4 How missing @Version caused double debit.

### How can missing @Version annotation lead to double debit in concurrent transactions?

- Two transactions read same account balance
- Both pass balance validation
- Both update balance independently
- Last commit silently overwrites first
- No conflict detected by Hibernate
- Lost update occurs
- Money debited twice
- No exception raised
- Audit logs show valid transactions
- @Version would have detected and blocked this

- Suppose two transfers hit the same account simultaneously.
- Both read balance = ₹1000.
- Each debits ₹500, final balance = ₹500 instead of ₹0.
- Missing @Version meant Hibernate didn’t detect lost updates.
- Customers were double debited, causing financial loss.
- Optimistic locking with @Version would have prevented this.
- One transaction would fail due to version mismatch.
- In banking, concurrency control is critical for accuracy.
- Missing versioning is a silent but dangerous bug.
- Lesson: always use @Version for transactional entities.

## 18.5 How improper cascade deleted critical banking data.

### How can improper cascade configuration delete critical banking data?

- CascadeType.ALL propagates remove operations
- Deleting parent deletes child records
- Account deletion cascades to transactions
- Historical financial data gets wiped
- Violates audit and regulatory requirements
- Happens without explicit delete query
- Often triggered accidentally during cleanup
- No warning from ORM
- Database happily executes cascade
- Cascades must be used surgically, not blindly

- Imagine deleting a customer entity with CascadeType.ALL.
- Hibernate cascaded delete to accounts and transactions.
- This wiped critical financial records.
- In banking, transactions must never be deleted.
- Cascade should be used selectively (e.g., for child cards).
- Improper cascade caused compliance violations.
- Regulators require immutable transaction history.
- Developers must carefully design cascade rules.
- Lesson: never use ALL blindly—especially in banking.
- Cascade misuse can destroy audit trails and trust.