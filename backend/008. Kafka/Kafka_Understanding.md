#### Throughput

- Throughput is the number of messages a system can process per second end-to-end — from producers → brokers →
  consumers.
    - It tells you how much data Kafka can handle, not how fast an individual message is processed.
    - If Kafka processes 10,000 messages/sec, that’s throughput. It includes: Producer send rate, Broker handling
      capacity,
      Consumer processing rate
    - So it’s a system-wide capacity metric, not just one component.

- Increase throughput usually increases latency. In Kafka: Messages/sec a topic or consumer group can handle

##### What goes wrong if throughput is low?

- Producers start queueing → producer buffer full → orders get rejected or delayed
- Consumers can’t keep up → lag explodes → customers see “Payment failed” even when money was deducted
- Brokers start throttling → CPU/disk on fire → entire cluster slows down

#### Latency

- Latency is the time taken for a message to travel end-to-end — from producer send → broker → consumer receive (and
  optionally process).
- It tells you how fast a single message is delivered, not how many messages the system can handle.
- If a message takes 20 ms from producer to consumer → that’s latency. It includes: Network delay, Broker write/read
  time, Consumer fetch time.
- This is a per-message delay metric, unlike throughput (which is per second volume)
- Latency is the time taken for a message to travel from producer to consumer, measuring how quickly a single message is
  delivered through the system. It is critical for real-time applications where immediate response is required.
- Payments → low latency required
- Analytics → latency less important.

##### What goes wrong?

If you tune Kafka for max throughput (big batches, high linger), your payment event takes 2–3 seconds → customer thinks
payment failed → double charges → angry calls to support.

##### How real teams solve it:

Separate topics: payment-events (low latency) vs user-activity (high throughput)
Payment producer: linger.ms=0, batch.size=1k, acks=1
Analytics consumer: max.poll.records=1000

#### Availability

- Availability ensures cluster uptime despite failures via replication and failover.
- System is up and serving requests.
- Brokers + replication ensure availability. 1 broker down → system still works

##### Without good availability:

- All producers start getting errors → no more ride requests processed
- Customers see “Something went wrong” → they switch to competitor
- With proper Kafka setup (what actually happens in production):
- Replication Factor = 3
- One broker dies → other two have full copy
- Leader election happens in < 5 seconds
- No messages lost, no downtime visible to users
- You just see in logs: “Broker 2 down → new leader elected for partition 5”
- Spring Boot tip: Always set
- min.insync.replicas=2 + unclean.leader.election.enable=false

#### Scalability

- Scalability allows horizontal growth by adding brokers and partitions to handle more load without redesign.
- Ability to handle increased load by adding resources.
- In Kafka: Add partitions → more consumers → more parallelism. Scalability is limited by number of partitions.

##### Vertical scaling (wrong way):

- You keep adding CPU/RAM to existing 3 brokers → hits limit → expensive machines → still crashes on peak.

##### Horizontal scaling (Kafka way — correct):

- Add 2 more brokers (cheap VMs)
- Increase partitions from 8 → 24 on order-events topic
- Deploy 3 more consumer pods of your Spring Boot service
- Kafka automatically rebalances → now 24 consumers working in parallel → handles 3x load with zero code change.
- Important catch: You can only scale up to number of partitions. That’s why smart engineers start with 12–16 partitions
  even if today they need only 3.

#### Replication

- Replication duplicates partition data across brokers for redundancy and balanced scaling.
- Copies of data across brokers.
- In Kafka: Leader + followers. Prevent data loss. Enable failover

##### Without replication:

- Some transactions disappear → money lost → RBI calls → company in deep trouble

##### With replication (what actually saves you):

- Every partition has 3 copies (Leader + 2 Followers)
- Producer waits till at least 2 brokers confirm write (acks=all, min.insync.replicas=2)
- When broker dies → follower instantly becomes leader → zero data loss

| Goal              | Configuration                                                              | Use Cases            | Reality Check                                                          |
|-------------------|----------------------------------------------------------------------------|----------------------|------------------------------------------------------------------------|
| High Throughput   | Large batches + lz4 + acks=1                                               | Analytics, Logs      | Fast but risk of data loss if broker crashes before replication        |
| Low Latency       | linger.ms=0 + small batch + acks=1                                         | Notifications        | Good for speed, but inefficient and still unsafe for critical data     |
| High Availability | replication.factor=3, min.insync.replicas=2, unclean.leader.election=false | Payments, Orders     | Correct approach for critical systems; ensures durability and failover |
| Easy Scaling      | 12–24 partitions + more brokers/consumer pods                              | Growing applications | Over-partitioning increases rebalance time and broker overhead         |

## Data Safety and Guarantees

#### Durability

- Data is not lost after being written. Durability persists messages durably once acknowledged, preventing loss via
  commit logs.
- In Kafka, data is stored on disk and replicated across brokers
- Config drivers: acks=all, replication factor

##### How Kafka delivers durability (the chain that saves you):

- Message written to leader's disk (commit log — append-only file)
- Replicated to followers
- Producer gets ack only after configured replicas confirm

##### Key configs that control it:

- acks=all → wait for all in-sync replicas (not just leader)
- replication.factor=3 → 3 copies total
- min.insync.replicas=2 → must have at least 2 live copies before saying “success”
- You set acks=all + min.insync.replicas=2
- One broker dies during peak → still 2 copies alive → write succeeds → payment event safe
- If two brokers die → write fails (NOT_ENOUGH_REPLICAS) → producer retries or errors out → no silent loss

#### Reliability

- Reliability maintains consistent delivery through configs like acks=all and min.insync.replicas.
- System behaves correctly under failures.
- Includes: No data loss, Proper retries, Consistent processing.
- Difference: Durability = data survives, Reliability = system behaves correctly

| Aspect                        | Durability                                                      | Reliability                                                             |
|-------------------------------|-----------------------------------------------------------------|-------------------------------------------------------------------------|
| Focus                         | “Is the data still there after a crash?”                        | “Does the whole pipeline behave correctly under failures?”              |
| Main concern                  | Data loss                                                       | Duplicates, ordering violations, inconsistent state                     |
| Kafka helps with              | acks=all + replication.factor + min.insync.replicas             | Idempotent producers + retries + transactions + correct consumer logic  |
| What Kafka guarantees         | Message is safely stored (if configured correctly)              | Delivery (at-least-once / at-most-once / exactly-once with constraints) |
| What Kafka does NOT guarantee | Business correctness                                            | No duplicates or correct processing (that’s your responsibility)        |
| Real failure mode             | Message lost after broker crash (e.g., acks=1, low replication) | Message processed twice → double charge / inconsistent state            |
| Your responsibility           | Configure brokers & producers properly                          | Design idempotent consumers + handle retries + manage offsets correctly |

##### Perfect Durabilty with No Reliability

