# 1. Kafka Fundamentals in Banking

## 1.1 Why do banks prefer Kafka over REST for high-volume events?

- Banks prefer Kafka because it handles millions of events per second with low latency, unlike REST which struggles
  under heavy load. Kafka provides scalability, durability, and real-time streaming, ensuring reliable event
  delivery
  even during traffic spikes.

## 1.2 What problems does Kafka solve in transaction-heavy systems?

- Kafka solves issues of scalability, fault tolerance, and event ordering in transaction-heavy systems. It ensures
  exactly-once or at-least-once delivery, prevents data loss, and supports real-time monitoring of financial
  transactions.

## 1.3 Kafka vs MQ (RabbitMQ/ActiveMQ) – where does Kafka fit in banking?

- Traditional MQs are good for point-to-point messaging but struggle with scale. Kafka is designed for distributed,
  high-throughput event streaming, making it ideal for fraud detection, audit trails, and real-time analytics in
  banking.

## 1.4 Why Kafka is not a database and should not be treated as one?

- Kafka is a log-based event streaming platform, not a transactional store. It doesn’t support complex queries,
  indexing, or relational integrity. Treating it as a database can lead to misuse—it’s meant for data pipelines, not
  storage.

## 1.5 When should Kafka NOT be used in banking?

- Kafka should not be used for low-volume, simple request-response systems or where strict ACID guarantees are
  mandatory. It’s also unsuitable for long-term storage or small-scale applications where the overhead outweighs the
  benefits.

# 2. Topics, Partitions & Ordering

## 2.1 Why partitioning strategy is critical for financial transactions?

### A withdrawal and deposit for the same account are processed out of order, resulting in a negative balance. Why is partitioning strategy critical for financial transactions?

- Partitioning decides how events are distributed across brokers. In financial systems, wrong partitioning can break
  ordering guarantees and cause inconsistent balances. A good strategy ensures scalability, parallelism, and correctness
  of transaction flows.
- Kafka only guarantees ordering within a partition. If related events don’t land in the same partition, ordering is
  gone and consistency collapses.
- In finance, ordering is business logic, not a nice-to-have. A bad partitioning strategy means: i) Concurrent
  processing of related events ii) Race conditions across consumers iii) Incorrect balances with no technical errors
- If partitioning is wrong, no amount of retries, idempotency, or transactions will save you.

- Imagine millions of debit and credit events flowing through Kafka.
- Partitioning decides how events are distributed across brokers.
- Poor partitioning can scatter related account events, breaking ordering.
- In banking, this risks inconsistent balances.
- Correct partitioning ensures all events for an account go to the same partition.
- This guarantees ordering and consistency.
- Partitioning also impacts scalability and throughput.
- Without strategy, hotspots or uneven load occur.
- Banking systems demand predictable partitioning.
- It’s the foundation of reliable event-driven architecture.

## 2.2 How do you choose partition key for account-based events?

- Use the account number or customer ID as the partition key. This ensures all events for the same account go to the
  same partition, preserving order and consistency in transaction processing.
- Partition by account identifier — always.
- This guarantees: i)All events for an account go to the same partition ii) Sequential processing iii)Natural locking
  without distributed locks
- For transfers: i) Debit event → source account partition ii) Credit event → destination account partition
- Cross-account atomicity is a business workflow problem, not a Kafka problem. If you try to force it into partitioning,
  you’ll fail.

- Suppose you publish fund transfer events.
- Partition key must ensure all events for one account go to same partition.
- Use account number or customer ID as key.
- This guarantees ordering of debit/credit events.
- In banking, consistency of account state is critical.
- Random keys scatter events, breaking ordering.
- Partition key design balances load and correctness.
- Hashing ensures even distribution across partitions.
- Account-based keys prevent race conditions.
- Proper key choice ensures financial safety.
- It’s a design decision with compliance impact.

## 2.3 How does Kafka guarantee ordering within a partition?

- Kafka guarantees ordering by writing events to a partition in append-only logs. Consumers read sequentially, so events
  are delivered in the exact order they were produced within that partition.
- Kafka writes records to a partition as an append-only log.
- Each message gets: i) A monotonically increasing offset ii) Single-threaded write per partition leader
- Consumers read sequentially by offset. No parallelism within a partition.
- Ordering is a side effect of serialization, not magic. Break that, and ordering disappears.

- Imagine multiple debit events for Account A.
- Kafka appends events sequentially to partition log.
- Consumers read in same order.
- Ordering is guaranteed within partition.
- In banking, this ensures debits and credits apply correctly.
- Without ordering, balances could be wrong.
- Partition log acts like a ledger.
- Consumers rely on sequential offsets.
- Ordering is local to partition, not global.
- This makes Kafka safe for account-level workflows.

## 2.4 What happens if account events go to different partitions?

- If events for the same account are spread across partitions, ordering breaks. This can lead to incorrect balances,
  double withdrawals, or inconsistent transaction histories.
- You lose determinism.
- Symptoms: i) Out-of-order processing ii) Conflicting updates iii) Incorrect balances iv) Hard-to-reproduce bugs
- Kafka won’t warn you. Everything will look “healthy.”
- This is the worst failure mode — silent data corruption. If this happens in production, the design is already broken.

- Suppose debit and credit events for Account A go to different partitions.
- Ordering is lost across partitions.
- Debit may appear after credit to consumers.
- In banking, this corrupts balances.
- Customers may see incorrect transaction order.
- Compliance requires strict ordering.
- Partitioning must ensure account events stay together.
- Otherwise, reconciliation jobs fail.
- Cross-partition ordering is not guaranteed.
- This is a critical design flaw in financial systems.

## 2.5 How do you increase throughput without breaking ordering?

- You increase throughput by adding more partitions and distributing accounts across them. Ordering is preserved at the
  partition level by ensuring the same account always maps to the same partition key.
- You don’t parallelize within an account. That’s non-negotiable.
- Your options: i) Increase partitions across different accounts ii) Scale consumers horizontally iii) Reduce
  per-message processing time iv) Use batching
