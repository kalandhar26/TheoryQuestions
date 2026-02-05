# Spring Transactions

- Transactions follow ACID properties
  A - Atomicity: All or nothing
  C - Consistency: Data remains valid after commit
  I - Isolation: Parallel transactions don’t corrupt each other
  D - Durability: Committed data survives crashes
- ACID works only inside one database.

# Transactions in MicroServices (Distributed Systems)

- We never have a transaction across services. Each service only protects its own DB.
- Here the pattern is simple '@Transaction' (persistent in DB) and then publish the event to Other services.
- If we do '@Transaction' across multiple services (Order + Payment + Inventory) then production pain. So should never
  violate this rule.

## Let's try to understand a problem

- In microservices, when a service like Order Service creates an order, it needs to:
- Save the order in its own database (local ACID transaction)
- Publish an event to Kafka so Payment Service, Inventory Service can react.
- The risky way

```text
@Transactional
saveOrderInDB();
kafkaTemplate.send("order-created", order);
```

- Problem = Dual-write problem (or two-phase write issue)
- DB save succeeds → but Kafka send fails (network issue, broker down, partition full) → Event lost → Other services
  never know order happened → Inconsistent system (order exists but no payment/ stock reserved)
  Or Kafka send succeeds → but DB save fails/rolls back → Ghost event → Other services think order happened but it
  didn't → Duplicate payments, oversold stock, angry customers
- This breaks atomicity — we want "save + notify" to be all-or-nothing, but DB and Kafka are different systems.
- For Distributed transactions (2PC/XA) are bad here — slow, blocking, fragile.

## 2PC (Two-Phase Commit):

- Two-Phase Commit is a protocol used to ensure atomic transactions across multiple systems or databases.
- **Goal:** Guarantee that either all participants commit or all participants roll back, maintaining consistency in
  distributed transactions.

### How It Works

- 2PC involves a coordinator and multiple participants (databases or services):

#### Phase 1 – Prepare

- The coordinator asks all participants if they can commit the transaction.
- Each participant executes the transaction locally but does not commit yet.
- Participants respond with “Yes” (ready to commit) or “No” (abort).

#### Phase 2 – Commit/Rollback

- If all participants say Yes → Coordinator sends a Commit command, and each participant commits.
- If any participant says No → Coordinator sends a Rollback command, and all participants undo their changes.

### Challenges

- **Blocking:** If the coordinator crashes after Phase 1, participants may be stuck waiting (cannot decide on their
  own).
- **Performance:** Slow due to multiple network round-trips and locks held during the process.
- **Scalability:** Not ideal for high-throughput microservices; works better in tightly controlled environments.

### Use Cases

- **Banking Transactions:** Transferring money across accounts in different databases.
- **Legacy Systems:** Where distributed transactions are unavoidable.
- **Strong Consistency Requirements:** When eventual consistency (like Outbox) is not acceptable.

## Outbox Pattern:

- The Outbox Pattern is a design strategy in microservices that ensures reliable communication between a database and a
  message broker by storing events in an "outbox" table within the same transaction as business data. This prevents data
  loss, duplication, and inconsistencies when publishing events.

### What is the Outbox Pattern?

- **Definition:** A pattern used in distributed systems to guarantee that database changes and event publishing happen
  atomically.
- **Core Idea:** Instead of directly sending a message to a broker (like Kafka or RabbitMQ) during a transaction, the
  service writes the message into an outbox table in the same database transaction.
- **Later Step:** A separate process (often a background worker or CDC tool) reads the outbox table and publishes the
  events to the broker.

### How It Works

- **Transaction Start:** Service updates business data (e.g., order status).
- **Outbox Write:** In the same transaction, it writes an event record into the outbox table.
- **Commit:** Both changes are committed together, ensuring atomicity.
- **Event Relay:** A relay process reads the outbox table and publishes events to the message broker.
- **Cleanup:** Outbox entries are marked as processed or deleted.

### Challenges

- **Outbox Table Growth:** Needs cleanup strategies (TTL, archiving).
- **Delay Complexity:** Requires a reliable mechanism to publish events.
- **Latency:** Events are not published instantly; depends on relay frequency.

### Use Cases

- **Saga Pattern:** Coordinating distributed transactions across microservices.
- **Event-Driven Systems:** Publishing domain events reliably.
- **Audit Logging:** Ensuring logs are consistent with business data.

| Feature     | Outbox Pattern             | Two-Phase Commit                |
|-------------|----------------------------|---------------------------------|
| Consistency | Eventual                   | Strong(atomic)                  |
| Performance | High throughput            | Slower, blocking                |
| Complexity  | Moderate                   | High                            |
| Scalability | Excellent                  | Poor                            |
| Use Case    | Event-driven microservices | Critical financial transactions |

