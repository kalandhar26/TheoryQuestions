# How does kafka ensure message delivery (atleast once, atmost once and exacly once)?

- **At-Most-Once:** A message is delivered zero or one time; it may be lost but never duplicated.
- **How Kafka Achieves It:**
    1. Producers send messages without waiting for broker acknowledgment (acks=0).
    2. Consumers commit offsets immediately after receiving messages, before processing.
- **Mechanism:** No retries on producer failure, and early offset commits on the consumer side risk message loss if
  processing fails.
- **Use Case:** Suitable for scenarios where losing a message is acceptable (e.g., non-critical logs).

- **At-Least-Once:** A message is delivered one or more times; it’s never lost but may be duplicated.
- **How Kafka Achieves It:**
    1. Producers wait for broker acknowledgment (acks=1 or acks=all) and retry on failure.
    2. Consumers process messages first, then commit offsets, ensuring no message is missed.
    3. If a consumer fails after processing but before committing, it may reprocess the message, leading to duplicates.
- **Mechanism:** Producer retries and delayed offset commits ensure delivery but risk duplicates.
- **Use Case:** Used when message loss is unacceptable (e.g., financial transactions).

- **Exactly-Once:**A message is delivered exactly once—no loss, no duplicates.
- **How Kafka Achieves It:**

    1. Introduced in Kafka 0.11 with idempotent producers and transactional messaging.
    2. Idempotent Producer: Assigns a unique Producer ID (PID) and sequence number to each message. Brokers detect and
       eliminate duplicates based on PID and sequence.
    3. Transactional Consumer: Uses transactions to ensure atomic writes across multiple partitions. Consumers read only
       committed messages (isolation.level=read_committed).

- **Mechanism:** Producers use enable.idempotence=true and transactional APIs (transactional.id). Consumers commit
  offsets transactionally, ensuring processing and offset commits are atomic.
- **Use Case:** Critical for applications requiring strict consistency (e.g., payment systems).

**Summary:**

- at-most-once by skipping retries and committing early.
- at-least-once with retries and delayed commits.
- exactly-once using idempotent producers and transactional APIs to prevent loss and duplicates.

# How do you test Kafka consumers in a real time scenario?

- Embedded Kafka (for unit/integration tests):

1. Use @EmbeddedKafka (Spring Kafka) to spin up a local Kafka broker.
2. Test consumer logic without external dependencies.

- Mocking with KafkaTemplate (for unit tests):

1. Mock KafkaTemplate to simulate message production.
2. Verify consumer behavior using @SpyBean or Mockito.

- Test Containers (for near-real integration tests):

1. Use Dockerized Kafka (Testcontainers) for a lightweight, real broker.
2. Test end-to-end flow with actual Kafka networking.

- Manual Testing (Real Kafka Cluster):

1. Use tools like kafkacat or scripts to produce test messages.
2. Monitor consumer logs/offsets (consumer-groups CLI).

## How do we guarantee that only committed (i.e., fully acknowledged) records ever reach our listener when brokers or producers use transactions?

- Use the consumer isolation-level setting

```yaml
spring:
  kafka:
    consumer:
      isolation-level: read_committed # default = read_uncommitted
```

---

## Question 1: What is Kafka and How Does It Work?

### Solution

Apache Kafka is a distributed streaming platform designed for high-throughput, fault-tolerant, and scalable processing
of real-time data feeds, functioning as a publish-subscribe messaging system.

- **Distributed System**: Kafka runs as a cluster of brokers, storing messages in a durable, replicated log.
- **Publish-Subscribe**: Producers send messages to topics; consumers subscribe to read them.
- **Topics and Partitions**: Messages are stored in topics, split into partitions for parallelism.
- **Durability**: Messages are persisted to disk and replicated across brokers.
- **Scalability**: Scales by adding brokers or partitions to handle increased load.
- **Workflow**:
    - Producers publish messages to topics, stored in partitions with unique offsets.
    - Consumers read messages, tracking progress via offsets.
    - ZooKeeper or KRaft manages cluster coordination (e.g., leader election).
- **Use Cases**: Log aggregation, event streaming, real-time analytics.

```java
// Simple Kafka Producer

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

import java.util.Properties;

public class SimpleProducer {
    public static void main(String[] args) throws Exception {
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
        props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            producer.send(new ProducerRecord<>("my-topic", "key", "Hello, Kafka!")).get();
        }
    }
}
```

## Question 2: Explain Kafka Architecture (Brokers, ZooKeeper, Topics, Partitions, Consumers)

### Solution

Kafka’s architecture supports scalability and fault tolerance through distributed components.

- **Brokers**: Servers storing topic partitions, handling read/write requests. One broker is the leader per partition;
  others are followers.
- **ZooKeeper/KRaft**: ZooKeeper (pre-3.3) or KRaft (3.3+) manages metadata, leader election, and consumer group
  coordination.
- **Topics**: Logical channels for messages, split into partitions.
- **Partitions**: Ordered, immutable logs for scalability and parallelism, replicated across brokers.
- **Consumers**: Read messages from topics, either standalone or in consumer groups for load balancing.
- **Producers**: Send messages to topics, optionally specifying partitions or keys.
- **Replication**: Each partition has a leader and follower replicas for fault tolerance.
- **Workflow**: Producers write to leader partitions; consumers read from assigned partitions, with offsets tracked in
  `__consumer_offsets`.