- If one account is too hot, that’s a business hotspot, not a Kafka problem. Sharding an account across partitions
  breaks correctness. Period.

- Imagine processing millions of salary credits.
- More partitions increase throughput.
- But ordering must be preserved per account.
- Use account number as partition key.
- This ensures ordering within partition while scaling.
- In banking, throughput must not compromise correctness.
- Parallelism is achieved across accounts, not within one.
- This balances performance and safety.
- Proper partitioning enables horizontal scaling.
- Banking systems rely on this balance.
- Throughput and ordering can coexist with careful design.

## 2.6 Can Kafka guarantee global ordering? Why not?

- No, Kafka cannot guarantee global ordering across partitions. Ordering is only guaranteed within a single partition.
  Global ordering would require a single partition, which kills scalability and throughput.
- No — and it never will.
- Global ordering requires: Single partition, Single leader, Single consumer.
- That kills throughput, availability, and scalability. Kafka is a distributed system — global ordering contradicts its
  design goals.
- If your business requires total ordering across all transactions, Kafka is not your solution. Use a database or a
  centralized ledger system.
- Forcing Kafka into this role leads to fragile systems and angry auditors.

- Suppose you want all banking events globally ordered.
- Kafka guarantees ordering only within a partition.
- Across partitions, events are independent.
- Global ordering would require single partition, killing scalability.
- In banking, global ordering is impractical.
- Instead, ordering is enforced per account or entity.
- This ensures correctness without bottlenecks.
- Global ordering conflicts with Kafka’s distributed design.
- Banking systems design around partition-level ordering.
- Global ordering is neither feasible nor necessary.
- Correct partitioning solves the problem.

# 3. Producers – Reliability & Safety

## 3.1 How does Kafka producer ensure message durability?

### A Kafka producer sends a payment event and receives success, but the message is missing after a broker crash. How does Kafka producer ensure message durability?

- Imagine publishing a debit event for a fund transfer.
- Kafka producer writes to broker logs on disk.
- Replication across brokers ensures durability.
- Producer waits for acknowledgments before confirming delivery.
- In banking, durability ensures no debit event is lost.
- Even if a broker crashes, replicas preserve the event.
- Kafka’s commit log guarantees persistence.
- Durability is critical for financial integrity.
- Without it, transactions could vanish mid-flight.
- Producer configs like acks=all enforce durability.
- This makes Kafka safe for banking workflows.

- Durability depends on replication + acknowledgements.
- A message is durable only after it is written to disk on multiple brokers, not just accepted by one leader.
- Kafka ensures durability when: Topic has replication factor ≥ 3, acks=all, Min ISR is enforced
- Leader waits for replicas to confirm write
- If you accept success before replicas persist the message, you’re lying to the business.
- Durability is not a default — it’s a configuration decision.

## 3.2 What is acks=all and why is it mandatory in banking?

### Why is acks=all mandatory in banking systems?

-
    - Suppose a salary credit event is published.
- acks=all means producer waits for all replicas to acknowledge.
- This ensures event durability across cluster.
- In banking, losing a salary credit event is unacceptable.
- acks=1 or acks=0 risks data loss.
- acks=all guarantees no event is lost even if leader crashes.
- It’s mandatory for financial transactions.
- Customers trust that credits are reliable.
- Compliance requires guaranteed delivery.
- acks=all is the safest choice for money flows.
- It’s non-negotiable in banking systems.
-
- With acks=all, the producer waits until all in-sync replicas acknowledge the write.
- If the leader crashes immediately after, a follower still has the data.
- Without acks=all, the leader can acknowledge before replication. If it dies, the message is gone forever.
- Banking systems don’t tolerate “probably delivered.” Either it’s committed safely or it didn’t happen. Anything else
  is negligence.

## 3.3 What happens if producer retries send after timeout?

### The producer times out while sending a message and retries. What happens?

- Imagine a debit event times out during send.
- Producer retries automatically.
- Without idempotence, duplicates may occur.
- In banking, duplicate debit events cause double charges.
- With idempotence enabled, retries are safe.
- Kafka ensures only one event is committed.
- Retries improve reliability under network issues.
- Timeout + retry must be tuned carefully.
- In banking, retries ensure resilience without duplication.
- Proper configs prevent financial errors.
- Safe retries are critical for trust.
-
- Kafka cannot know whether the first attempt actually succeeded or not.
- Without idempotence → duplicate messages
- With idempotence → Kafka detects retry using sequence numbers and discards duplicates
- Timeout + retry is normal in distributed systems. Assuming it won’t happen is amateur thinking. You must design for
  it, not hope it away.

## 3.4 How do idempotent producers prevent duplicate events?

### How do idempotent producers prevent duplicate events?

- Suppose producer retries a salary credit event.
- Without idempotence, multiple credits may occur.
- Idempotent producer assigns sequence numbers to events.
- Broker ensures duplicates are discarded.
- In banking, this prevents double credits.
- Idempotence guarantees exactly-once delivery.
- It’s essential for financial transactions.
- Customers must never see duplicate debits or credits.
- Idempotence makes retries safe.
- It’s a cornerstone of reliable event publishing.
- Banking systems rely heavily on this feature.
-
- Kafka assigns: Producer ID (PID),Sequence number per partition
- If the same message is retried, Kafka detects repeated sequence numbers and drops duplicates.
- This works only per partition and only for a single producer instance.
- Idempotence is not global deduplication. It’s precise, narrow, and intentional. Treating it as a magic shield is
  wrong.

## 3.5 Why enable.idempotence=true is non-negotiable for money flows?

### Money credited twice due to retry storm What could be the reason?

- Imagine fund transfer producer without idempotence.
- Network glitch causes duplicate debit events.
- Customer balance shows double deduction.
- In banking, this is catastrophic.
- enable.idempotence=true ensures duplicates are discarded.
- It guarantees exactly-once semantics.
- Without it, retries risk financial errors.
- Regulators demand strict consistency.
- Idempotence is mandatory for money flows.
- It’s not optional—it’s a compliance requirement.
- Safe transfers depend on it.