- You have perfect durability (message never lost), but poor reliability:
- Producer retry → duplicate write (without idempotence)
- Consumer crash after DB write but before commit offset → reprocess → double inventory deduction

##### Good Reliability

- Enable producer idempotence
- Use manual offset commit after successful business action
- Make consumers idempotent (check unique event ID)
- Add DLQ for poison messages
- Use transactions if DB + Kafka must be atomic

#### Idempotency

- Idempotency prevents duplicates via unique producer IDs and sequence numbers in transactions.
- Same operation executed multiple times → same result.
- In Kafka: Producer idempotence avoids duplicate writes, Consumer idempotency avoids duplicate processing.
- Duplicate Messages arise from retries or at-least-once semantics, mitigated by idempotency.
- Same message delivered more than once.Happens due to: retries, consumer crash, rebalancing
- Reality: Kafka guarantees at-least-once, not exactly-once (by default)

- Network glitch → broker wrote it but ack lost → producer retries → now two identical events in Kafka.
  Inventory consumer sees both → deducts stock twice → “out of stock” even when only one order.
  Or worse: payment processor charges twice → angry customer tweet.

##### Where duplicates come from (very common causes):

- Producer retry (network blip, broker timeout)
- Consumer crash after processing but before offset commit
- Rebalance during long poll → same message re-delivered

##### Producer-side idempotence (prevents duplicate writes to Kafka)

- Set enable.idempotence=true (in Spring: spring.kafka.producer.enable-idempotence: true)
- Kafka gives producer a unique Producer ID (PID) + auto-incrementing sequence number per partition
- Broker remembers last seen (PID, seq) → if retry with same seq → rejects duplicate
- Result: Even if producer retries 100 times → only one copy in topic

##### Consumer-side idempotency (prevents duplicate processing / side effects)

- Kafka alone cannot do this
- Every event has unique eventId / transactionId / UUID
- Before processing: SELECT 1 FROM processed_events WHERE id = ?
- If exists → skip (already done)
- Else → process + INSERT id
- Or use Redis / DB with unique constraint on eventId

| Concept     | What it protects against                    | Kafka config / feature                                                         | Real-world must-have?               | Spring Boot tip                                              |
|-------------|---------------------------------------------|--------------------------------------------------------------------------------|-------------------------------------|--------------------------------------------------------------|
| Durability  | Data loss on broker crashes                 | acks=all + replication.factor=3 + min.insync.replicas=2                        | Yes — always for business data      | Never use acks=0 or acks=1 for critical systems              |
| Reliability | Wrong behavior (duplicates, loss, ordering) | Durability configs + idempotent producer + retries + proper offset management  | Yes — ultimate goal                 | Use manual ack + commit AFTER DB success                     |
| Idempotency | Duplicate processing (retries, crashes)     | Producer: enable.idempotence=true<br>Consumer: application-level deduplication | Yes — mandatory for payments/orders | Store unique eventId/transactionId with DB UNIQUE constraint |

## Operational Metrics

#### Consumer Lag

- Consumer Lag tracks unprocessed messages, signaling overload or slow consumers.
- Difference between:Latest offset - Consumer offset. How far consumer is behind
- High lag = your system is failing to keep up

##### What lag really tells you:

- Lag = latest offset − consumer's current offset
- High lag → consumers too slow (slow DB writes, heavy logic, GC pauses, under-scaled pods) or dead.

##### How teams fix it (practical steps):

- Monitor lag with Prometheus + Grafana (alert if > 10,000 or growing > 1k/sec)
- Scale consumers horizontally (more pods)
- Optimize processing (batch DB inserts, async heavy work)
- Fix root causes: GC tuning, more CPU/memory, reduce max.poll.records if single message is slow

#### Back-Pressure

- System slows down producers when consumers can’t keep up
- Back Pressure occurs when consumers can't keep up, managed via buffer limits and scaling.
- In Kafka: Not automatic like some systems, You must handle it (rate limiting, scaling consumers)
- Kafka does NOT have built-in back-pressure like RabbitMQ or reactive streams.
- It happily lets producers fill topics forever.

##### What happens without handling:

- Consumers pause polling (or get kicked out → rebalance storm)
- Lag → infinite growth
- Downstream DBs overload → timeouts everywhere

##### How real Spring Boot teams handle it (2026 patterns):

- Application-level back-pressure: Use bounded queues / thread pools in consumers → when full, pause Kafka polling (
  consumer.pause() partitions) → resume when queue drains
- Rate-limit producers (e.g., Resilience4j RateLimiter around KafkaTemplate.send())
- Scale consumers aggressively (KEDA / HPA based on lag metrics)
- Lower max.poll.records (e.g. 50 instead of 500) → smaller batches → faster cycles → less overload per poll
- Hand off heavy work to separate thread pools + manual ack only after success

#### Processing Time

- Time taken by consumer to process one message. High processing time → increases lag
- Includes: DB calls, API calls, business logic.
- Processing Time measures per-message handling duration, impacting lag and throughput.

##### What high processing time causes:

- Fewer messages processed per poll → lag grows
- Higher chance of hitting max.poll.interval.ms → consumer marked dead → rebalance → duplicates

##### How teams keep it under control:

- Measure per-message time (Micrometer @Timed on listener method)
- Offload slow parts (email → async queue, heavy computation → separate worker)
- Use batch processing where possible
- Set realistic max.poll.interval.ms = 5–10× average processing time
- Alert on p95/p99 processing time > 2 seconds
-

I Wanted to learn in depth about Kafka
Producers - Sending Messages
Consumers - Read Messagings
topics - Event Streaming
partitions - Parallel Processing
offsets - resume from where left
Broker - Stores Data
Consumer Groups - Load Balancing
Producer → Controls durability, partitioning, retries
Consumer → Controls processing, offset commit, failure handling
Topic → Distributed append-only log
Partition → Unit of ordering + scalability
Offset → Consumer’s position pointer, not just resume
Replication : Data copies
Zookeeper - Cluster Managers
High Availability - Fault Tolerance.
High Throughput configuration
High Latency configuration
Which is best for Java Springboot Microservice projects

Explain clearly.

Thought for 19s
Kafka Architecture. In my previous article, we talked about… | by Emre Akın | Medium
medium.com
Apache Kafka: A Deep Dive into Its Architecture and Workflow | by Aniket Sharma | Medium
medium.com

Apache Kafka is a distributed event streaming platform that handles massive volumes of real-time data with high
throughput, durability, scalability, and fault tolerance. It acts like a highly reliable, append-only commit log that
thousands of microservices, data pipelines, and analytics systems rely on daily.

Below is a clear, structured, in-depth explanation matching exactly what you asked for.

1. Producers – Sending Messages
   Producers are client applications (your Spring Boot services) that publish records to Kafka topics.
   They handle serialization, batching, compression, partitioning, and retries automatically.

3 Kafka Messaging Strategies - by Saurabh Dashora
newsletter.systemdesigncodex.com
3 Kafka Messaging Strategies - by Saurabh Dashora