```java
// Simple Kafka Consumer

import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class SimpleConsumer {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put("bootstrap.servers", "localhost:9092");
        props.put("group.id", "my-consumer-group");
        props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        props.put("enable.auto.commit", "true");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            consumer.subscribe(Collections.singletonList("my-topic"));
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
                records.forEach(record -> System.out.printf("offset=%d, value=%s%n", record.offset(), record.value()));
            }
        }
    }
}
```

## Question 3: Difference Between Kafka and Traditional Message Queues (e.g., RabbitMQ)

### Solution

Kafka differs from traditional message queues like RabbitMQ in design and use cases.

- **Architecture**:
    - Kafka: Distributed log with persistent storage, partitioned topics for scalability.
    - RabbitMQ: Queue-based system with messages typically removed after consumption.
- **Message Retention**:
    - Kafka: Retains messages for a configurable period (e.g., days), allowing replay.
    - RabbitMQ: Messages are deleted after acknowledgment unless explicitly persisted.
- **Scalability**:
    - Kafka: Scales horizontally via partitions and brokers, handling high throughput.
    - RabbitMQ: Scales via clustering but is less suited for massive data volumes.
- **Delivery Semantics**:
    - Kafka: At-least-once by default, supports exactly-once with transactions.
    - RabbitMQ: Supports at-most-once, at-least-once, or exactly-once with AMQP.
- **Use Cases**:
    - Kafka: Event streaming, log aggregation, real-time analytics.
    - RabbitMQ: Task queues, point-to-point messaging, workflow orchestration.
- **Consumer Model**:
    - Kafka: Consumer groups for parallel processing.
    - RabbitMQ: Work queues with competing consumers.

## Question 4: How Does Kafka Ensure Message Delivery?

### Solution

Kafka ensures message delivery through replication, acknowledgments, and offset management.

- **Replication**: Partitions are replicated across brokers (controlled by `replication.factor`), ensuring data
  availability if a broker fails.
- **Producer Acks**:
    - `acks=0`: No acknowledgment; risk of loss.
    - `acks=1`: Leader acknowledges; risk of loss if leader fails before replication.
    - `acks=all`: All in-sync replicas acknowledge, ensuring durability.
- **Retries**: Producers retry failed sends (configurable via `retries`).
- **Consumer Offset Commits**: Consumers commit offsets to track processed messages, resuming from the last offset on
  restart.
- **Idempotence**: Prevents duplicates by assigning unique sequence numbers to messages.
- **Transactions**: Enable exactly-once delivery by coordinating writes and offset commits.

```java
package com.example.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;

import java.util.Properties;

public class ReliableKafkaProducer {

    public static void main(String[] args) {

        // 1. Producer Configuration for Reliable Delivery
        Properties props = new Properties();

        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
                "localhost:9092");

        props.put(ProducerConfig.ACKS_CONFIG,
                "all");                         // Strong durability

        props.put(ProducerConfig.RETRIES_CONFIG,
                3);                             // Retry on transient failures

        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG,
                true);                          // Prevent duplicates

        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringSerializer");

        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringSerializer");

        // 2. Create Kafka Producer
        KafkaProducer<String, String> producer =
                new KafkaProducer<>(props);

        try {
            // 3. Create and send message
            ProducerRecord<String, String> record =
                    new ProducerRecord<>("orders",
                            "order-101",
                            "Order Placed Successfully");

            producer.send(record, (RecordMetadata metadata, Exception exception) -> {
                if (exception == null) {
                    System.out.printf(
                            "Message delivered to topic=%s partition=%d offset=%d%n",
                            metadata.topic(),
                            metadata.partition(),
                            metadata.offset()
                    );
                } else {
                    exception.printStackTrace();
                }
            });

        } finally {
            // 4. Flush and close producer
            producer.flush();
            producer.close();
        }
    }
}
                         
```

## Question 5: What is the Role of `acks`, `retries`, and `linger.ms` in a Producer Config?

### Solution

These configurations control producer reliability and performance.

- **acks**:
    - Specifies acknowledgment requirements.
    - `acks=0`: No acknowledgment; fastest but risks loss.
    - `acks=1`: Leader acknowledges; balances speed and reliability.
    - `acks=all`: All in-sync replicas acknowledge; maximizes durability.
- **retries**:
    - Number of retry attempts for transient failures (e.g., network issues).
    - Set to a positive integer (e.g., 3) to handle temporary broker unavailability.
- **linger.ms**:
    - Time (in milliseconds) the producer buffers messages before sending.
    - Higher values increase latency but improve throughput by batching messages.
    - Example: `linger.ms=5` waits 5ms to accumulate messages.

```java
package com.example.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;

import java.util.Properties;

public class ProducerConfiguration {

    public static void main(String[] args) {

        // 1. Producer Configuration
        Properties props = new Properties();

        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
                "localhost:9092");

        props.put(ProducerConfig.ACKS_CONFIG,
                "all");                 // Strong durability

        props.put(ProducerConfig.RETRIES_CONFIG,
                3);                     // Retry on transient failures

        props.put(ProducerConfig.LINGER_MS_CONFIG,
                5);                     // Enable batching

        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringSerializer");

        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringSerializer");

        // 2. Create Kafka Producer
        KafkaProducer<String, String> producer =
                new KafkaProducer<>(props);

        try {
            // 3. Send a sample message
            ProducerRecord<String, String> record =
                    new ProducerRecord<>("orders",
                            "order-1",
                            "Order Created");

            producer.send(record, (RecordMetadata metadata, Exception exception) -> {
                if (exception == null) {
                    System.out.printf(
                            "Message sent successfully to topic=%s, partition=%d, offset=%d%n",
                            metadata.topic(),
                            metadata.partition(),
                            metadata.offset()
                    );
                } else {
                    exception.printStackTrace();
                }
            });

        } finally {
            // 4. Flush and close producer
            producer.flush();
            producer.close();
        }
    }
}

```

