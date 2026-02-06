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

- Partitioning decides how events are distributed across brokers. In financial systems, wrong partitioning can break
  ordering guarantees and cause inconsistent balances. A good strategy ensures scalability, parallelism, and correctness
  of transaction flows.

## 2.2 How do you choose partition key for account-based events?

- Use the account number or customer ID as the partition key. This ensures all events for the same account go to the
  same partition, preserving order and consistency in transaction processing.

## 2.3 How does Kafka guarantee ordering within a partition?

- Kafka guarantees ordering by writing events to a partition in append-only logs. Consumers read sequentially, so events
  are delivered in the exact order they were produced within that partition.

## 2.4 What happens if account events go to different partitions?

- If events for the same account are spread across partitions, ordering breaks. This can lead to incorrect balances,
  double withdrawals, or inconsistent transaction histories.

## 2.5 How do you increase throughput without breaking ordering?

- You increase throughput by adding more partitions and distributing accounts across them. Ordering is preserved at the
  partition level by ensuring the same account always maps to the same partition key.

## 2.6 Can Kafka guarantee global ordering? Why not?

- No, Kafka cannot guarantee global ordering across partitions. Ordering is only guaranteed within a single partition.
  Global ordering would require a single partition, which kills scalability and throughput.

# 3. Producers – Reliability & Safety

## 3.1 How does Kafka producer ensure message durability?

- Kafka producers ensure durability by writing messages to broker logs on disk and replicating them across multiple
  brokers. Once acknowledged, the message is safely stored and can survive broker failures.

## 3.2 What is acks=all and why is it mandatory in banking?

- acks=all means the producer waits until all in-sync replicas confirm the write. In banking, this is mandatory to
  guarantee no data loss, ensuring every transaction is safely replicated before being acknowledged.

## 3.3 What happens if producer retries send after timeout?

- If a send times out, the producer retries automatically. This can cause duplicate messages if the original write
  actually succeeded but the acknowledgment was delayed. Hence, idempotence is critical.

## 3.4 How do idempotent producers prevent duplicate events?

- Idempotent producers assign a unique sequence number to each message. Kafka uses this to detect and discard
  duplicates, ensuring exactly-once delivery semantics at the producer level.

## 3.5 Why enable.idempotence=true is non-negotiable for money flows?

- In financial systems, duplicate events can mean double withdrawals or credits. Enabling idempotence ensures
  exactly-once delivery, making it non-negotiable for money flows where correctness is critical.

## 3.6 How do you handle producer backpressure during peak hours?

- Backpressure is handled by tuning producer configs like buffer.memory and max.in.flight.requests, batching messages,
  and scaling partitions. This ensures throughput is increased without overwhelming brokers.

# 4. Consumers & Consumer Groups

## 4.1 How does Kafka distribute load across consumers?

- Kafka distributes load by assigning partitions of a topic across consumers in a group. Each partition is consumed by
  only one consumer, ensuring parallelism and balanced workload distribution.

## 4.2 What happens when one consumer in group crashes?

- If a consumer crashes, the group coordinator detects missing heartbeats and triggers a rebalance. The crashed
  consumer’s partitions are reassigned to active consumers, ensuring no data loss but causing a brief pause.

## 4.2.1  How Kafka handles recovery when the crashed consumer comes back online?

- When the consumer rejoins, the coordinator includes it in the next rebalance. It gets new partition assignments and
  resumes consumption from the last committed offset, avoiding data loss but possibly reprocessing uncommitted events.

## 4.3 Why should banking consumers be slow and cautious?

- Banking consumers must process events carefully to ensure transaction integrity. Rushing can cause missed validations,
  duplicate processing, or incorrect balances. Slow, cautious consumption ensures accuracy over speed.

## 4.4 How do you scale consumers without reprocessing messages?

- You scale by adding more consumers to the group, which triggers a rebalance. Kafka ensures each partition is consumed
  by only one consumer, so scaling increases throughput without duplicating or reprocessing messages.

## 4.5 What is consumer lag and why must it be monitored?

- Consumer lag is the gap between the latest offset in a partition and the consumer’s committed offset. Monitoring lag
  is critical in banking to detect slow consumers, prevent backlog, and ensure timely transaction processing.

## 4.6 How do you handle poison messages?

- Poison messages are problematic events that repeatedly fail processing. They are handled by sending them to a Dead
  Letter Queue (DLQ), logging for investigation, and continuing normal flow to avoid blocking the consumer group.

# 5. Offset Management & Exactly-Once Semantics

## 5.1 When should offsets be committed manually?

- Offsets should be committed manually when you need control over message acknowledgment. In banking, this ensures
  offsets are only committed after successful DB writes, preventing data loss or inconsistent transaction states.

## 5.2 What happens if offset is committed before DB write?

- If the offset is committed before the DB write, a crash can cause the event to be skipped. This results in lost
  transactions, since Kafka thinks the message was processed even though the DB update never happened.

## 5.3 How does at-least-once cause double debit risk?

- At-least-once delivery retries failed messages. If a debit was written to the DB but the offset wasn’t committed,
  Kafka may reprocess the same event, leading to duplicate debits in financial systems.

## 5.4 How does Kafka provide exactly-once semantics?

- Kafka provides exactly-once semantics using idempotent producers + transactional APIs. Producers send messages with
  unique sequence numbers, and consumers commit offsets atomically with DB writes, ensuring no duplicates or losses.

## 5.5 Is exactly-once end-to-end achievable in banking?

- Exactly-once is achievable only if Kafka + DB + application logic all support atomic commits. In practice, it’s
  complex—banks often design idempotent transaction logic instead of relying solely on Kafka guarantees.

## 5.6 How do you combine DB transaction + Kafka offset safely?

- You use the transactional outbox pattern or Kafka’s consume-transform-produce with transactions. This ensures the DB
  write and offset commit happen in a single atomic unit, preventing both double processing and data loss.

# 6. Transactions in Kafka

## 6.1 Why Kafka transactions matter for banking?

## 6.2 How does transactional producer work?

## 6.3 What happens when transaction is aborted?

## 6.4 Kafka transaction vs database transaction – differences?

## 6.5 How do you publish multiple events atomically?

## 6.6 How does Kafka transaction timeout affect processing?

# 7. Error Handling & Retries

## 7.1 How do you handle temporary vs permanent failures?

## 7.2 Retry topic vs dead-letter topic – differences?

## 7.3 How do you prevent infinite retry loops?

## 7.4 How do you reprocess failed messages safely?

## 7.5 What should never be retried in banking?

## 7.6 How do you alert on repeated failures?

# 8. Idempotency & Deduplication

## 8.1 Why idempotency is mandatory for Kafka consumers?

## 8.2 How do you detect duplicate events?

## 8.3 Where should idempotency logic live – consumer or DB?

## 8.4 How do you use transactionId / businessId for dedupe?

## 8.5 How long should dedupe records be stored?

## 8.6 How do you handle duplicate replay during recovery?

# 9. Schema Management & Compatibility

## 9.1 Why schema evolution is risky in banking events?

## 9.2 How does Schema Registry help?

## 9.3 Backward vs forward compatibility – which is safer?

## 9.4 What happens if consumer cannot deserialize event?

## 9.5 How do you version event schemas safely?

## 9.6 JSON vs Avro vs Protobuf – banking tradeoffs?

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