Key Producer Controls (you mentioned):

Durability → acks=0 (fire-and-forget, fastest), acks=1 (leader only), acks=all (leader + all in-sync replicas — safest)
Partitioning → Use message key → same key always goes to same partition (ordering guarantee). Or custom partitioner.
Retries → retries (or better: delivery.timeout.ms), retry.backoff.ms, max.in.flight.requests.per.connection=1 (to keep
ordering)

2. Consumers – Reading Messages
   Consumers pull records from topics (pull model = better back-pressure control).
   They process messages and decide when to mark them as “done”.

Key Consumer Controls:

Processing → Your business logic inside @KafkaListener or ConsumerRecord
Offset Commit → enable.auto.commit=true (simple but risk of duplicates) or manual (commitSync/commitAsync after
successful processing)
Failure Handling → Use SeekToCurrentErrorHandler / DeadLetterPublishingRecoverer + retry topics + DLQ (Dead Letter
Queue)

3. Topics – Event Streaming
   A topic is a logical category/folder for events (e.g., order-created, payment-processed).
   It is a distributed, append-only, immutable log — once written, data is never changed or deleted (only retained for a
   configurable time or size).

4. Partitions – Parallel Processing + Ordering
   Each topic is split into partitions (like shards).

Unit of ordering: Messages inside one partition are strictly ordered.
Unit of scalability & parallelism: More partitions = more consumers can read in parallel.
Understanding Kafka Partitioning Strategy - Scaler Topics
scaler.com
Kafka Topic Architecture - Replication, Failover, and Parallel Processing
dzone.com

Rule of thumb for Spring Boot microservices: Start with 6–12 partitions per topic (easy to increase later).

5. Offsets – Consumer’s Position Pointer
   Every message in a partition gets a unique, monotonically increasing offset (like a line number in a log file).
   The consumer records its last successfully processed offset → this is how it resumes exactly where it left off after
   restart or rebalance.

Kafka Consumer - Committing consumer group offset
codingharbour.com
Kafka Consumers - IBM Automation - Event-driven Solution - Sharing knowledge
ibm-cloud-architecture.github.io

6. Broker – Stores Data
   A broker is a Kafka server. It stores partition logs on disk, serves producers & consumers, and handles replication.

A Kafka cluster usually has 3–9+ brokers.

7. Consumer Groups – Load Balancing
   Multiple consumer instances that share the same group.id form a Consumer Group.
   Kafka automatically assigns partitions to consumers (one consumer per partition max).
   When a consumer dies or joins → rebalance happens automatically.

Kafka Load Balancing at Agoda for Terabytes of Data
newsletter.systemdesigncodex.com
Kafka Consumer Architecture - Consumer Groups and Subscriptions
dzone.com

Benefit in microservices: Horizontal scaling = just add more pod replicas → Kafka rebalances load instantly.

Replication: Data Copies (Fault Tolerance)
Every partition has a replication factor (RF), usually 3.

One leader (handles all read/write)
Others = followers (replicas)
Only In-Sync Replicas (ISR) can become leader.
This gives High Availability + Fault Tolerance — you can lose 1–2 brokers and still keep going without data loss.

Zookeeper → Cluster Manager (Important Update 2026)
Old way: ZooKeeper managed metadata, broker registration, leader election.
New way (Kafka 3.3+ production-ready, Kafka 4.0+ ONLY mode): KRaft (Kafka Raft) — everything inside Kafka brokers. No
separate ZooKeeper cluster needed anymore! Simpler ops, faster metadata, higher partition limits.

In 2026 production projects → always use KRaft mode.

High Availability & Fault Tolerance Summary
Replication Factor = 3
min.insync.replicas=2
unclean.leader.election.enable=false (never lose data)
Automatic leader election + rack-aware placement
Configuration: High Throughput vs Low Latency
Goal Producer Settings Broker / Topic Settings Consumer Settings Trade-off
High Throughput batch.size=100000–200000
linger.ms=10–100
compression.type=lz4
acks=1
retries=high More partitions (12+)
SSD disks
num.io.threads=16+ fetch.max.bytes=5MB
max.poll.records=500 Slightly higher latency
Low Latency linger.ms=0
batch.size=16384
acks=1 Fewer partitions if ordering critical
High network threads max.poll.interval.ms=300000 (long processing)    Lower throughput, more network calls
Most Spring Boot microservices choose the middle: acks=all, linger.ms=5, lz4 compression, RF=3 → excellent balance.

Which is BEST for Java Spring Boot Microservice Projects?
Spring for Apache Kafka (spring-kafka) is the gold standard in 2026.

Recommended Setup (Best Practices):

Dependency: spring-boot-starter + spring-kafka
Producer → KafkaTemplate<String, YourEvent> + @KafkaListener on consumer side
Use @EnableKafka + ConcurrentKafkaListenerContainerFactory with concurrency=6 (matches partitions)
application.yml example:
spring:
kafka:
bootstrap-servers: kafka-0:9092,kafka-1:9092,kafka-2:9092
producer:
key-serializer: org.apache.kafka.common.serialization.StringSerializer
value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
acks: all
retries: 10
batch-size: 16384
linger: 5
consumer:
group-id: order-service-group
auto-offset-reset: earliest
enable-auto-commit: false # manual control is safer
max-poll-records: 200
Extra best practices:
Enable idempotent producer (enable.idempotence=true)
Use Spring Retry + Dead Letter Topic pattern
Monitor with Micrometer + Prometheus (Kafka metrics)
Containerized with Kubernetes + Strimzi or Confluent Operator
This setup gives you decoupled, scalable, resilient, observable event-driven microservices — exactly what modern
Java/Spring Boot teams love.

You now have a complete mental model + production-ready configuration guidance.

If you want actual Spring Boot code snippets, Docker Compose + KRaft, exactly how to implement retry + DLQ, or a diagram
for your specific use-case, just say the word and I’ll generate it instantly! 🚀

1.1s
Web page favicon
Web page favicon
Web page favicon
85 sources
Rebalancing → major cause of duplicates
Offset management → core to correctness
Partition strategy → controls ordering + scaling
Delivery semantics (at-least-once etc.)
Here’s a clear, focused explanation of the four points you listed — all critical for building reliable Spring Boot +
Kafka microservices.

1. Rebalancing → Major Cause of Duplicates
   Rebalancing happens when:

Consumer joins/leaves group (scale up/down, pod restart, deployment)
Consumer is considered dead (session.timeout.ms or max.poll.interval.ms exceeded)
Topic metadata changes (new partitions added)
During eager rebalance (default until ~Kafka 2.3, still possible):

All consumers stop consuming
Partitions are revoked from everyone
New assignment is calculated
Consumers get new partitions → resume from last committed offset
Why duplicates appear:

Consumer A was processing messages 100–150 → processed 120 but crash/rebalance before commit
After rebalance → partition goes to Consumer B → starts from committed offset 100 → reprocesses 100–119 (duplicates)
Even with cooperative rebalance (incremental), duplicates can still occur if commit fails during revocation or if
processing continues too long.

Real-world numbers (from production reports):

Short rebalances → 5–40% duplicate rate possible in bad cases
Very common in Kubernetes auto-scaling (HPA/KEDA)
How to minimize / handle in Spring Boot projects (2026 best practices):

Approach Duplicate Risk When to Use Spring Kafka Config / Pattern
Idempotent processing Very low Almost always (recommended default)    Business logic checks unique ID / event ID /
transaction ID
CooperativeStickyAssignor Lower Default in recent spring-kafka
partition.assignment.strategy=org.apache.kafka.clients.consumer.CooperativeStickyAssignor
Manual commit + after successful processing Medium–low Need strong at-least-once AckMode.MANUAL_IMMEDIATE or MANUAL +
Acknowledgment.acknowledge()
Dead Letter Queue + retries Handles duplicates downstream High reliability needed DeadLetterPublishingRecoverer +
retryable topics
Increase max.poll.interval.ms Fewer rebalances Long processing time 10–30 minutes if batch or heavy work
Static membership (group.instance.id)    Much fewer rebalances StatefulSet / stable pods
group.instance.id=order-service-1
Most common realistic combo in Spring Boot microservices 2026:

CooperativeStickyAssignor
Idempotent consumer logic
Manual acks after successful business action
DLQ for poison messages

2. Offset Management → Core to Correctness
   Offsets are not just "resume point" — they define exactly-once / at-least-once / at-most-once boundary.

Commit Timing Semantics Duplicate Risk Loss Risk Use-case fit (Spring Boot)
Before processing At-most-once None High Metrics, non-critical logs (speed > correctness)
After successful processing At-least-once Possible None Orders, payments, most business events
Using transactions Exactly-once None None Kafka Streams, or Kafka → DB atomic writes
Spring Kafka offset strategies:

AckMode.AUTO / AUTO_IMMEDIATE → auto commit (dangerous in production — periodic commit → duplicates on rebalance/crash)
AckMode.MANUAL → you call ack.acknowledge() — most popular safe choice
AckMode.MANUAL_IMMEDIATE → commit after each message (safer but slower)
AckMode.RECORD / BATCH (with manual) → commit per record or whole poll batch
Best practice pattern 2026:

@KafkaListener(..., containerFactory = "manualAckFactory")
public void onEvent(YourEvent event, Acknowledgment ack) {
try {
process(event); // your business logic (idempotent!)
ack.acknowledge(); // only here → at-least-once
} catch (RecoverableException e) {
throw e; // → retry mechanism
} catch (Exception e) {
// log + send to DLQ or retry topic
ack.acknowledge(); // or nack() depending on design
}
}

3. Partition Strategy → Controls Ordering + Scaling
   Key trade-off table:

Strategy Ordering Guarantee Rebalance Disruption Scaling (parallelism)    Best for Spring Boot use-case
RangeAssignor (old default)    Good within partition High (eager)    Good Simple, small groups
StickyAssignor Good within partition Medium Good General purpose (older clusters)
CooperativeStickyAssignor Good within partition Low (incremental)    Good Default & recommended 2024+ — microservices
Ordering reality:

Kafka guarantees strict order only inside one partition
If you need total order → 1 partition (bad for scale)
If you need partial order (per user / per order-id) → key your messages → same key → same partition
Spring Boot recommendation:

spring.kafka.consumer.partition-assignment-strategy=org.apache.kafka.clients.consumer.CooperativeStickyAssignor
→ Minimal stop-the-world during scale / failure

Number of partitions:

Start 8–16 for medium traffic microservice
Increase only when you need more consumer parallelism (never decrease!)

4. Delivery Semantics (at-least-once etc.)
   Summary — what actually happens in practice:

Guarantee Producer side Consumer side End-to-end result (with failures/rebalances)    Performance Spring Boot fit (most
teams)
At-most-once acks=0, retries=0 Commit before process May lose messages Highest Rare (telemetry only)
At-least-once acks=1 or all + retries > 0 Commit after successful process No loss, possible duplicates High Most common
choice
Exactly-once idempotence + transactions Isolation level + consume-process-produce Exactly once (very strong)
Medium–low Kafka Streams or critical sinks
In plain Spring Kafka consumers (not Streams) → exactly-once is hard / partial:

You can get exactly-once processing only if:
Producer is idempotent + transactional
You use ChainedKafkaTransactionManager (Kafka + DB)
Or consume → process → produce in one transaction
Most Java microservices choose:

At-least-once delivery + idempotent consumer + DLQ
→ Very good balance of reliability, simplicity, and performance
If something is still unclear (e.g. code for CooperativeSticky + manual ack + idempotency check, or when to really use
transactions), tell me which part you want to zoom in on!

1.9s
Web page favicon
Web page favicon
Web page favicon
30 sources

#### Throughput

- Throughput is number of messages processed per second.
- Throughput measures messages processed per second across producers, brokers, and consumers, vital for high-volume
  streaming.
- Increase throughput usually increases latency. In Kafka: Messages/sec a topic or consumer group can handle

#### Latency

- Latency is end-to-end delay from producer send to consumer receipt, critical for real-time apps.
- Time taken from producer send → consumer process.
- Payments → low latency required
- Analytics → latency less important.

#### Availability

- Availability ensures cluster uptime despite failures via replication and failover.
- System is up and serving requests.
- Brokers + replication ensure availability. 1 broker down → system still works

#### Scalability

- Scalability allows horizontal growth by adding brokers and partitions to handle more load without redesign.
- Ability to handle increased load by adding resources.
- In Kafka: Add partitions → more consumers → more parallelism. Scalability is limited by number of partitions.

#### Replication

- Replication duplicates partition data across brokers for redundancy and balanced scaling.
- Copies of data across brokers.
- In Kafka: Leader + followers. Prevent data loss. Enable failover

Could you explain like a real world scenarios each topic. so that an average engineer understands the problem.

Thought for 15s
Here’s a super-practical, real-world breakdown — exactly how an average engineer (like you or me) runs into these
problems every day when building Spring Boot microservices with Kafka.

I’ll explain each concept + a real scenario you can immediately relate to + what actually breaks + how good engineers
fix it.

1. Throughput
   “How many messages can the system handle per second without falling over?”

Real-world scenario (you’ve seen this):
Imagine Flipkart or Amazon on Big Billion Days / Black Friday.
In 10 seconds, 500,000+ people click “Buy Now”.
Your OrderService (Spring Boot microservice) must push 50,000+ “order-created” events per second to Kafka.
Your PaymentService and InventoryService must consume and process them at the same speed.

What goes wrong if throughput is low?