## Question 6: Explain Consumer Groups and Offset Management

### Solution

Consumer groups and offset management enable scalable and fault-tolerant message processing.

- **Consumer Groups**:
    - A group of consumers that share the same `group.id` to process a topic’s partitions in parallel.
    - Kafka assigns each partition to exactly one consumer in the group.
    - Rebalancing occurs when consumers join/leave, redistributing partitions.
- **Offset Management**:
    - Each message in a partition has a unique offset, tracking consumer progress.
    - Offsets are stored in Kafka’s `__consumer_offsets` topic or committed manually.
    - `enable.auto.commit=true`: Automatically commits offsets periodically.
    - `enable.auto.commit=false`: Manual commits via `Acknowledgment.acknowledge()` for precise control.
- **Use Cases**: Load balancing, fault tolerance (e.g., resuming after crashes).

```java
// Spring Kafka Consumer with Manual Offset Commit

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.Acknowledgment;
import org.springframework.stereotype.Service;

@Service
public class KafkaConsumerService {
    @KafkaListener(topics = "my-topic", groupId = "my-consumer-group")
    public void consume(String message, Acknowledgment acknowledgment) {
        System.out.println("Received: " + message);
        acknowledgment.acknowledge(); // Manual commit
    }
}
```

## Question 7: How Do You Tune Kafka for High Throughput?

### Solution

Tuning Kafka for high throughput involves optimizing producer, consumer, and broker settings.

- **Producer Tuning**:
    - Increase `batch.size` (e.g., 16384) to send larger batches.
    - Set `linger.ms` (e.g., 5) to batch messages before sending.
    - Enable compressio an (`compression.type=gzip`) to reduce network load.
- **Consumer Tuning**:
    - Increase `max.poll.records` (e.g., 500) to fetch more messages per poll.
    - Set `fetch.min.bytes` (e.g., 1024) to wait for more data before polling.
- **Broker Tuning**:
    - Increase `num.io.threads` and `num.network.threads` for better I/O handling.
    - Set `replication.factor=3` and `min.insync.replicas=2` for durability.
- **Topic Configuration**:
    - Increase partitions (e.g., 10) for parallelism.
    - Optimize `segment.bytes` and `segment.ms` for efficient log management.
- **Infrastructure**: Use high-performance disks (e.g., SSDs) and sufficient brokers in AWS MSK or Kubernetes.

```yaml
# application.yml
spring:
  kafka:
    producer:
      batch-size: 16384
      linger-ms: 5
      compression-type: gzip
    consumer:
      max-poll-records: 500
      fetch-min-bytes: 1024
```

## Question 8: What is Idempotence in Kafka Producer?

### Solution

Idempotence ensures that a producer does not create duplicate messages during retries.

- **Definition**: Prevents duplicates by assigning unique sequence numbers to messages.
- **Enablement**: Set `enable.idempotence=true` in producer config.
- **Mechanism**:
    - Producer assigns a `Producer ID` (PID) and sequence number to each message.
    - Kafka brokers track sequence numbers to deduplicate messages.
- **Benefits**: Guarantees at-least-once delivery without duplicates, enabling exactly-once semantics when combined with
  transactions.
- **Requirements**: `acks=all`, `retries>0`, and `max.in.flight.requests.per.connection=1` (default for idempotence).

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class IdempotentProducer {

    public static void main(String[] args) {

        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, 3);

        KafkaProducer<String, String> producer = new KafkaProducer<>(props);

        try {
            producer.send(new ProducerRecord<>("orders", "key1", "order-created"));
        } finally {
            producer.close();
        }
    }
}

```

## Question 9: How Does Kafka Achieve Fault Tolerance?

### Solution

Kafka ensures fault tolerance through replication and distributed architecture.

- **Replication**:
    - Each partition is replicated across multiple brokers (`replication.factor`).
    - One broker is the leader; others are followers, syncing data.
- **Leader Election**: If a leader fails, a follower is promoted via ZooKeeper/KRaft.
- **In-Sync Replicas (ISR)**: Only ISRs can become leaders, ensuring data consistency.
- **Broker Redundancy**: Multiple brokers in the cluster prevent single-point failures.
- **Consumer Group Rebalancing**: Reassigns partitions if a consumer fails.
- **Offset Management**: Consumers resume from last committed offset after crashes.

```bash
# Create topic with replication
kafka-topics.sh --create --topic my-topic --bootstrap-server localhost:9092 --replication-factor 3 --partitions 4
```

## Question 10: How Would You Design a Log Aggregation Pipeline Using Kafka?

### Solution

A log aggregation pipeline collects logs from multiple sources, processes them, and stores or analyzes them.

- **Producers**: Applications or agents (e.g., Fluentd, Logstash) send logs to a Kafka topic.
- **Topic Design**: Use a topic (e.g., `logs`) with multiple partitions for scalability and a high
  `replication.factor` (e.g., 3).
- **Consumers**: Spring Boot application consumes logs, processes them (e.g., parse, enrich), and stores them in a
  database (e.g., Elasticsearch on AWS).
- **Scaling**: Increase partitions and consumer instances to handle high log volumes.
- **Monitoring**: Use Prometheus to track consumer lag and log ingestion rate.
- **Durability**: Set `acks=all` and manual offset commits to prevent loss.

```java
// Spring Boot Log Producer
@Service
public class LogProducerService {
    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;