- Because retries are guaranteed to happen — network blips, GC pauses, broker throttling.
- Without idempotence: Same payment event can be written twice, Downstream systems may process it twice
- You now owe money to customers, Idempotence turns retries from a financial risk into a safe mechanism.
- If you disable it for “performance”, you’re trading correctness for speed — which is unacceptable in banking.

## 3.6 How do you handle producer backpressure during peak hours?

- Backpressure is handled by tuning producer configs like buffer.memory and max.in.flight.requests, batching messages,
  and scaling partitions. This ensures throughput is increased without overwhelming brokers.
- Suppose payroll service publishes 1M salary credits.
- Brokers may slow down under load.
- Producer experiences backpressure.
- Use batching to reduce round-trips.
- Tune linger.ms and batch.size for efficiency.
- Apply throttling to avoid overwhelming brokers.
- In banking, backpressure must not drop events.
- Retry with idempotence ensures safe delivery.
- Monitor broker health continuously.
- Backpressure handling ensures smooth peak-hour processing.
- It’s critical for large-scale salary credits.

- Backpressure is Kafka telling you the truth: the system is at capacity.
- Options: Increase linger + batch size, Enable compression, Scale partitions, Rate-limit upstream requests, Reject or
  queue non-critical requests
- Worst option: ignoring backpressure and increasing retries. That amplifies failure.
- In banking, slowing down is safer than corrupting data. Throughput comes second to correctness.

# 4. Consumers & Consumer Groups

## 4.1 How does Kafka distribute load across consumers?

- Kafka distributes load by assigning partitions of a topic across consumers in a group. Each partition is consumed by
  only one consumer, ensuring parallelism and balanced workload distribution.
- Kafka assigns partitions, not messages, to consumers in a group. Each partition is consumed by exactly one consumer at
  a time.
- Parallelism = number of partitions, not consumers.
- If you add consumers without adding partitions, you gain nothing. This is a common scaling illusion.

- Imagine transaction history service with multiple consumers.
- Kafka partitions topic data.
- Each consumer in group gets subset of partitions.
- Load is distributed evenly.
- In banking, this ensures scalability.
- Millions of transactions can be processed in parallel.
- Consumer groups balance workload automatically.
- This prevents bottlenecks.
- Distribution ensures high throughput.
- It’s the backbone of scalable banking systems.

## 4.2 What happens when one consumer in group crashes?

- If a consumer crashes, the group coordinator detects missing heartbeats and triggers a rebalance. The crashed
  consumer’s partitions are reassigned to active consumers, ensuring no data loss but causing a brief pause.
- If it stops polling within max.poll.interval.ms, Kafka considers it dead and triggers a rebalance.
- Its partitions are reassigned to other consumers.
- During rebalance: Consumption pauses, Throughput drops, If frequent → system instability
- This is why long processing inside poll loops is dangerous.

- Suppose one consumer processing debit events crashes.
- Kafka detects failure via heartbeat timeout.
- Partitions are reassigned to healthy consumers.
- Processing continues without interruption.
- In banking, this ensures no debit event is lost.
- Slow consumers also trigger rebalancing.
- This prevents lag buildup.
- Consumer group resilience ensures reliability.
- Failures are handled gracefully.
- Banking systems remain consistent under crashes.

## 4.2.1  How Kafka handles recovery when the crashed consumer comes back online?

- When the consumer rejoins, the coordinator includes it in the next rebalance. It gets new partition assignments and
  resumes consumption from the last committed offset, avoiding data loss but possibly reprocessing uncommitted events.
- The returning consumer rejoins the group and may trigger another rebalance.
- It resumes from the last committed offset, not where it crashed.
- If offsets were committed early → messages lost
- If committed late → messages reprocessed
- Kafka gives you control, but also responsibility. Pick your poison intentionally.

- Imagine consumer resumes after crash.
- Kafka reassigns partitions back to it.
- Consumer resumes from last committed offset.
- No events are lost or duplicated.
- In banking, this ensures continuity.
- Recovery is seamless and automatic.
- Consumers pick up where they left off.
- This guarantees reliability under failures.
- Banking systems depend on this resilience.
- Kafka ensures smooth recovery.

## 4.3 Why should banking consumers be slow and cautious?

- Banking consumers must process events carefully to ensure transaction integrity. Rushing can cause missed validations,
  duplicate processing, or incorrect balances. Slow, cautious consumption ensures accuracy over speed.
- Because speed amplifies mistakes.
- Consumers must: Validate schema, Check idempotency, Handle retries safely, Commit offsets only after durable
  processing.
- Fast consumers that commit early are silent data corruption machines.
- In banking, correctness beats throughput every single time.

- Suppose consumer processes debit events too fast.
- It may commit offsets before DB transaction completes.
- If DB fails, event is lost.
- Banking consumers must process cautiously.
- Commit offsets only after successful DB write.
- Slow but safe ensures financial integrity.
- Speed without safety risks double debits.
- Consumers must prioritize accuracy over throughput.
- In banking, cautious processing is mandatory.
- Reliability matters more than speed.

## 4.4 How do you scale consumers without reprocessing messages?

- You scale by adding more consumers to the group, which triggers a rebalance. Kafka ensures each partition is consumed
  by only one consumer, so scaling increases throughput without duplicating or reprocessing messages.
- You can’t avoid rebalances, but you can minimize reprocessing by:
- i) Committing offsets after processing
- ii) Using cooperative rebalancing
- iii) Avoiding long poll processing
- iv) Keeping consumer logic idempotent
- If reprocessing breaks your system, your system is fragile by design.

- Imagine scaling transaction consumers from 2 to 4.
- Kafka rebalances partitions across consumers.
- Each consumer gets unique partitions.
- No reprocessing occurs if offsets are managed.
- In banking, this ensures scalability without duplication.
- Consumers scale horizontally under load.
- Proper offset management prevents errors.
- Scaling is seamless and safe.
- Banking systems handle peak loads reliably.
- Kafka makes scaling efficient.