Producers start queueing → producer buffer full → orders get rejected or delayed
Consumers can’t keep up → lag explodes → customers see “Payment failed” even when money was deducted
Brokers start throttling → CPU/disk on fire → entire cluster slows down
What a good engineer does in Spring Boot:

spring.kafka.producer:
batch-size: 16384 # pack many small orders together
linger.ms: 5 # wait 5ms to make bigger batches
compression.type: lz4 # squeeze messages
acks: 1 # fast but still safe
Result? One topic easily handles 100k–500k msgs/sec on just 3 brokers.

Kafka Distributed Messaging & Data Pipeline Architecture: High Performance Event Streaming, Reliability, and Scalability
Explained | by Scaibu | DevOps.dev
blog.devops.dev
Mastering Kafka Concept: High Throughput, Low Latency, Deduplication and Data Integrity | by 🚀 Backend Scaling
Playbook | Medium
dip-mazumder.medium.com

2. Latency
   “How long does it take from ‘I clicked Buy’ to ‘Payment confirmed’?”

Real-world scenario:
You are paying for Swiggy/Zomato order using UPI.
You expect the screen to say “Paid ✓” in < 800ms.

Two completely different needs in same company:

Payment microservice → low latency (must be < 300ms end-to-end)
Analytics / Recommendation team → high latency is fine (they can wait 5–10 seconds)
What goes wrong?
If you tune Kafka for max throughput (big batches, high linger), your payment event takes 2–3 seconds → customer thinks
payment failed → double charges → angry calls to support.

How real teams solve it:

Separate topics: payment-events (low latency) vs user-activity (high throughput)
Payment producer: linger.ms=0, batch.size=1k, acks=1
Analytics consumer: max.poll.records=1000
How a Tier‑1 Bank Tuned Apache Kafka® for p99 Latency for Trading
confluent.io
How a Tier‑1 Bank Tuned Apache Kafka® for p99 Latency for Trading

3. Availability
   “Is the system still working when shit hits the fan?”

Real-world scenario:
It’s 11:59 PM on 31st Dec. Everyone is booking cab on Ola/Uber for New Year.
Suddenly one Kafka broker (or even entire AZ in AWS) goes down because of network blip.

Without good availability:

All producers start getting errors → no more ride requests processed
Customers see “Something went wrong” → they switch to competitor
With proper Kafka setup (what actually happens in production):

Replication Factor = 3
One broker dies → other two have full copy
Leader election happens in < 5 seconds
No messages lost, no downtime visible to users
You just see in logs: “Broker 2 down → new leader elected for partition 5”

Spring Boot tip: Always set
min.insync.replicas=2 + unclean.leader.election.enable=false

4 Ways to Avoid Datacenter and Cloud Provider Outages in Apache Kafka
developer.confluent.io
Apache Kafka Explained: Core Concepts, Use Cases, and Architecture | by Syed Fawzul Azim | Medium
medium.com

4. Scalability
   “Black Friday next year will be 3x bigger — can I just add servers?”

Real-world scenario:
Your startup food-delivery app grows from 10k to 300k orders/day in 6 months (classic story of Swiggy, Zomato, Blinkit).

Vertical scaling (wrong way):
You keep adding CPU/RAM to existing 3 brokers → hits limit → expensive machines → still crashes on peak.

Horizontal scaling (Kafka way — correct):
You simply:

Add 2 more brokers (cheap VMs)
Increase partitions from 8 → 24 on order-events topic
Deploy 3 more consumer pods of your Spring Boot service
Kafka automatically rebalances → now 24 consumers working in parallel → handles 3x load with zero code change.

Important catch: You can only scale up to number of partitions.
That’s why smart engineers start with 12–16 partitions even if today they need only 3.

Comparing Horizontal vs. Vertical Scaling in Apache Kafka®
confluent.io
Scaling Kafka: Unraveling the Mystery of Topic Capacity -
dattell.com

5. Replication
   “I lost one server… did I lose any customer data?”

Real-world scenario:
Your banking app (or Razorpay/Paytm) processes money transfers.
A Kafka broker crashes at 9:17 AM while 47,000 transactions are in flight.

Without replication:

Some transactions disappear → money lost → RBI calls → company in deep trouble
With replication (what actually saves you):

Every partition has 3 copies (Leader + 2 Followers)
Producer waits till at least 2 brokers confirm write (acks=all, min.insync.replicas=2)
When broker dies → follower instantly becomes leader → zero data loss
You just see a small blip in monitoring and everything continues.

What is ISR (In-Sync Replicas) in Kafka? | NootCode Knowledge Hub
nootcode.com
Knowing and valuing Apache Kafka's ISR (In-Sync Replicas) | by Gautam Goswami | Medium
gautambangalore.medium.com

Quick cheat sheet for your Spring Boot projects (2026 standard):

Need Typical Setting Real Example
High Throughput Big batches + lz4 + acks=1 Analytics, logs
Low Latency linger=0 + small batch + acks=1 Payments, notifications
High Availability RF=3, min.insync=2, unclean=false Money, orders
Easy Scaling 12–24 partitions + more brokers/pods Growing apps
These five things are always in tension — increasing one usually hurts another.
The art of being a good Kafka engineer is knowing which one matters most for THIS particular microservice.

If you want, I can give you:

Exact application.yml for a payment service (low latency) vs analytics service (high throughput)
Or a ready Docker + Spring Boot template with all these tuned
Just say which one you want next! 🚀

1.3s

## Data Safety and Guarantees

#### Durability

- Data is not lost after being written. Durability persists messages durably once acknowledged, preventing loss via
  commit logs.
- In Kafka, data is stored on disk and replicated across brokers
- Config drivers: acks=all, replication factor

#### Reliability

- Reliability maintains consistent delivery through configs like acks=all and min.insync.replicas.
- System behaves correctly under failures.
- Includes: No data loss, Proper retries, Consistent processing.
- Difference: Durability = data survives, Reliability = system behaves correctly

#### Idempotency

- Idempotency prevents duplicates via unique producer IDs and sequence numbers in transactions.
- Same operation executed multiple times → same result.
- In Kafka: Producer idempotence avoids duplicate writes, Consumer idempotency avoids duplicate processing.
- Duplicate Messages arise from retries or at-least-once semantics, mitigated by idempotency.
- Same message delivered more than once.Happens due to: retries, consumer crash, rebalancing
- Reality: Kafka guarantees at-least-once, not exactly-once (by default)
  Here’s a clear, real-world explanation of Durability, Reliability, and Idempotency in Kafka — explained like you're
  debugging a production incident at 2 AM with your team, using everyday scenarios most backend engineers (especially in
  Spring Boot microservices) actually hit.

1. Durability
   “Once I said ‘order placed’, is the money really gone forever — or can a crash eat it?”