    public void sendLog(String log) {
        kafkaTemplate.send("logs", log);
    }
}
```

## Question 11: What Happens if a Kafka Consumer Crashes? How Does It Resume?

### Solution

Kafka handles consumer crashes via consumer groups and offset management.

- **Crash Impact**: The consumer group rebalances, reassigning the crashed consumer’s partitions to other instances.
- **Offset Management**:
    - If `enable.auto.commit=true`, offsets are periodically committed, and the new consumer resumes from the last
      committed offset.
    - If `enable.auto.commit=false`, manual commits ensure no offsets are committed until processing completes.
- **Resume Process**: The new consumer starts reading from the last committed offset in `__consumer_offsets`.
- **Configuration**: Set `auto.offset.reset=earliest` to start from the beginning if no offsets exist.

```java
// Manual Offset Commit
@KafkaListener(topics = "my-topic", groupId = "my-consumer-group")
public void consume(String message, Acknowledgment acknowledgment) {
    processMessage(message);
    acknowledgment.acknowledge();
}
```

## Question 12: How Do You Handle Backpressure in Kafka?

### Solution

Backpressure occurs when consumers cannot keep up with message production.

- **Increase Consumers**: Add more consumer instances in the same group to process partitions in parallel.
- **Increase Partitions**: Add partitions to the topic to allow more parallelism.
- **Batch Processing**: Configure consumers to process messages in batches (`max.poll.records`).
- **Throttle Producers**: Implement rate limiting on producers to reduce message rate.
- **Dead-Letter Topic (DLT)**: Route unprocessable messages to a DLT for later analysis.
- **Monitoring**: Track consumer lag to detect backpressure early.

```yaml
spring:
  kafka:
    consumer:
      max-poll-records: 500
```

## Question 13: How Do You Monitor Kafka in Production?

### Solution

Monitoring Kafka ensures performance and reliability.

- **Metrics**:
    - Use JMX metrics (e.g., `kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec`).
    - Monitor consumer lag (`kafka_consumergroup_lag`).
- **Tools**:
    - Prometheus + Grafana for visualizing metrics.
    - AWS CloudWatch for MSK clusters.
    - Kafka Manager or Confluent Control Center for cluster health.
- **Logs**: Enable debug logging for `org.apache.kafka` and `org.springframework.kafka`.
- **Alerts**: Set alerts for high consumer lag, broker failures, or low disk space.
- **Key Metrics**: Message throughput, partition latency, broker CPU/disk usage.

```yaml
# Prometheus Config for Kafka
scrape_configs:
  - job_name: "kafka"
    static_configs:
      - targets: [ "kafka-broker:9999" ]
```

## Question 14: How Would You Deploy Kafka in Kubernetes?

### Solution

Deploying Kafka in Kubernetes ensures scalability and manageability.

- **StatefulSet**: Use a `StatefulSet` for Kafka brokers to ensure stable network identities and persistent storage.
- **ZooKeeper/KRaft**: Deploy ZooKeeper or use KRaft for cluster coordination.
- **Storage**: Use PersistentVolumeClaims (PVCs) for broker data (e.g., EBS volumes in AWS EKS).
- **Service**: Expose brokers via a `ClusterIP` or `LoadBalancer` service for client access.
- **Scaling**: Increase `replicas` in the `StatefulSet` to add brokers.
- **Monitoring**: Integrate Prometheus for metrics and logging.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kafka
spec:
  replicas: 3
  serviceName: kafka
  selector:
    matchLabels:
      app: kafka
  template:
    metadata:
      labels:
        app: kafka
    spec:
      containers:
        - name: kafka
          image: confluentinc/cp-kafka:latest
          env:
            - name: KAFKA_BROKER_ID
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: KAFKA_ZOOKEEPER_CONNECT
              value: "zookeeper:2181"
          volumeMounts:
            - name: data
              mountPath: /var/lib/kafka/data
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
```

## Question 15: What are Kafka Retention Policies?

### Solution

Retention policies control how long Kafka retains messages and logs.

- **Retention Period**:
    - `retention.ms`: Time messages are kept (e.g., 7 days = 604800000ms).
    - `retention.bytes`: Maximum size per partition before old messages are deleted.
- **Log Cleanup Policies**:
    - `delete`: Removes old messages after retention period/size.
    - `compact`: Removes duplicate keys, keeping the latest value (log compaction).
- **Configuration**: Set at the topic level or broker-wide (`log.retention.hours`).
- **Use Case**: Long retention for replayable logs; compaction for key-based data.

```bash
# Set retention period
kafka-topics.sh --alter --topic my-topic --bootstrap-server localhost:9092 --config retention.ms=604800000
```