- OrderService send OrderCreated event to Payment and Inventory Services.
- PaymentService send PaymentDone event to InventoryService.
- But in InventoryService the stock is OutOfStock. Now rollback is not an ideal scenario.
- Payment is not rollback if later steps fail, Refund is a new BusinessAction, not DB rollback.
- If InventoryCheck is after Payment, refunds will happen. This is a business decision, not a tech bug.
- This is Compensation [ Payment failed -> Cancel Order ; InventoryStockFailed -> RefundPayment -> Cancel Order]
- No Roll Back here, Just another transaction.

### Correct Approach: Compensation

| Failure          | Action         |
|------------------|----------------|
| Payment failed   | Cancel Order   |
| Inventory failed | Refund Payment |
| Refund completed | Cancel Order   |

- These are new business transactions, not rollbacks.

# CQRS

- CQRS is a design pattern that separates read operations (queries) from write operations (commands) in a system.
- **Core Idea:** Instead of using the same model for both reads and writes, you split them into two distinct models.
- **Command Model:** Handles state changes (create, update, delete).
- **Query Model:** Handles data retrieval (read-only).

## How CQRS Works?

### Commands:

- Represent intent to change state (e.g., "PlaceOrder", "UpdateCustomer").
- Go through validation and business logic.
- Often stored in a write-optimized database.

### Queries:

- Retrieve data without modifying state.
- Can use a read-optimized database (like denormalized views, caches, or search indexes).

### Event Propagation:

- When a command updates data, it may emit events.
- These events update the query side asynchronously, keeping read models in sync.

### Challenges

- **Complexity:** Adds architectural overhead compared to CRUD.
- **Consistency:** Query side may be eventually consistent (not always real-time).
- **Event Handling:** Requires reliable messaging/event infrastructure.

### Use Cases

- **Microservices:** Where read and write workloads differ significantly.
- **Event Sourcing:** CQRS pairs naturally with event sourcing (commands generate events, queries read projections).
- **High-Performance Systems:** E-commerce, banking, analytics dashboards.

- In modern microservices architectures, CQRS is often combined with Event Sourcing and Outbox Pattern to build
  resilient, scalable systems.

# SAGA

- A Saga is a sequence of local transactions across multiple microservices.
- Each local transaction updates its own data and then publishes an event.
- If one transaction fails, compensating transactions are triggered to undo previous changes.
- Goal: Achieve eventual consistency without using heavy protocols like 2PC.

# Choreography (SAGA)

- Choreography means there is no central coordinator.
- Each service listens for events and reacts accordingly.
- The flow of the saga is driven by events rather than commands from a central orchestrator.

## How Choreography Works

- Service A performs a local transaction and publishes an event (e.g., OrderCreated).
- Service B listens to that event, performs its own transaction (e.g., reserve inventory), and publishes another event (
  InventoryReserved).
- Service C listens to InventoryReserved, processes payment, and publishes PaymentProcessed.
- If something fails (e.g., payment fails), a compensating event is published (PaymentFailed), and other services
  react (e.g., release inventory, cancel order).

## Challenges

- Complexity in Flow: Harder to visualize the entire saga since logic is spread across services.
- Coupling via Events: Services must agree on event formats and semantics.
- Error Handling: Compensating transactions must be carefully designed.

## Use Cases

- E-commerce Orders: Order → Inventory → Payment → Shipping.
- Travel Booking: Flight → Hotel → Car rental.
- Financial Transactions: Multi-step workflows where rollback is needed.

| Feature	         | Choreography (Events)      | Orchestration (Central Coordinator) |
|------------------|----------------------------|-------------------------------------|
| Control	         | Decentralized              | Centralized                         |
| Scalability	     | High	                      | Moderate                            |
| Complexity       | Hard to trace	             | Easier to visualize                 |
| Failure Handling | Distributed compensations	 | Centralized compensations           |

# Orchestration (SAGA)

- Orchestration is a way to manage distributed transactions where a central coordinator (orchestrator) controls the flow
  of the saga.
- **Core Idea:** Instead of services reacting to each other’s events (like in choreography), the orchestrator explicitly
  tells
  each service what to do next.

## How Orchestration Works

- Orchestrator starts the saga (e.g., OrderService sends a request to the orchestrator).
- The orchestrator sends commands to services in sequence:
- Call InventoryService to reserve stock.
- Call PaymentService to process payment.
- Call ShippingService to arrange delivery.
- Each service executes its local transaction and responds with success/failure.
- If a service fails, the orchestrator triggers compensating transactions in reverse order (e.g., cancel payment,
  release inventory).

## Challenges

- Single Point of Control: Orchestrator can become a bottleneck or single point of failure.
- Coupling: Services depend on the orchestrator’s commands.
- Complexity in Orchestrator: Logic can grow large and hard to maintain.

## Use Cases

- Order Management: Coordinating inventory, payment, and shipping.
- Travel Booking: Flight, hotel, and car rental reservations.
- Financial Workflows: Multi-step approval and settlement processes.

## When to use What?

| Situation                | Use           |
|--------------------------|---------------|
| Money involved           | Orchestration |
| Refunds required         | Orchestration |
| Long-running process     | Orchestration |
| Simple async reactions   | Choreography  |
| High read traffic        | CQRS          |
| Strong write consistency | Saga + CQRS   |
| Reporting & dashboards   | CQRS + Events |