## 4.5 What is consumer lag and why must it be monitored?

- Consumer lag is the gap between the latest offset in a partition and the consumer’s committed offset. Monitoring lag
  is critical in banking to detect slow consumers, prevent backlog, and ensure timely transaction processing.
- Consumer lag = difference between latest offset and committed offset.
- High lag means: Consumers are slow, Downstream systems are overloaded, Failures are coming
- Lag is an early warning signal, not just a metric. In banking, rising lag often precedes outages and SLA breaches.

- Suppose consumer lags behind producer during peak hours.
- Lag = difference between latest offset and committed offset.
- High lag means consumers are falling behind.
- In banking, this delays transaction processing.
- Customers may see outdated balances.
- Monitoring lag ensures timely processing.
- Alerts trigger scaling or tuning.
- Lag must be minimized for SLA compliance.
- It’s a critical metric in banking systems.
- Lag monitoring ensures reliability.

## 4.6 How do you handle poison messages?

- Poison messages are problematic events that repeatedly fail processing. They are handled by sending them to a Dead
  Letter Queue (DLQ), logging for investigation, and continuing normal flow to avoid blocking the consumer group.
- Never let one message block a partition forever.
- Strategies: Retry with limits, Move to Dead Letter Topic, Alert + manual intervention, Skip after validation failure (
  with audit)
- Infinite retries are denial-of-service attacks you run on yourself. Poison messages must be isolated, not tolerated.

- Imagine a malformed transaction event.
- Consumer crashes repeatedly on same message.
- This is a poison message.
- Use dead-letter queues to isolate bad events.
- Skip or quarantine poison messages safely.
- In banking, poison messages must not block processing.
- DLQs allow investigation without halting system.
- Proper handling ensures resilience.
- Poison messages are logged for audit.
- Banking systems must handle them gracefully.
- This ensures continuous availability.

# 5. Offset Management & Exactly-Once Semantics

## 5.1 When should offsets be committed manually?

- Offsets should be committed manually when you need control over message acknowledgment. In banking, this ensures
  offsets are only committed after successful DB writes, preventing data loss or inconsistent transaction states.
- Only after the business side-effect is fully completed and durable — typically after the DB commit succeeds.
- Auto-commit is reckless in financial systems because Kafka may commit offsets before processing finishes.
- Manual commit gives you control over failure boundaries. If you can’t clearly point to the exact moment money becomes
  durable, you don’t know when to commit the offset.

- Imagine a consumer processing debit events.
- If offsets are auto-committed, they may advance before DB write completes.
- Manual commit ensures offsets move only after successful processing.
- In banking, this prevents losing debit events.
- Manual commit gives control over reliability.
- It ensures DB and Kafka stay consistent.
- Auto-commit is risky for financial workflows.
- Manual commit is safer for mission-critical transactions.
- It’s the standard for banking consumers.
- Reliability outweighs convenience here

## 5.2 What happens if offset is committed before DB write?

- If the offset is committed before the DB write, a crash can cause the event to be skipped. This results in lost
  transactions, since Kafka thinks the message was processed even though the DB update never happened.
- The message is lost forever.
- Kafka thinks it’s processed. Your DB says it never happened. There’s no retry, no replay, no warning.
- This is silent data loss — the worst kind.
- If this happens in banking, reconciliation will catch it days later, not your monitoring.

- Suppose consumer commits offset, then DB write fails.
- Kafka thinks event is processed.
- Consumer skips event on restart.
- Debit event is lost permanently.
- In banking, this causes missing transactions.
- Customers see incorrect balances.
- Compliance violations occur.
- Offset must be committed only after DB success.
- This ensures no event is lost.
- It’s a critical safeguard in financial systems.

## 5.3 How does at-least-once cause double debit risk?

- At-least-once delivery retries failed messages. If a debit was written to the DB but the offset wasn’t committed,
  Kafka may reprocess the same event, leading to duplicate debits in financial systems.
- At-least-once means Kafka may deliver the same message again if offset wasn’t committed yet.
- If the consumer: i) Writes to DB ii) Crashes before committing offset iii) Restarts and reprocesses the message
- You debit the account twice unless your DB logic is idempotent.
- Kafka did exactly what it promised. Your design failed.

- Imagine consumer retries debit event after crash.
- Event may be processed twice.
- Account balance shows double deduction.
- At-least-once delivery risks duplication.
- In banking, this is catastrophic.
- Customers lose money unfairly.
- Exactly-once semantics are required.
- At-least-once is unsafe for money flows.
- Duplication must be prevented.
- Banking systems cannot tolerate this risk.

## 5.4 How does Kafka provide exactly-once semantics?

- Kafka provides exactly-once semantics using idempotent producers + transactional APIs. Producers send messages with
  unique sequence numbers, and consumers commit offsets atomically with DB writes, ensuring no duplicates or losses.
- Kafka provides exactly-once only inside Kafka: i) Idempotent producers ii) Transactions iii) read_committed consumers
  iv) Atomic offset commits with produced records (Kafka Streams)
- This does not cover: i) Databases ii) REST calls iii)External systems
- Exactly-once is narrow, scoped, and conditional. Anyone claiming global exactly-once is overselling or
  misunderstanding.

- Suppose payroll service publishes salary credits.
- Kafka transactional producer + idempotent consumer ensures exactly-once.
- Producer commits offsets atomically with events.
- Consumers see only committed events.
- Retries don’t cause duplicates.
- In banking, this guarantees safe credits.
- Exactly-once semantics align with financial integrity.
- Kafka achieves this via transactions + idempotence.
- It’s the backbone of reliable event-driven banking.
- Customers trust balances remain correct.

## 5.5 Is exactly-once end-to-end achievable in banking?

- Exactly-once is achievable only if Kafka + DB + application logic all support atomic commits. In practice, it’s
  complex—banks often design idempotent transaction logic instead of relying solely on Kafka guarantees.