## Question 16: What is Kafka Streams? When Would You Use It Over Apache Spark?

### Solution

Kafka Streams is a lightweight stream processing library for building real-time applications.

- **Kafka Streams**:
    - Java library for processing Kafka topic data (e.g., filtering, aggregation).
    - Integrates natively with Kafka, no external cluster needed.
    - Supports stateful (e.g., joins) and stateless operations.
- **Use Cases**: Real-time event processing, data transformation, microservices.
- **Kafka Streams vs. Spark**:
    - Kafka Streams: Lightweight, low-latency, tightly integrated with Kafka, ideal for simple stream processing in
      Spring Boot.
    - Spark: Heavyweight, supports batch and stream processing, better for complex analytics or large-scale data.
- **Choose Kafka Streams**:
    - When processing is Kafka-centric and lightweight.
    - For low-latency, real-time applications.
    - When avoiding external cluster management (e.g., Spark cluster).

```java
// Kafka Streams Example

import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.kstream.KStream;

public class StreamsExample {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put("application.id", "streams-app");
        props.put("bootstrap.servers", "localhost:9092");

        StreamsBuilder builder = new StreamsBuilder();
        KStream<String, String> stream = builder.stream("input-topic");
        stream.filter((key, value) -> value.contains("important"))
                .to("output-topic");

        KafkaStreams streams = new KafkaStreams(builder.build(), props);
        streams.start();
    }
}
```

## Question 17: How Does Kafka Handle Message Reprocessing?

### Solution

Kafka supports message reprocessing by allowing consumers to rewind offsets.

- **Offset Rewind**:
    - Consumers can reset offsets to an earlier point using `seek` or `auto.offset.reset=earliest`.
    - Useful for reprocessing historical data or recovering from errors.
- **Consumer Group Reset**:
    - Use `kafka-consumer-groups.sh --reset-offsets` to reset offsets for a group.
    - Options: `--to-earliest`, `--to-offset`, `--to-datetime`.
- **Retention Period**: Messages must be within the topic’s retention period (`retention.ms`).
- **Log Compaction**: For compacted topics, only the latest message per key is available for reprocessing.

```bash
# Reset consumer group offsets
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group my-consumer-group --reset-offsets --to-earliest --topic my-topic --execute
```

## Question 18: What is Exactly-Once Semantics in Kafka?

### Solution

Exactly-once semantics (EOS) ensures each message is processed exactly once, avoiding duplicates or loss.

- **Mechanism**:
    - Enabled via idempotent producers (`enable.idempotence=true`) to prevent duplicates.
    - Uses transactions to coordinate message production and offset commits atomically.
- **Producer**: Assigns unique sequence numbers and uses `transactional.id` for atomic writes.
- **Consumer**: Sets `isolation.level=read_committed` to read only committed messages.
- **Use Case**: Critical applications requiring no duplicates (e.g., financial transactions).
- **Spring Boot Example**:
    - Configure `transactional.id` and manual offset commits.

```java
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class ExactlyOnceProducer {

    public static void main(String[] args) {

        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);

        props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "tx-producer-1");

        KafkaProducer<String, String> producer = new KafkaProducer<>(props);

        producer.initTransactions();

        try {
            producer.beginTransaction();

            producer.send(new ProducerRecord<>("my-topic", "key", "value"));

            producer.commitTransaction();
        } catch (Exception e) {
            producer.abortTransaction();
        } finally {
            producer.close();
        }
    }
}

```

## Question 19: How Do You Secure Kafka in a Spring Boot Application?

### Solution

Securing Kafka involves encryption, authentication, and authorization.

- **SSL/TLS**:
    - Enable `security.protocol=SSL` for encrypted communication.
    - Configure truststore and keystore for brokers and clients.
- **Authentication**:
    - Use SASL (e.g., SASL/SCRAM, SASL/PLAIN) or IAM with AWS MSK.
    - Example: `sasl.mechanism=SCRAM-SHA-512`.
- **Authorization**:
    - Enable ACLs to restrict topic access (`authorizer.class.name=kafka.security.authorizer.AclAuthorizer`).
- **Spring Boot Config**:
    - Set SSL and SASL properties in `application.yml`.
- **Key Management**: Store certificates and credentials in AWS Secrets Manager or Kubernetes secrets.

```yaml
spring:
  kafka:
    bootstrap-servers: <broker>:9093
    properties:
      security.protocol: SSL
      ssl.truststore.location: /path/to/truststore.jks
      ssl.truststore.password: truststore-password
```

## Question 20: How Do You Handle Schema Evolution in Kafka?

### Solution

Schema evolution ensures compatibility when message formats change.

- **Schema Registry**: Use Confluent Schema Registry to manage Avro, JSON, or Protobuf schemas.
- **Compatibility Types**:
    - Backward: New consumers can read old messages.
    - Forward: Old consumers can read new messages.
    - Full: Both backward and forward compatible.
- **Spring Boot Integration**:
    - Use `spring-kafka` with `avro-serde` for schema-aware serialization.
- **Best Practices**: Version schemas, test compatibility, and update consumers/producers incrementally.

```java
// Avro Producer with Schema Registry
@Bean
public ProducerFactory<String, MyAvroRecord> producerFactory() {
    Map<String, Object> props = new HashMap<>();
    props.put(KafkaAvroSerializerConfig.SCHEMA_REGISTRY_URL_CONFIG, "http://schema-registry:8081");
    return new DefaultKafkaProducerFactory<>(props);
}
```