Real-world scenario (super common in fintech / e-commerce):
A user clicks “Pay Now” on your app (Razorpay / PhonePe style).
Your Spring Boot Payment microservice sends an “payment-success” event to Kafka.
Broker writes it → but right after, the leader broker crashes hard (disk full, OOM, power cut in data center).
Question: Did that payment event disappear? → Customer sees “Payment failed” but bank deducted money → chargeback storm.

What Durability actually means here:
Durability = “the message survives crashes / restarts / broker deaths — as long as it was properly acknowledged.”

How Kafka delivers durability (the chain that saves you):

Message written to leader's disk (commit log — append-only file)
Replicated to followers
Producer gets ack only after configured replicas confirm
Key configs that control it:

acks=all → wait for all in-sync replicas (not just leader)
replication.factor=3 → 3 copies total
min.insync.replicas=2 → must have at least 2 live copies before saying “success”
Real production example:

You set acks=all + min.insync.replicas=2
One broker dies during peak → still 2 copies alive → write succeeds → payment event safe
If two brokers die → write fails (NOT_ENOUGH_REPLICAS) → producer retries or errors out → no silent loss
Bottom line: Durability is about surviving hardware / broker failures after the write.
Without strong durability → money disappears silently. With it → you sleep better.

2. Reliability
   “Even when things break, does the whole system keep behaving correctly — no ghost payments, no lost inventory?”

Real-world scenario:
Black Friday. 100k orders/sec.
One broker restarts → rebalance happens → consumer crashes mid-processing → retry logic kicks in → but somehow you end
up charging twice or skipping inventory deduction.

Durability ≠ Reliability (biggest confusion point)

Aspect Durability Reliability
Focus “Is the data still there after crash?” “Does the whole pipeline behave correctly under failures?”
Main concern Data loss Duplicates, ordering violations, inconsistent state
Kafka helps with acks=all + replication + min.insync Idempotence + retries + transactions + consumer logic
Real failure mode Message vanishes after broker death Message arrives twice → double charge
Real production pain:
You have perfect durability (message never lost), but poor reliability:

Producer retry → duplicate write (without idempotence)
Consumer crash after DB write but before commit offset → reprocess → double inventory deduction
What good engineers do for reliability in Spring Boot:

Enable producer idempotence
Use manual offset commit after successful business action
Make consumers idempotent (check unique event ID)
Add DLQ for poison messages
Use transactions if DB + Kafka must be atomic
Bottom line: Reliability is the full promise: no loss + no harmful duplicates + correct order + correct side effects (
DB, emails, etc.) even during chaos.

3. Idempotency
   “If the same thing happens twice, nothing bad should happen the second time.”

Real-world scenario (the nightmare everyone has seen):
Payment microservice sends “deduct ₹500” event.
Network glitch → broker wrote it but ack lost → producer retries → now two identical events in Kafka.
Inventory consumer sees both → deducts stock twice → “out of stock” even when only one order.
Or worse: payment processor charges twice → angry customer tweet.

Where duplicates come from (very common causes):

Producer retry (network blip, broker timeout)
Consumer crash after processing but before offset commit
Rebalance during long poll → same message re-delivered
Kafka’s help (two levels):

A. Producer-side idempotence (prevents duplicate writes to Kafka)

Set enable.idempotence=true (in Spring: spring.kafka.producer.enable-idempotence: true)
Kafka gives producer a unique Producer ID (PID) + auto-incrementing sequence number per partition
Broker remembers last seen (PID, seq) → if retry with same seq → rejects duplicate
Result: Even if producer retries 100 times → only one copy in topic
Real example:
Bank transfer event → producer crashes after send but before ack → restarts → retries → thanks to idempotence → no
double publish to Kafka.

B. Consumer-side idempotency (prevents duplicate processing / side effects)
Kafka alone cannot do this — you must code it.

Common ways in Spring Boot:

Every event has unique eventId / transactionId / UUID
Before processing: SELECT 1 FROM processed_events WHERE id = ?
If exists → skip (already done)
Else → process + INSERT id
Or use Redis / DB with unique constraint on eventId
Real production pattern (2026 standard):

Producer: enable.idempotence=true + acks=all + retries=high
Consumer: manual ack + check eventId in DB before action
For ultra-critical (money movement): Kafka transactions (transactional.id=...) + isolation.level=read_committed
Quick summary cheat-sheet:

Concept What it protects against Kafka config / feature Real-world must-have? Spring Boot tip
Durability Data loss on crashes acks=all + min.insync.replicas=2 + RF=3 Yes — always for business data Never use acks=0
in prod
Reliability Wrong behavior (dupe/lost/order)    Above + idempotence + transactions + logic Yes — the full goal Combine
producer + consumer idempotency
Idempotency Duplicates from retries/crashes Producer: enable.idempotence=true
Consumer: your code Yes — for money/orders/inventory Event must carry unique ID
These three are layered:
Durability (base layer) → Reliability (full system promise) → Idempotency (the tool that makes reliability possible in
practice).

If you want exact Spring Boot yaml + code for a payment service with strong durability + full idempotency (producer +
consumer), or how to add Kafka transactions for DB + Kafka atomicity — just tell me which scenario to zoom into! 🚀

2s
Web page favicon
Web page favicon
Web page favicon
40 sources

## Operational Metrics

#### Consumer Lag

- Consumer Lag tracks unprocessed messages, signaling overload or slow consumers.
- Difference between:Latest offset - Consumer offset. How far consumer is behind
- High lag = your system is failing to keep up

#### Back-Pressure

- System slows down producers when consumers can’t keep up
- Back Pressure occurs when consumers can't keep up, managed via buffer limits and scaling.
- In Kafka: Not automatic like some systems, You must handle it (rate limiting, scaling consumers)

#### Processing Time

- Time taken by consumer to process one message. High processing time → increases lag
- Includes: DB calls, API calls, business logic.
- Processing Time measures per-message handling duration, impacting lag and throughput.

#### Rebalancing

- Kafka redistributes partitions among consumers when: a consumer joins/leaves, a consumer crashes, group metadata
  changes
- Where duplicates come from

1. Consumer reads message
2. Processes it
3. Rebalance happens BEFORE offset commit
4. New consumer reads same message again

- Result: duplicate processing.
- Idempotent processing (non-negotiable):  DB unique constraint on transactionId.
- Control processing time: Long processing = higher chance of rebalance mid-processing.
- Tune polling: (max.poll.interval.ms=300000) If processing exceeds this → Kafka assumes consumer is dead → triggers
  rebalance.
- Use cooperative rebalancing (advanced): Reduces stop-the-world effect: (
  partition.assignment.strategy=org.apache.kafka.clients.consumer.CooperativeStickyAssignor)

#### Offset Management (core of correctness)

- Offset = pointer to “where consumer is in the log”
- There are two approaches Auto Commit and Manual Commit.
- Auto Commit: (enable.auto.commit=true)

1. Read message
2. Offset auto committed
3. Crash before processing
   → DATA LOSS

- Manual Commit: (ack.acknowledge();) Commit after success.
- Failure scenarios
- Case 1: Crash before commit
  → message reprocessed → duplicate