- No. And pretending otherwise is dishonest.
- Banking systems achieve effectively-once, not exactly-once: i) Idempotent writes ii) Deduplication keys iii)Business
  invariants iv)Reconciliation jobs
- Distributed systems cannot guarantee global exactly-once with failures. What they guarantee is detectable and
  correctable duplication. Auditors care about correctness, not theoretical purity.

- Imagine debit event processed by Kafka + DB.
- Kafka ensures exactly-once in messaging.
- DB ensures atomicity in storage.
- End-to-end requires integration of both.
- Use transactional outbox or dual-write patterns.
- In banking, end-to-end exactly-once is achievable but complex.
- Requires careful design and monitoring.
- Without it, duplication or loss occurs.
- Achieving it ensures compliance and trust.
- It’s mandatory for regulated financial systems.

## 5.6 How do you combine DB transaction + Kafka offset safely?

- You use the transactional outbox pattern or Kafka’s consume-transform-produce with transactions. This ensures the DB
  write and offset commit happen in a single atomic unit, preventing both double processing and data loss.
- There are only two sane patterns:
-
    1. Idempotent DB + At-least-once Kafka : i) Process message ii) DB enforces uniqueness (transaction ID, event ID)
       iii) Commit offset after DB commit, Duplicates become harmless.
-
    2. Transactional Outbox / Inbox : i) Store event or processing state in DB ii) Commit DB transaction iii) Publish or
       mark offset processed reliably
- Two-phase commit with Kafka is a trap. Avoid it.
- If your system cannot tolerate reprocessing, your system is brittle by design.

- Suppose consumer processes debit event and writes to DB.
- Must commit DB transaction and Kafka offset atomically.
- Use transactional outbox pattern: write event to DB, then publish.
- Or use sendOffsetsToTransaction() with Kafka producer.
- This ties DB commit with Kafka offset commit.
- In banking, this ensures no mismatch between DB and Kafka.
- Prevents lost or duplicated events.
- Guarantees consistency across systems.
- It’s the safest way to integrate DB + Kafka.
- Critical for fund transfers and salary credits.

# 6. Transactions in Kafka

## 6.1 Why Kafka transactions matter for banking?

### In a banking flow, an account is debited in the database, but the Kafka event that credits another system is never published due to a crash. Why do Kafka transactions matter here?

- Banking systems cannot tolerate “DB committed but event lost.”
- Without Kafka transactions, you’re relying on luck and retries.
- Kafka transactions allow you to atomically commit DB changes + Kafka messages (via outbox or transactional producer).
- Either the debit and the event both happen, or neither happens.
- This prevents ghost debits, reconciliation nightmares, and manual reversals.
- If your system can create money inconsistencies, it’s not a banking system — it’s a liability generator.
- Kafka transactions exist to close this exact consistency gap.

- Imagine a fund transfer event where Account A is debited and Account B is credited.
- If only the debit event is published, the system shows money deducted but not credited.
- Kafka transactions ensure both events are published atomically.
- This prevents partial updates in event-driven systems.
- In banking, atomicity is critical for financial integrity.
- Transactions guarantee “exactly-once” semantics.
- Without them, duplicate or missing events could cause financial loss.
- Kafka transactions align with ACID principles in distributed messaging.
- They protect against double debits or phantom credits.
- This makes Kafka safe for mission-critical banking workflows.

## 6.2 How does transactional producer work?

### A payment service retries sending events after failures and downstream systems receive duplicate transfer events. How does a transactional producer prevent this?

- A transactional producer combines idempotence + transaction markers.
- Each producer has a transactional.id. Kafka tracks sequence numbers per partition.
- If retries happen, Kafka discards duplicates.
- Messages are written in a pending state until commitTransaction() is called.
- Consumers configured with isolation.level=read_committed only see committed records.
- This guarantees exactly-once semantics per partition. Not magic — just strict bookkeeping.
- If you don’t use transactions, retries WILL create duplicates. And in banking, duplicates equal fraud alarms.

- Suppose payroll service publishes salary credits for 10,000 employees.
- A transactional producer starts a transaction with initTransactions().
- It groups multiple messages into one atomic unit.
- If all succeed, it commits; if any fail, it aborts.
- Consumers only see committed messages.
- In banking, this ensures no employee gets partial salary events.
- Producer uses sendOffsetsToTransaction() to commit offsets atomically.
- This ties event publishing with consumer progress.
- Transactional producer guarantees consistency across topics.
- It’s the backbone of reliable event-driven banking systems.

## 6.3 What happens when transaction is aborted?

### A producer sends multiple events in a transaction but crashes before commit. What happens to those events?

- They are aborted. Kafka writes an abort marker.
- Consumers with read_committed will never see those records.
- They physically exist in the log but are logically invisible.
- This is not rollback like a database — data isn’t erased, just marked invalid.
- If your consumers use read_uncommitted, congratulations — you just opted out of safety.
- That’s a conscious decision, not a Kafka problem.

- Imagine a loan disbursement event fails midway.
- Kafka aborts the transaction, discarding all uncommitted messages.
- Consumers never see partial events.
- In banking, this prevents half-completed disbursements.
- Aborted transactions ensure data consistency.
- They act like rollbacks in databases.
- This protects against corruption in event streams.
- Developers must handle retries gracefully.
- Aborted transactions are invisible to consumers.
- This guarantees atomicity in financial workflows.
- It’s a safety net for distributed event publishing.

## 6.4 Kafka transaction vs database transaction – differences?

### Developers assume Kafka transactions behave like DB transactions. Why is this assumption dangerous?

- Kafka transactions are log-level atomicity, not state-level isolation.
- Database transactions: Strong consistency, Locks / MVCC, Immediate visibility guarantees
- Kafka transactions: Atomic write to partitions, No locking across services, No global ordering, No rollback of side
  effects
- Kafka ensures message atomicity, not business atomicity.
- If you send a message and another system acts on it, Kafka cannot undo that action.
- If you expect DB-style rollback semantics, you’re designing fiction, not software.