## Question 21: How Do You Handle Dead-Letter Topics (DLTs) in Spring Boot?

### Solution

DLTs store messages that fail processing for later analysis.

- **Configuration**:
    - Define a DLT topic (e.g., `my-topic-dlt`).
    - Use `DeadLetterPublishingRecoverer` to route failed messages.
- **Error Handling**: Catch exceptions in `@KafkaListener` and publish to DLT.
- **Monitoring**: Monitor DLT for failed messages and process them manually or automatically.

```java

@Bean
public DeadLetterPublishingRecoverer deadLetterPublishingRecoverer(KafkaTemplate<String, String> template) {
    return new DeadLetterPublishingRecoverer(template);
}

@KafkaListener(topics = "my-topic")
public void consume(String message) {
    try {
        processMessage(message);
    } catch (Exception e) {
        deadLetterPublishingRecoverer.accept(record, e);
    }
}
```

## Question 22: How Do You Optimize Kafka Performance in AWS MSK?

### Solution

Optimizing Kafka in AWS MSK enhances throughput and reliability.

- **Broker Sizing**: Use appropriately sized instances (e.g., `kafka.m5.large`).
- **Storage**: Configure EBS volumes for high IOPS (e.g., `gp3`).
- **Multi-AZ Deployment**: Deploy across multiple availability zones for fault tolerance.
- **Monitoring**: Use CloudWatch for metrics (e.g., `BytesInPerSec`, `ConsumerLag`).
- **Tuning**:
    - Set `num.io.threads=8` and `num.network.threads=5` for brokers.
    - Use `compression.type=snappy` for producers.
- **IAM Authentication**: Enable IAM for secure access without managing credentials.

```yaml
spring:
  kafka:
    bootstrap-servers: <msk-broker>:9098
    properties:
      security.protocol: SASL_SSL
      sasl.mechanism: AWS_MSK_IAM
      sasl.jaas.config: software.amazon.msk.auth.iam.IAMLoginModule required;
```

## Question 23: If There are 2 consumer groups which consume from same topic. Will the message is polled twice? or this is not possible?

- Kafka keeps one offset per (partition, consumer-group).
- Both groups read the same physical records independently; nothing prevents the broker from sending the same message to
  both.
- Each consumer group maintains its own independent offset for every partition of a topic.
- The broker does not block one group just because another group is already reading that partition.
  Only within the same consumer group is a partition assigned to exactly one consumer at a time; across different
  groups, simultaneous access is allowed.

## Question 24: What are the key properties of Kafka Producer?

```java
package com.example.kafka.producer;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.RecordMetadata;

import java.util.Properties;

public class OrderProducer {

    public static void main(String[] args) {

        // 1. Producer configuration
        Properties props = new Properties();

        // Initial list of Kafka brokers used to discover the cluster, Producer automatically finds the leader for each partition
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
                "broker1:9092,broker2:9092");

        props.put(ProducerConfig.ACKS_CONFIG,
                "all");

        props.put(ProducerConfig.RETRIES_CONFIG,
                3);

        props.put(ProducerConfig.BATCH_SIZE_CONFIG,
                16384);

        props.put(ProducerConfig.LINGER_MS_CONFIG,
                20);

        props.put(ProducerConfig.BUFFER_MEMORY_CONFIG,
                33554432);

        props.put(ProducerConfig.COMPRESSION_TYPE_CONFIG,
                "snappy");

        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringSerializer");

        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringSerializer");

        // 2. Create Kafka Producer
        KafkaProducer<String, String> producer = new KafkaProducer<>(props);

        try {
            // 3. Send messages
            for (int i = 1; i <= 5; i++) {

                ProducerRecord<String, String> record =
                        new ProducerRecord<>("orders",
                                "order-" + i,
                                "Order Created : " + i);

                producer.send(record, (RecordMetadata metadata, Exception exception) -> {
                    if (exception == null) {
                        System.out.printf(
                                "Sent to topic=%s partition=%d offset=%d%n",
                                metadata.topic(),
                                metadata.partition(),
                                metadata.offset()
                        );
                    } else {
                        exception.printStackTrace();
                    }
                });
            }
        } finally {
            // 4. Flush & close producer
            producer.flush();
            producer.close();
        }
    }
}

```

- **acks:** Controls when the producer considers a message "sent" successfully. Controls durability guarantee
- acks=0 : No acknowledgment. Fire-and-forget. where some data loss is acceptable.
- acks=1 : Leader acknowledges receipt. Good for most apps where some durability is needed.
- acks=all : Leader + all ISRs (in-sync replicas) acknowledge.where no loss is acceptable. all → Leader waits for all
  in-sync replicas to acknowledge