- Case 2: Commit before processing
  → message lost forever.
- What you MUST do
  Always commit after DB success
  Never use auto commit in critical systems
  Combine with idempotency

| Strategy     | Result     |
|--------------|------------|
| Early commit | Data loss  |
| Late commit  | Duplicates |

#### Partition Strategy (controls scaling + ordering)

- How messages are distributed across partitions
- Ordering: Kafka guarantees Order only within a partition.
- Parallelism: More partitions → more consumers → higher throughput

| Use case | Key           |
|----------|---------------|
| Payments | transactionId |
| Orders   | orderId       |
| Logs     | random        |

Failure when done wrong
❌ No key (round-robin)
TXN1 → P0
TXN1 → P2
Order breaks → inconsistent state

Hot partition
All messages → same key → same partition

- One partition overloaded → lag spike

- What you MUST do
  Choose key based on business entity
  Balance distribution
  Pre-plan partition count (hard to change later)
- Hidden cost
- More partitions:
- More memory
- More open file handles
- More rebalance overhead

#### Delivery Semantics (what Kafka actually guarantees)

- **At Most Once** Process once or not at all. Offset committed before processing. Fast but risky. Not for payments
- **At Least Once (default, most used)** Process ≥ 1 times (duplicates possible). Commit after processing. Safe for data
- **Exactly Once (EOS)** Kafka guarantees No duplicate writes (producer side), Transactional processing.
- EOS requires: Idempotent producer, Transactions,Careful config.
- Why most teams avoid EOS: Complex, Performance overhead, Hard to debug.
- What you should do instead, Use: At-least-once delivery, Idempotent consumers.
  Here’s a practical, real-world explanation of these operational metrics in Kafka — explained through scenarios that
  actually happen in production Spring Boot microservices (e-commerce, fintech, food delivery, etc.). These are the
  things that wake engineers up at 3 AM.

I’ll use everyday examples + what breaks + how teams fix it in 2026.

1. Consumer Lag
   “How far behind is my consumer? Are orders being processed or just piling up?”

Real-world scenario (very common in e-commerce/fintech):
Black Friday peak. Producers (order-placement service) send 80,000 “order-created” events per second.
Your Spring Boot consumer group (inventory + payment processors) can only handle 45,000/sec.
Lag starts at 0 → climbs to 2 million messages in 10 minutes.
Dashboard shows: “Consumer lag = 2,000,000 msgs”
Customers see “Out of stock” errors even when items are available → angry support tickets.

Another real case (fraud detection):
Bank streams real-time transactions to Kafka. Fraud engine consumer lags by 15 minutes → fraudulent UPI transfer
completes before detection → money gone.

What lag really tells you:
Lag = latest offset − consumer's current offset
High lag → consumers too slow (slow DB writes, heavy logic, GC pauses, under-scaled pods) or dead.

How teams fix it (practical steps):

Monitor lag with Prometheus + Grafana (alert if > 10,000 or growing > 1k/sec)
Scale consumers horizontally (more pods)
Optimize processing (batch DB inserts, async heavy work)
Fix root causes: GC tuning, more CPU/memory, reduce max.poll.records if single message is slow
Bottom line: Lag is your early warning siren. Ignore it → system fails silently until users complain.

2. Back-Pressure
   “When consumers drown, how do we stop producers from flooding the system?”

Real-world scenario:
Your food-delivery app has a surge (rainy evening, everyone orders biryani).
Order events flood Kafka.
Consumers (delivery assignment + notification services) get overloaded → processing slows → lag explodes → but producers
keep sending happily → memory buffers fill → OOM crashes or thread exhaustion.

Kafka does NOT have built-in back-pressure like RabbitMQ or reactive streams.
It happily lets producers fill topics forever.

What happens without handling:

Consumers pause polling (or get kicked out → rebalance storm)
Lag → infinite growth
Downstream DBs overload → timeouts everywhere
How real Spring Boot teams handle it (2026 patterns):

Application-level back-pressure: Use bounded queues / thread pools in consumers → when full, pause Kafka polling (
consumer.pause() partitions) → resume when queue drains
Rate-limit producers (e.g., Resilience4j RateLimiter around KafkaTemplate.send())
Scale consumers aggressively (KEDA / HPA based on lag metrics)
Lower max.poll.records (e.g. 50 instead of 500) → smaller batches → faster cycles → less overload per poll
Hand off heavy work to separate thread pools + manual ack only after success
Bottom line: You must build back-pressure yourself. Otherwise fast producers kill slow consumers.

3. Processing Time
   “How long does one message take? If too long → lag guaranteed.”

Real-world scenario:
Payment consumer calls external gateway (Razorpay/Stripe) + writes to DB + sends email/SMS.
Average = 800 ms per message.
During peak → gateway latency spikes to 4–5 seconds → one consumer processes ~1 msg/sec → lag builds fast.

What high processing time causes:

Fewer messages processed per poll → lag grows
Higher chance of hitting max.poll.interval.ms → consumer marked dead → rebalance → duplicates
How teams keep it under control:

Measure per-message time (Micrometer @Timed on listener method)
Offload slow parts (email → async queue, heavy computation → separate worker)
Use batch processing where possible
Set realistic max.poll.interval.ms = 5–10× average processing time
Alert on p95/p99 processing time > 2 seconds
Bottom line: Processing time is the hidden killer of throughput. Every extra 100 ms hurts at scale.

#### Rebalancing

- Kafka redistributes partitions among consumers when: a consumer joins/leaves, a consumer crashes, group metadata
  changes
- Where duplicates come from

1. Consumer reads message
2. Processes it
3. Rebalance happens BEFORE offset commit
4. New consumer reads same message again

- Result: duplicate processing.
- Idempotent processing (non-negotiable):  DB unique constraint on transactionId.
- Control processing time: Long processing = higher chance of rebalance mid-processing.
- Tune polling: (max.poll.interval.ms=300000) If processing exceeds this → Kafka assumes consumer is dead → triggers
  rebalance.
- Use cooperative rebalancing (advanced): Reduces stop-the-world effect: (
  partition.assignment.strategy=org.apache.kafka.clients.consumer.CooperativeStickyAssignor)

##### Fixes that actually work:

- Idempotency everywhere — non-negotiable. Unique transactionId + DB unique constraint / processed_events table
- CooperativeStickyAssignor (default in modern spring-kafka) → incremental rebalance → less stop-the-world
- Tune timeouts: max.poll.interval.ms = processing time + buffer (e.g. 10–30 min for slow jobs)
- Static membership (group.instance.id) → stable pods (StatefulSet) → fewer rebalances
- Commit in onPartitionsRevoked callback (last chance before revocation)
- Bottom line: Rebalancing is normal, but without idempotency → duplicates. With long processing → frequent rebalances.

#### Offset Management (core of correctness)