- Suppose a fund transfer updates DB and publishes Kafka events.
- Data transaction ensures atomicity within topics.
- DB rollback doesn’t affect Kafka unless integrated.
- Kafka transactions are distributed across brokers.
- In banking, both must align for consistency.
- DB ensures balances are correct, Kafka ensures events are reliable.
- Together, they prevent mismatches between system state and event logs.
- Database = storage integrity, Kafka = messaging integrity.
- Both are needed for end-to-end financial safety.
- They complement each other, not replace.

## 6.5 How do you publish multiple events atomically?

### A banking service must publish multiple related events (OrderCreated, PaymentInitiated, LedgerUpdated). How can these be published atomically?

- Use a single transactional producer and publish all events within one Kafka transaction, then commit once.
- Constraints people ignore: i) All events must be sent by the same producer ii) They must be written to partitions that
  Kafka can track transactionally iii) Consumers must use read_committed
- If these events span multiple services, Kafka transactions alone are insufficient.
- You then need Saga + outbox. Kafka transactions don’t replace workflow orchestration.
- They only guarantee atomic writes — not atomic business processes.

- Imagine a transfer that requires debit event, credit event, and audit event.
- Kafka transactional producer groups all three into one transaction. Commit ensures all events appear together.
- Abort ensures none appear if one fails.
- In banking, this prevents missing audit trails.
- Atomic publishing guarantees consistency across topics.
- Consumers see a complete set of events or nothing.
- This avoids partial updates in distributed systems.
- It’s critical for compliance and fraud detection.
- Atomic publishing is the foundation of reliable event-driven banking.
- Kafka transactions make this possible.

## 6.6 How does Kafka transaction timeout affect processing?

### A producer takes too long between beginTransaction() and commitTransaction(). Suddenly transactions start failing. Why?

- Kafka enforces transaction.timeout.ms. If the producer exceeds it, the broker automatically aborts the transaction.
- This protects Kafka from zombie producers holding transactions forever.
- Common mistake: doing DB calls, REST calls, or heavy computation inside a Kafka transaction.
- Kafka transactions are meant to be short-lived. If your processing is slow, your design is wrong.
- Split compute from publish. Commit fast. Anything else leads to random aborts and invisible data loss.

- Suppose a payroll job starts a transaction but stalls.
- Kafka enforces a transaction timeout.
- If producer doesn’t commit within timeout, transaction aborts.
- Consumers never see incomplete salary events.
- In banking, this prevents stuck or hanging transactions.
- Timeout ensures system recovers automatically.
- But too short a timeout may abort valid long jobs.
- Too long a timeout risks resource locks.
- Proper tuning balances safety and performance.
- Timeout is a safeguard against stalled producers.
- It ensures reliability in high-volume banking systems.

# 7. Error Handling & Retries

## 7.1 How do you handle temporary vs permanent failures?

- You classify failures before retrying.
- Temporary (retryable) : Network timeouts, Broker unavailable, DB connection pool exhaustion
- Action: limited retries with backoff.
- Permanent (non-retryable) : Validation errors, Schema mismatch, Business rule violations (insufficient funds)
- Action: fail fast, route to DLQ, alert.
- Blind retries turn permanent failures into infinite loops. If you can’t classify failure types, retries are a bug, not
  a feature.

- Imagine a debit event fails due to a network glitch.
- Temporary failures (e.g., broker unavailable, DB timeout) should be retried.
- Permanent failures (e.g., invalid account number, schema violation) must not be retried.
- In banking, retrying permanent failures risks duplication or corruption.
- Temporary failures are transient and recoverable.
- Permanent failures require manual intervention or DLQ.
- Differentiating them ensures resilience without chaos.
- Banking systems must classify errors correctly.
- Retry only when recovery is possible.
- Permanent failures must be quarantined for audit.
- This distinction is critical for compliance.

## 7.2 Retry topic vs dead-letter topic – differences?

- Retry Topic:  Used for temporary failures, Message will be retried after a delay, Bounded retries
- Dead-Letter Topic (DLT) : Used for permanent failures, Message will never be retried automatically, Requires manual
  inspection or correction.
- Retry topics are for resilience.
- DLTs are for accountability.

- Suppose a salary credit event fails due to DB timeout.
- Retry topic reprocesses event after delay.
- Dead-letter topic stores unrecoverable events.
- Retry = temporary failures, DLQ = permanent failures.
- In banking, retry ensures resilience under transient issues.
- DLQ ensures bad events don’t block processing.
- Retry topics allow controlled reprocessing.
- DLQ provides audit trail for investigation.
- Both are essential for safe event handling.
- Proper routing prevents infinite loops.
- Banking systems rely on both strategies.

## 7.3 How do you prevent infinite retry loops?

- You enforce hard limits: Max retry count, Exponential backoff, Retry metadata in headers, Circuit breaker after
  threshold
- Infinite retries are denial-of-service attacks launched by your own code.
- In banking, retries must be boring, predictable, and finite.

- Imagine a malformed debit event keeps failing.
- Blind retries cause infinite loops.
- In banking, this blocks processing and risks duplication.
- Use retry limits (e.g., 3 attempts).
- After limit, move event to DLQ.
- This prevents system overload.
- Infinite loops can crash consumers.
- Banking systems must enforce retry caps.
- Retry policies balance resilience and safety.
- DLQ ensures bad events are isolated.
- Infinite retries are unacceptable in regulated systems.

## 7.4 How do you reprocess failed messages safely?

- Suppose debit events land in DLQ.
- Reprocessing must avoid duplication.
- Use idempotent consumers to ensure safe retries.
- Validate DB state before reapplying event.
- In banking, double debit must be prevented.
- Reprocessing requires careful audit.
- DLQ events must be reviewed before replay.
- Safe reprocessing ensures compliance.
- Automation must include safeguards.
- Banking systems must prioritize correctness over speed.
- Reprocessing is a controlled recovery process.