- **retries & retry.backoff.ms** Handles transient failures, broker down, network issues
- retries: Number of retries (default: 0). Set to Integer.MAX_VALUE for mission-critical apps.
- retry.backoff.ms: Delay between retries (default: 100ms). Adjust based on broker recovery time.
- **bootstrap.servers** List of Kafka brokers for initial connection.
- **buffer.memory & batch.size** Controls batching for throughput optimization.
- buffer.memory : Total memory for unsent messages (default: 32MB).
- batch.size: Max bytes per batch (default: 16KB).
- linger.ms : Max time to wait for batch filling (default: 0). Set to 5-100ms for better batching.
- **max.in.flight.requests.per.connection** Controls how many unacknowledged requests can be in flight.
- When the value is 1 , 1 Strict ordering (no retry reordering). Exactly-once semantics (e.g., transactions)
- 5 (default) Higher throughput, but possible reordering. High-throughput apps where order isn’t critical.
- **compression.type** Compresses messages before sending.
- none (default) - - Low CPU, high network usage.
- gzip High High Best for high-latency apps (archival).
- snappy Medium Low Balanced (logs, metrics).
- lz4 Medium Very Low Best for low-latency apps.
- zstd Very High Medium Best for Kafka 2.1+.
- **enable.idempotence** Ensures exactly-once delivery (no duplicates)
- false (default) Possible duplicates on retries. Default for most apps.
- true No duplicates even with retries. Financial transactions, orders.
- **transactional.id** Enables atomic writes across partitions/topics.
- **request.timeout.ms & delivery.timeout.ms** Controls how long producer waits for a response.
- request.timeout.ms Timeout per request (default: 30s). Increase in slow networks.
- delivery.timeout.ms Total time for send + retries (default: 2m). Must be > linger.ms + request.timeout.ms.
- **key.serializer & value.serializer** Serializers for keys and values.
- **producer tuning**
  | Goal | Key Configs |
  | ------------------ | -------------------------------------------------------------------------- |
  | Maximum Durability | `acks=all`, `enable.idempotence=true`, `retries=MAX_INT` |
  | Maximum Throughput | `acks=1`, `linger.ms=20`, `batch.size=64KB`, `compression.type=snappy/lz4` |
  | Lowest Latency | `acks=0`, `linger.ms=0`, `batch.size=1` |
  | Exactly-Once | `enable.idempotence=true`, `max.in.flight=1`, `acks=all` |

## Question 25: What are the key properties of Kafka Consumer?

```java
package com.example.kafka.consumer;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class OrderConsumer {

    public static void main(String[] args) {

        // 1. Kafka Consumer Configuration
        Properties props = new Properties();

        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
                "broker1:9092,broker2:9092");

        props.put(ConsumerConfig.GROUP_ID_CONFIG,
                "order-processing-group");

        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG,
                "earliest");

        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG,
                "false"); // Manual offset commit

        props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG,
                "100");

        props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG,
                "30000");

        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringDeserializer");

        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringDeserializer");

        // 2. Create Kafka Consumer
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);

        // 3. Subscribe to topic
        consumer.subscribe(Collections.singletonList("orders"));

        try {
            // 4. Poll loop
            while (true) {
                ConsumerRecords<String, String> records =
                        consumer.poll(Duration.ofMillis(100));

                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf(
                            "Received: topic=%s, partition=%d, offset=%d, key=%s, value=%s%n",
                            record.topic(),
                            record.partition(),
                            record.offset(),
                            record.key(),
                            record.value()
                    );
                }

                // 5. Commit offsets manually after processing
                consumer.commitSync();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 6. Close consumer gracefully
            consumer.close();
        }
    }
}

```

- **group.id** Identifies the consumer group for coordination and offset tracking.
- Consumers in the same group share partitions. Load balancing (multiple consumers processing different partitions)
- Each group maintains its own offset. Different apps consuming the same topic independently.
- **auto.offset.reset (Offset Behavior)** What to do when no offset is committed
- earliest Start from the oldest message. Replay all data (e.g., analytics).
- latest (default) Start from new messages. Real-time apps
- none Throw exception if no offset exists. Strict offset control.
- **enable.auto.commit (Offset Management)** Whether to auto-commit offsets (can lead to duplicates).
- true (default) Automatically commit offsets periodically. Best-effort processing (some duplicates allowed).
- false Manual offset commits (commitSync()/commitAsync()). Exactly-once processing (critical apps).
- **max.poll.records (Batch Size)** Max records returned in a single poll() call.
- Smaller batches → Lower latency. Real-time apps.
- Larger batches → Higher throughput. Batch processing.
- **max.poll.interval.ms (Consumer Liveness)** Max time between poll() calls before being considered dead.
- **session.timeout.ms & heartbeat.interval.ms (Consumer Health)**
- session.timeout.ms (default: 10s) Time to detect consumer failure. Adjust for slow networks.
- heartbeat.interval.ms (default: 3s) How often to send heartbeats. Must be < session.timeout.ms / 3.
- **fetch.min.bytes & fetch.max.wait.ms** Control how much data is fetched per request.
- fetch.min.bytes (default: 1) Min bytes to wait for.
- fetch.max.wait.ms (default: 500) Max time to wait for fetch.min.bytes.
- **isolation.level (Read Committed)** Control visibility of transactional messages.
- read_uncommitted (default) See all messages (even aborted ones)
- read_committed Only see committed messages.
- **partition.assignment.strategy (Rebalance Control)**
- Range (default) Static range-based assignment. Simple but can be unbalanced.
- RoundRobin Evenly distributes partitions. Better for small consumer groups.
- Sticky Minimizes reassignment. Best for frequent rebalances.
- **key.deserializer & value.deserializer** Deserializers for keys and values.