| Feature / Aspect         | **CQRS**                                               | **Choreography (Event-Driven)**                       | **Orchestration (Central Coordinator)**         |
|--------------------------|--------------------------------------------------------|-------------------------------------------------------|-------------------------------------------------|
| Core Idea                | Separate **commands (writes)** and **queries (reads)** | Services react to events without a central controller | One service coordinates the entire workflow     |
| Primary Goal             | Scalability + performance                              | Loose coupling + scalability                          | Business flow control + consistency             |
| Control                  | Split by responsibility (write vs read)                | Decentralized                                         | Centralized                                     |
| Decision Making          | Command side only                                      | Distributed across services                           | Centralized in orchestrator                     |
| Communication Style      | Commands + events                                      | Events only                                           | Commands + events                               |
| Transaction Scope        | Local to each service                                  | Local to each service                                 | Local to each service                           |
| Consistency Model        | Strong for writes, eventual for reads                  | Eventual consistency                                  | Eventual consistency with explicit compensation |
| Scalability              | High (especially reads)                                | Very high                                             | Moderate (acceptable for critical flows)        |
| Traceability             | Moderate (needs correlation IDs)                       | Hard to trace                                         | Easy to trace                                   |
| Debugging                | Moderate                                               | Difficult                                             | Easier                                          |
| Failure Handling         | Handled on command side                                | Distributed compensations                             | Centralized compensations                       |
| Timeout Handling         | Command logic                                          | Hard / implicit                                       | Explicit & controlled                           |
| Business Flow Visibility | Medium                                                 | Poor                                                  | High                                            |
| Coupling                 | Low data coupling                                      | Low technical, high mental                            | Higher technical, lower mental                  |
| Best Suited For          | Read-heavy systems, dashboards                         | Notifications, analytics, side effects                | Orders, payments, long-running workflows        |
| Typical Risks            | Eventual read staleness                                | Kafka spaghetti, hidden flows                         | Orchestrator misuse or overloading              |
| Common Misuse            | Assuming CQRS = event sourcing                         | Using for money flows                                 | Using for every tiny workflow                   |

## Conclusion

- CQRS → Optimizes how systems write and read data. CQRS separates responsibilities.
- Choreography → Optimizes how services react to changes. Choreography spreads reactions.
- Orchestration → Optimizes how business workflows are controlled. Orchestration centralizes decisions.

==========================================

# Transaction Propagation:

- Propagation defines what happens to a transaction when a transactional method is called by another transactional
  method.

| **Propagation Type**   | **Behavior**                                                                                 | **Typical Use Case**                                                                                |
|------------------------|----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| **REQUIRED (default)** | Joins an existing transaction if present; otherwise creates a new one                        | Most common scenario; ensures all operations run in a single atomic transaction                     |
| **REQUIRES_NEW**       | Suspends the current transaction and always starts a new one                                 | Logging, auditing, notifications, or operations that must commit even if the main transaction fails |
| **SUPPORTS**           | Joins an existing transaction if present; otherwise runs non-transactionally                 | Read-only operations that don’t strictly require a transaction                                      |
| **MANDATORY**          | Must run inside an existing transaction; throws an exception if none exists                  | Enforces strict transactional context for critical lower-level operations                           |
| **NOT_SUPPORTED**      | Suspends the current transaction and runs non-transactionally                                | Long-running tasks, external API calls, reporting, batch exports                                    |
| **NEVER**              | Must run outside of a transaction; throws an exception if a transaction exists               | Health checks, cache refresh, monitoring endpoints                                                  |
| **NESTED**             | Executes within a nested transaction using savepoints; rollback affects only the nested part | Complex operations where partial rollback is acceptable within the same database                    |

| Propagation   | Existing TX    | New TX    | Suspends TX | Failure Impact   |
|---------------|----------------|-----------|-------------|------------------|
| REQUIRED      | Join           | If none   | No          | Rollback whole   |
| REQUIRES_NEW  | Ignore         | Always    | Yes         | Isolated         |
| SUPPORTS      | Join           | No        | No          | Depends          |
| NOT_SUPPORTED | No             | No        | Yes         | No rollback      |
| MANDATORY     | Must exist     | No        | No          | Exception        |
| NEVER         | Must not exist | No        | No          | Exception        |
| NESTED        | Join           | Savepoint | No          | Partial rollback |

## Key Insights

- REQUIRED is the default and most widely used.
- REQUIRES_NEW is useful for independent tasks (e.g., sending emails, audit logs).
- NESTED requires a database that supports savepoints (like PostgreSQL, Oracle).
- MANDATORY and NEVER enforce strict rules about transaction presence.
- NOT_SUPPORTED and SUPPORTS are flexible for non-critical or read-only operations.

## Challenges

- Misusing propagation can lead to unexpected rollbacks or data inconsistencies.
- Nested transactions are not fully supported in all databases.
- REQUIRES_NEW can increase overhead since it suspends and starts new transactions