- Offset = pointer to “where consumer is in the log”
- There are two approaches Auto Commit and Manual Commit.
- Auto Commit: (enable.auto.commit=true)

1. Read message
2. Offset auto committed
3. Crash before processing
   → DATA LOSS

- Manual Commit: (ack.acknowledge();) Commit after success.
- Failure scenarios
- Case 1: Crash before commit
  → message reprocessed → duplicate
- Case 2: Commit before processing
  → message lost forever.
- What you MUST do
  Always commit after DB success
  Never use auto commit in critical systems
  Combine with idempotency

##### What you must choose (production reality):

- Never auto-commit for money/orders/inventory
- Manual immediate or manual after success + idempotency
- At-least-once + idempotent consumer → safest simple choice
- Early commit → possible loss
- Late commit → possible duplicates (but fixable with idempotency)

| Strategy     | Result     |
|--------------|------------|
| Early commit | Data loss  |
| Late commit  | Duplicates |

#### Partition Strategy (controls scaling + ordering)

- How messages are distributed across partitions
- Ordering: Kafka guarantees Order only within a partition.
- Parallelism: More partitions → more consumers → higher throughput

| Use case | Key           |
|----------|---------------|
| Payments | transactionId |
| Orders   | orderId       |
| Logs     | random        |

Failure when done wrong
❌ No key (round-robin)
TXN1 → P0
TXN1 → P2
Order breaks → inconsistent state

Hot partition
All messages → same key → same partition

- One partition overloaded → lag spike

- What you MUST do
  Choose key based on business entity
  Balance distribution
  Pre-plan partition count (hard to change later)
- Hidden cost
- More partitions:
- More memory
- More open file handles
- More rebalance overhead

#### Delivery Semantics (what Kafka actually guarantees)

- **At Most Once** Process once or not at all. Offset committed before processing. Fast but risky. Not for payments
- **At Least Once (default, most used)** Process ≥ 1 times (duplicates possible). Commit after processing. Safe for data
- **Exactly Once (EOS)** Kafka guarantees No duplicate writes (producer side), Transactional processing.
- EOS requires: Idempotent producer, Transactions,Careful config.
- Why most teams avoid EOS: Complex, Performance overhead, Hard to debug.
- What you should do instead, Use: At-least-once delivery, Idempotent consumers.

- At-least-once + idempotent consumers + DLQ for failures
  → Reliable, simple, good perf
  → Duplicates possible → but idempotency handles them
- At-most-once → only non-critical (logs, metrics)
- Exactly-once → only when needed (Kafka Streams, or Kafka + DB transactions with transactional.id) → complex, slower
- Most fintech/e-commerce teams stick to at-least-once + idempotency — it survives 99.9% of chaos without the
  exactly-once overhead.
- These metrics are interconnected: high processing time → lag → back-pressure needed → rebalance risk → offset/commit
  strategy matters → partition strategy affects everything.

``text
Rebalancing + Offset (Rebalance before commit → duplicate)
Offset + Delivery semantics (Commit after processing → at-least-once)
Partition + Ordering (Wrong key → ordering breaks)
Delivery + Idempotency (At-least-once → requires idempotent consumer)
Partition → decides WHERE data goes
Offset → decides WHAT is processed
Rebalance → decides WHO processes
Delivery semantics → decides HOW MANY TIMES processed
``

## Failure and Data Issues

#### Data Loss:

- Message never processed or lost permanently. Data Loss happens without sufficient replication or acks, avoided via
  strong durability settings.
- Causes: auto commit before processing, acks=1, broker crash before replication.

#### Ordering Breaks

- Messages processed out of order. Ordering Breaks occur across partitions or rebalances; preserved only within
  partitions.
- In Kafka: Ordering guaranteed only within a partition
- Breaks when: no proper key, multiple partitions used incorrectly.

## Error Handling && Monitoring

#### DLT Volume (Dead Letter Topic)

- Number of failed messages sent to DLT. DLT Volume (Dead Letter Topic) counts failed messages routed for retry or
  inspection
- High DLT = something is wrong in processing

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092

    # 🔹 Producer Config
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer

      acks: all
      retries: 2147483647
      enable-idempotence: true

      # batching vs latency trade-off
      batch-size: 16384
      linger-ms: 5
      compression-type: snappy

      # safety
      max-in-flight-requests-per-connection: 5

    # 🔹 Consumer Config
    consumer:
      group-id: payment-group
      auto-offset-reset: earliest
      enable-auto-commit: false

      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer

      max-poll-records: 100

      # tuning fetch behavior
      fetch-min-size: 1
      fetch-max-wait: 500

    # 🔹 Listener (Spring-specific)
    listener:
      ack-mode: manual
      concurrency: 3   # match partitions ideally

      # avoid rebalance issues
      poll-timeout: 3000

    # 🔹 Properties (low-level tuning)
    properties:
      session.timeout.ms: 10000
      heartbeat.interval.ms: 3000
      max.poll.interval.ms: 300000

      # cooperative rebalancing (important)
      partition.assignment.strategy: org.apache.kafka.clients.consumer.CooperativeStickyAssignor
  ```

### Kafka End to End Flow

#### Producer side Flow

1. Producer creates message
   Adds key, value, headers
2. Partitioning happens
   Key → decides partition (hashing)
   No key → round-robin
   Ordering is guaranteed only within a partition
3. Batching & buffering
   Messages grouped (batch.size, linger.ms) before sending to improve throughput
4. Producer sends to broker (leader partition)
   Request goes to leader of the target partition
5. Retry (Producer side)
   If send fails → producer retries automatically
   Can cause duplicates if not handled properly
6. Idempotence (Producer)
   Ensures retries don’t create duplicates
   Guarantees exactly-once at producer level
7. Broker writes to commit log (disk)
   Sequential write → very fast
   Message stored on disk with offset
8. Replication to follower brokers
   Followers copy data from leader
9. Acknowledgment sent to producer
   Based on acks:
   0 → no ack
   1 → leader ack
   all → all replicas ack

#### Consumer Side Flow

1. Consumer group & rebalance
   Consumers join group
   Partitions assigned
   Rebalance happens on join/leave/failure
2. Consumer polls messages
   poll() pulls data from broker (Kafka is pull-based, not push)
3. Broker returns messages
   From partition based on last committed offset
4. Consumer processes message (your logic)
   Example: validation, transformation, DB write
5. After DB write → offset commit happens
   If commit before DB write → data loss risk
   If commit after DB write → safer (at-least-once)

#### Offset Handling

1. Offset commit (Auto vs Manual)
   Auto commit:
   Offsets committed periodically
   Risk: commit before processing → data loss
   Manual commit:
   Commit after processing (preferred)
   Better control, safer
   Stored in Kafka (__consumer_offsets topic)
   Marks message as “processed”
2. Commit after DB write
   Correct flow:
   Process → DB write → commit offset
   Ensures at-least-once delivery