- **consumer Tuning**
  | Goal | Key Configs |
  | ----------------------- | --------------------------------------------------------------|
  | Exactly-Once Processing | `enable.auto.commit=false`, `isolation.level=read_committed` |
  | High Throughput | `fetch.min.bytes=1MB`, `max.poll.records=500` |
  | Low Latency | `fetch.min.bytes=1`, `max.poll.records=1` |
  | Avoid Rebalance Issues | `session.timeout.ms=30s`, `max.poll.interval.ms=5m` |

=========================================================================================

# How does kafka handle message size limits?

- Kafka has configurable message size limits. The default maximum message size is 1MB, but this can be increased by
  changing the 'message.max.bytes' configuration on the broker and the 'max.request.size' on the producer. However ,
  very large messages can impact performance and memory usage. So its generally recommended to keep messages relativey
  small.

# What is the purpose of idempotent producer in kafka?

- The idempotent producer in kafka ensures that messages are delivered exactly once to a partition, even in case of
  retries. It achieves this by assigning a unique ID to each producer request and maintaining a sequence number for
  each producer-partition pair. This prevents duplicate messages due to network issues or producer issues.

# How does Kafka support scalability?

- Kafka supports scalability through partitioning and distributed processing. Topics can be partitioned across multiple
  brokers, allowing for parallel processing.
- Consumers can be grouped to read from multiple partitions simultaneously.
- Brokers can be added to cluster to increase capacity and the cluster can be scaled without downtime.

# How does kafka handle message delivery timeouts?

- Kafka producers can be configured with delivery timeouts . If a message cannot be successfully acknowledged with in
  this timeout period, the producer will consider the send failed and may retry (depending on configuration).
- On the consumer side, there is a max.poll.interval.ms setting that controls how long a consumer can go without polling
  before it is considered failed and a rebalance is triggered.

# How does kafka ensures fault tolerance?

- Kafka ensures fault tolerance through data replication. Each partition is replicated across a configurable number of
  servers for fault tolerance.
- One of the servers is designated as the leader, which handles all read and write requests for the partition, while the
  others are followers that passively replicate the leader.
- If the leader goes down, one of the followers can become leader and perform same operations.

# How does kafka handle message delivery semantics?

- Kafka supports three message delivery semantics
- At most once : Messages may be lost but are never redelivered.
- At least once : Messages are never lost but may be redelivered.
- Exactly once: Each message is delivered once and only once. The choice depends on the specific use case and can be
  configured through producer and consumer settings.

# How does kafka handle message deletion?

- Kafka does not delete messages individually. Instead, it uses a retention policy to manage message deletion.
- Messages are retained either for configurable amount of time or until the topic reaches a certain size.
- Once the retention limit is reached, Kafka deletes messages in bulk by removing whole segments of the log file.
- For more fine-grained control, Kafka also supports log compaction.

# What is the role of group co-ordinator in kafka?

- The group coordinator in kafka is responsible for managing consumer groups.
- It handles consumer group membership, assigns partitions to consumers within a group and manages offset commits.
- When a consumer joins or leaves a group, the group co-ordinator triggers a rebalance to reassign partitions among the
  remaining consumers.
- As part of Kafka 4 , Rebalance logic is enhanced? Please define what is it?

# How does kafka handle back pressure and slow consumers?

- Kafka uses consumer offsets; each consumer reads at its own pace.
- decouples producers and consumers.
- Messages can stay in kafka for the retention period, allowing slow consumers to catch up.
- However, if consumers fall too fat behind, data might expire before its consumed.

# How does kafka ensure message durability?

- Kafka ensures durability through
- *Disk Persistence*: Messages are written to disk as soon as they arrive.
- *Replication*: Topics have configurable replication factors. Data is replicated across brokers.
- *Acknowledgements*: 'acks = all' ensures a message is considered committed only when all replicas acknowledge it.
- *Write-ahead Log*: Kafka uses a commit log structure to store data.

# How do you understand about kafka  MirrorMaker?

- The MirrorMaker is a standalone utility for copying data from one apache cluster to another.
- The MirrorMaker reads data from original cluster topics and writes it to a destination cluster with the same topic
  name.
- The source and destination clusters are separate entities that can have various partition counts and offset values.

# How does kafka handle message ordering?

- Kafka guarantees order with in a partition.
- Messages sent by a producer to a particular topic partition will be appended in a the order they are sent.
- A Consumer instance will read records in the order they are stored in the log. However, there is no guarantee of the
  order across partitions.

# How does kafka handle data retention?

- Kafka handles data retention through configurable retention policies.
- These can be based on time (retain data for 7 days or size (retain upto 1GB per partition)).
- After the retention limit is reached, old messages are discarded.
- Kafka also supports log compaction for topics where only the latest value for each key is needed.

# How does kafka handle consumer offsets?

- Kafka maintains offsets for each consumer group per partition. These offsets represent the position of the consumer in
  the partition log.
- Consumers can commit these offsets either automatically (at configurable intervals) or manually.
- Kafka stores these offsets in a special kafka topic called `_consumer_offsets`, allowing consumers to resume from
  where they left off in case of restarts or failures.

# What is the role of the controller in a kafka cluster?

- The controller in a kafka cluster is a broker that has additional responsibilities for managing the overall state of
  cluster.
- It is responsible for electing partition leaders and managing the distribution of partitions across brokers, and
  handling administrative operations like adding or removing topics.
- If the controller fails, ZooKeeper helps elect a new controller among the brokers.