- Reprocessing must be: Manual or controlled, Idempotent, Auditable
- Process: Fix root cause, Replay from retry topic or DLT, Ensure deduplication keys are enforced, Track reprocessing
  outcome
- If reprocessing can double debit, your system is unsafe by design.

## 7.5 What should never be retried in banking?

- Imagine a debit event with invalid account number.
- Retrying won’t fix invalid data.
- In banking, retries must not apply to permanent errors.
- Examples: invalid schema, duplicate transaction ID, fraud detection failure.
- Retrying these risks corruption or fraud.
- Such events must go to DLQ immediately.
- Manual investigation is required.
- Banking systems must distinguish retryable vs non-retryable.
- Never retry events that violate business rules.
- Compliance demands strict error handling.
- Retrying permanent failures is dangerous.

- Never retry: Business validation failures (insufficient funds)
- Duplicate transaction IDs
- Fraud-flagged events
- Regulatory rule violations
- Retrying this doesn’t increase success — it increases risk.
- Some failures are final. Accept that.

## 7.6 How do you alert on repeated failures?

- Suppose debit events repeatedly fail due to DB outage.
- System must raise alerts after threshold.
- Alerts notify ops teams for intervention.
- In banking, repeated failures risk SLA breaches.
- Monitoring tools track retry counts and DLQ volume.
- Alerts ensure quick response to systemic issues.
- Without alerts, failures may go unnoticed.
- Banking systems must integrate monitoring + alerting.
- Repeated failures indicate deeper problems.
- Alerts protect against silent data loss.
- Compliance requires proactive failure detection.

- You alert on patterns, not single events:
- Retry count threshold breached, DLT growth rate, Same error across partitions, Consumer lag + retries correlation
- One failure is noise. Repeated failures are a signal.
- If alerts fire only after customers complain, monitoring is cosmetic.

# 8. Idempotency & Deduplication

## 8.1 Why idempotency is mandatory for Kafka consumers?

- Imagine a debit event being retried after a consumer crash.
- Without idempotency, the same debit could be applied twice.
- In banking, this causes double deductions from customer accounts.
- Idempotency ensures that processing the same event multiple times has no side effects.
- Consumers must check if the event was already applied before committing.
- This protects against retries, duplicates, and replay scenarios.
- Idempotency is the cornerstone of financial correctness.
- It guarantees resilience without risking duplication.
- Banking systems cannot tolerate non-idempotent consumers.
- Mandatory idempotency ensures trust and compliance.

- Because at-least-once delivery is the default reality.
- Consumers can crash after DB commit but before offset commit. Kafka will redeliver. That’s not a bug — that’s the
  contract.
- Without idempotency, retries and replays create double debit, double credit, and audit failures.
- Idempotency is the only line of defense between correct reprocessing and financial corruption.

## 8.2 How do you detect duplicate events?

- Suppose a salary credit event is retried due to timeout.
- Consumers must detect duplicates before applying.
- Use unique identifiers like transactionId or businessId.
- Store processed IDs in DB or cache.
- Check if ID already exists before applying.
- In banking, this prevents double credits.
- Deduplication ensures correctness under retries.
- Duplicates often arise from network glitches.
- Detection must be fast and reliable.
- Proper dedupe logic ensures financial safety.
- It’s a critical safeguard in event-driven banking.

- You detect duplicates using a stable, business-meaningful identifier: Transaction ID, Payment reference, Event ID
  generated at source
- Offsets don’t help. Timestamps don’t help. Payload equality doesn’t help.
- If the event does not carry a unique ID, it is not safe to consume.

## 8.3 Where should idempotency logic live – consumer or DB?

- Imagine debit events processed by consumer.
- Consumer-level dedupe checks prevent duplicate processing.
- DB-level dedupe ensures persistence layer rejects duplicates.
- In banking, DB is the ultimate source of truth.
- Idempotency logic should live in DB for safety.
- Consumer checks add efficiency but DB enforces correctness.
- Dual-layer dedupe is best practice.
- Consumer avoids unnecessary DB writes.
- DB ensures no duplicates slip through.
- Banking systems rely on DB-level guarantees.
- Idempotency must be enforced at persistence boundary.

- DB first. Always.
- In-memory dedupe: Dies on restart, Breaks on scale-out, Fails under rebalance
- The database is the only place that: Is durable, Is shared across instances, Can enforce uniqueness atomically
- Consumer-side checks are optimizations. DB-level constraints are guarantees.

## 8.4 How do you use transactionId / businessId for dedupe?

- Suppose fund transfer event has transactionId = TX123.
- Consumer checks if TX123 already exists in DB.
- If yes, skip processing.
- If no, apply debit/credit and store TX123.
- BusinessId ensures uniqueness across retries.
- In banking, transactionId is mandatory for dedupe.
- It prevents double debits or credits.
- Deduplication relies on consistent identifiers.
- Without IDs, duplicates cannot be detected.
- TransactionId is the backbone of idempotency.
- It’s a compliance requirement in financial systems.

- You treat it as a natural idempotency key: Store it in a table with a UNIQUE constraint
- Process event only if insert succeeds. If insert fails → duplicate → skip safely
- This turns duplicates into no-ops.
- If your DB schema doesn’t enforce uniqueness, idempotency is a suggestion, not a rule.

## 8.5 How long should dedupe records be stored?

- Imagine storing transaction IDs for dedupe.
- If stored too short, duplicates may slip through.
- If stored too long, storage overhead increases.
- In banking, retention depends on business rules.
- Typically, dedupe records are stored until reconciliation completes.
- For fund transfers, keep IDs for at least settlement window.
- For salary credits, keep until payroll cycle ends.
- Retention balances safety and efficiency.
- Regulators may mandate minimum retention.
- Deduplication records must align with compliance.
- Storage duration is a critical design choice.

## 8.6 How do you handle duplicate replay during recovery?

- Suppose consumer replays events after crash.
- Replay may include already processed events.
- Idempotency ensures duplicates are skipped.
- Consumer checks transactionId against DB.
- Only new events are applied.
- In banking, replay must not cause double debits.
- Recovery must be safe and consistent.
- Idempotency makes replay reliable.
- Without it, recovery risks corruption.
- Duplicate replay is common in distributed systems.
- Proper dedupe ensures resilience under recovery.

# 9. Schema Management & Compatibility

## 9.1 Why schema evolution is risky in banking events?

- Imagine a debit event schema changes field names.
- Old consumers may fail to deserialize.
- Debit events could be silently dropped.
- In banking, this means missing transactions.
- Schema evolution risks breaking compatibility.
- Customers may see incorrect balances.
- Regulators demand strict event integrity.
- Schema changes must be backward-compatible.
- Risk is high because financial events are mission-critical.
- Evolution must be carefully governed.

## 9.2 How does Schema Registry help?

- Suppose multiple services consume salary credit events.
- Schema Registry stores versions centrally.
- Producers and consumers validate compatibility.
- Prevents breaking changes in event formats.
- In banking, this ensures safe evolution of schemas.
- Registry enforces backward/forward rules.
- It acts as a contract between teams.
- Without it, schema drift causes outages.
- Registry makes event governance reliable.
- It’s essential for financial event pipelines.

## 9.3 Backward vs forward compatibility – which is safer?

- Imagine adding a new field “branchCode” to debit events.
- Backward compatibility: old consumers still work.
- Forward compatibility: new consumers can handle old events.
- In banking, backward compatibility is safer.
- Old consumers must never break.
- Forward compatibility is useful but less critical.
- Backward ensures historical events remain valid.
- Compliance requires old data to stay readable.
- Safer choice = backward compatibility.

## 9.4 What happens if consumer cannot deserialize event?

- Suppose consumer fails to parse debit event.
- Event is skipped or consumer crashes.
- In banking, this means lost transactions.
- Balances become inconsistent.
- Compliance violations occur.
- Consumers must handle deserialization errors gracefully.
- DLQ stores failed events for investigation.
- Schema Registry prevents such mismatches.
- Safe handling ensures no silent data loss.

## 9.5 How do you version event schemas safely?

- Imagine evolving salary credit schema.
- Use version numbers in schema registry.
- Add fields, never remove or rename.
- Maintain backward compatibility.
- Document schema changes clearly.
- In banking, versioning ensures auditability.
- Consumers can migrate gradually.
- Safe versioning avoids outages.
- Governance ensures compliance.

## 9.6 JSON vs Avro vs Protobuf – banking tradeoffs?

- JSON: human-readable, flexible, but heavy.
- Avro: compact, schema evolution support, widely used.
- Protobuf: efficient, strongly typed, but less flexible.
- In banking, Avro is preferred for schema evolution.
- JSON is good for external APIs.
- Protobuf suits high-performance internal pipelines.
- Tradeoff = readability vs efficiency vs governance.

# 10. Ordering & Consistency Guarantees

## 10.1 How do you ensure debit happens before credit?

## 10.2 What happens if consumer processes messages out of order?

## 10.3 How do you handle reordering during retries?

## 10.4 How do you replay events without breaking balances?

## 10.5 Can Kafka guarantee causal ordering?

## 10.6 How do you detect missing events?

# 11. Performance & Throughput

## 11.1 How do you tune Kafka for salary credit peak load?

## 11.2 Producer batching – risk vs reward?

## 11.3 Compression – when does it help?

## 11.4 How many partitions is too many?

## 11.5 How do you avoid broker overload?

## 11.6 How does disk I/O impact Kafka performance?

# 12. Security & Compliance

## 12.1 How do you secure Kafka with SSL/TLS?

## 12.2 SASL mechanisms – when to use which?

## 12.3 How do you restrict topic access per service?

## 12.4 How do you encrypt sensitive payloads?

## 12.5 How do you audit Kafka access?

## 12.6 How do you handle PII in Kafka topics?

# 13. Monitoring & Operations

## 13.1 What Kafka metrics are critical in banking?

## 13.2 How do you detect stuck consumers?

## 13.3 How do you monitor under-replicated partitions?

## 13.4 How do you perform broker rolling upgrades safely?

## 13.5 How do you handle disk full scenarios?

## 13.6 How do you plan capacity for growth?

# 14. Retention, Compaction & Replay

## 14.1 Retention vs compaction – differences?

## 14.2 When should you use log compaction?

## 14.3 How long should banking events be retained?

## 14.4 How do you replay events for reconciliation?

## 14.5 What happens when retention expires?

## 14.6 How do you handle GDPR deletion requests?

# 15. Kafka in Microservices Architecture

## 15.1 Event-driven vs REST – when to use which?

## 15.2 How do you avoid tight coupling via Kafka topics?

## 15.3 How do you name topics for clarity and governance?

## 15.4 One topic per service or per domain?

## 15.5 How do you handle cross-team topic ownership?

## 15.6 How do you manage backward compatibility across teams?

# 16. Real Banking Scenarios

## 16.1 Fund transfer – how do you design Kafka flow end-to-end?

## 16.2 Salary credit – how do you prevent double credits?

## 16.3 Fraud detection – how does Kafka enable real-time scoring?

## 16.4 Reconciliation – how do you rebuild state from events?

## 16.5 How do you handle partial failures in event chains?

# 17. Testing Kafka in Banking

## 17.1 How do you unit test Kafka producers?

## 17.2 How do you test consumers idempotency?

## 17.3 Embedded Kafka vs Testcontainers – which is safer?

## 17.4 How do you simulate broker failure?

## 17.5 How do you test replay and recovery?

# 18. Anti-Patterns & Failure Stories

## 18.1 Kafka used as request-response system – what went wrong?

## 18.2 Missing idempotency caused duplicate payouts – how?

## 18.3 Poor partition key design broke ordering – impact?

## 18.4 Auto-commit offsets caused data loss – explain.

## 18.5 Retention misconfiguration wiped audit data – lessons?