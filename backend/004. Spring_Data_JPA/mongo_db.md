1. What is MongoDB and how is it different from RDBMS?

- MongoDB is a NoSQL document database that stores data in JSON-like BSON format. Unlike RDBMS, it doesn’t use tables
  and
  rows but collections and documents. It is schema-flexible, meaning documents in the same collection can have different
  structures. It scales horizontally using sharding, unlike traditional vertical scaling in RDBMS. Joins are limited, so
  data is often denormalized. It’s optimized for high throughput and flexible data models.

2. What are collections and documents?

- A collection is similar to a table in RDBMS, and a document is like a row. Documents are stored in BSON format and can
  contain nested structures. Collections don’t enforce a strict schema. Each document can have different fields. This
  flexibility is useful but can lead to inconsistency if not managed properly. Collections are created automatically
  when
  inserting data.

3. What is BSON and how is it different from JSON?

- BSON (Binary JSON) is a binary-encoded format used internally by MongoDB. It supports additional data types like Date,
  ObjectId, and Binary which JSON doesn’t. BSON is optimized for storage and traversal. JSON is text-based, while BSON
  is
  compact and faster for machine processing. However, BSON increases storage slightly due to metadata.

4. What is _id field? Can we customize it?

- _id is a unique identifier automatically added to every document. By default, it’s an ObjectId. It ensures uniqueness
  within a collection. You can override it with your own value (like UUID or business key). Choosing custom _id impacts
  indexing and performance. Poor choice can create hotspots in sharding.

5. What are the data types supported in MongoDB?

- MongoDB supports types like String, Integer, Boolean, Double, Array, Object, Date, ObjectId, Binary, and Null. It also
  supports embedded documents. Special types like Decimal128 are used for precision. Choosing correct types is important
  for indexing and query performance. Wrong types can break queries or cause inefficiency.

6. Difference between embedded documents vs references?

- Embedded documents store related data within a single document. References store relationships using IDs across
  collections. Embedding improves read performance and avoids joins. References are better when data grows large or is
  reused. Trade-off: embedding = duplication, referencing = more queries. Choose based on access pattern, not theory.

7. What is a capped collection?

- A capped collection is a fixed-size collection that maintains insertion order. When size limit is reached, old
  documents
  are automatically overwritten. It behaves like a circular buffer. Useful for logs or streaming data. It does not
  support
  document deletion. It offers high write performance.

8. What is the default storage engine?

- The default storage engine is WiredTiger. It provides compression, concurrency, and journaling support. It uses
  document-level locking, improving performance over older engines. It supports snapshots for consistency. It is
  optimized
  for both read and write workloads. Almost all production systems use this.

9. What is journaling?

- Journaling ensures durability by writing operations to a log before applying them to data files. If a crash occurs,
  MongoDB can recover using the journal. It protects against data loss. It slightly impacts write performance. It’s
  enabled by default. Critical for production systems.

10. What is replica set?

- A replica set is a group of MongoDB nodes that maintain the same data. One node is primary (handles writes), others
  are
  secondary (replicate data). If primary fails, automatic election happens. It provides high availability and fault
  tolerance. Reads can be distributed to secondaries. Essential for production deployments.

11. How do you create a collection in MongoDB?

- Collections are created automatically when inserting the first document. You can also explicitly create using
  db.createCollection(). Options include capped collections and validation rules. Explicit creation is useful for
  setting
  constraints. Otherwise, MongoDB keeps it flexible.

12. Can MongoDB be schema-less? Then why schema design matters?

- MongoDB is schema-flexible, not schema-less. Without design, data becomes inconsistent and hard to query. Poor schema
  leads to performance issues. Schema design impacts indexing, query speed, and scalability. Good design is based on
  access patterns. Ignoring schema is a beginner mistake.

13. When do you use embedded documents vs references?

- Use embedded when data is accessed together and size is manageable. Use references when data is large, shared, or
  updated frequently. Embedding reduces joins and improves performance. References avoid duplication and reduce document
  size. Decision depends on read/write patterns.

14. What are schema design patterns?

- Common patterns include:
  Embedded pattern
  Reference pattern
  Bucket pattern (for time-series)
  Subset pattern (for large docs)
  Outlier pattern (handling rare large data)
  These patterns solve real-world problems like scaling and performance. Good schema design is pattern-driven, not
  random.

15. How do you handle one-to-many relationships?

- For small datasets → embed child documents. For large/unbounded → use references. Example: user → orders. Embedding
  works for few orders, not thousands. Always think about document size (16MB limit). Access pattern decides approach.

16. How do you model many-to-many relationships?

- Use references in both documents or a separate linking collection. Embedding is not practical due to duplication
  explosion. Queries may require multiple lookups. MongoDB is not ideal for heavy many-to-many joins. Design carefully
  or
  reconsider DB choice.

17. What is document growth problem?

- If a document grows beyond allocated space, MongoDB moves it. This causes fragmentation and performance overhead.
  Frequent updates to growing arrays cause this. It leads to disk I/O overhead. Avoid unbounded arrays. Use bucketing or
  referencing.

18. How do you avoid large document issues?

- Keep documents under control (<16MB limit). Avoid large arrays. Use subset pattern to split data. Move infrequently
  used
  data to separate collection. Monitor document growth. Large docs hurt performance and memory usage.

19. What is polymorphic schema design?

- It allows documents in the same collection to have different structures. Useful when entities share some fields but
  differ in others. Example: payment types (card, UPI, netbanking). It reduces number of collections. But querying
  becomes
  complex. Needs careful indexing.

20. How do you version your schema?

- Add a version field in documents. Handle logic in application layer. For major changes, migrate old data gradually.
  Avoid breaking existing queries. Backward compatibility is key. Schema evolution is continuous in microservices.

21. How do you insert a document?

- You use insertOne() or insertMany() to add documents into a collection. MongoDB automatically creates the collection
  if
  it doesn’t exist. Each document gets an _id field if not provided. Inserts are atomic at document level. In
  high-throughput systems, batch inserts are preferred. Write concern affects durability.

22. Difference between insertOne and insertMany?

- insertOne inserts a single document, while insertMany inserts multiple documents in one operation. insertMany is more
  efficient for bulk operations. It reduces network overhead. It can be ordered or unordered. Ordered stops on first
  failure; unordered continues. Bulk inserts improve performance significantly.

23. How do you query documents?

- You use find() with filters. Filters are JSON-like conditions. MongoDB supports operators like $eq, $
  gt, $in. Queries can include projections to limit fields. You can combine conditions using $and, $or. Efficient
  queries
  depend heavily on indexes. Without indexes, full collection scan happens.

24. Difference between find() and findOne()?

- find() returns a cursor (multiple documents), while findOne() returns a single document. findOne() stops after first
  match, so it’s faster. find() is used for iteration. Both accept filters. For large datasets, find() must be handled
  carefully to avoid memory issues.

25. How do you update documents?

- You use updateOne(), updateMany(), or replaceOne(). Updates use operators like $set, $inc. Without operators, it
  replaces entire document. Updates are atomic per document. Proper filtering is critical. Wrong filter can update
  unintended data.

26. What is $set, $inc, $push?

- $set: updates specific fields
- $inc: increments numeric value
- $push: adds value to array
- These operators avoid replacing entire document.
- They improve performance and reduce risk. Misusing them can lead to unexpected data structure changes.

27. Difference between update and replace?

- Update modifies specific fields using operators. Replace overwrites entire document except _id. Replace is risky
  because
  missing fields get deleted. Update is safer for partial changes. Replace is rarely used in production unless
  intentional.

28. What is upsert?

- Upsert = update + insert. If document exists → update. If not → insert new. Enabled using upsert: true. Useful for
  idempotent operations. Avoids extra read before write. But can create duplicates if not designed carefully.

29. How do you delete documents?

- Use deleteOne() or deleteMany(). Filters define which documents to remove. Deletion is permanent. Large deletes can
  impact performance. Soft delete (flag) is often preferred in real systems. Indexes help speed up deletion queries.

30. How do you handle partial updates in nested documents?

- Use dot notation like user.address.city.
- Combine with $set to update specific nested fields. Avoid replacing full nested object.
- Proper indexing on nested fields improves performance. Mistakes here can overwrite entire nested structure.

31. What is an index in MongoDB?

- An index is a data structure that improves query performance.
- It avoids full collection scan. MongoDB uses B-tree indexes.
- Indexes speed up reads but slow down writes. They consume extra storage. Choosing right indexes is critical.

32. Types of indexes?

- Single field
- Compound
- Multikey (arrays)
- Text
- Geospatial
- Each serves different use cases. Wrong index type leads to poor performance.
- Compound indexes are most common in real systems.

33. What is compound index ordering importance?

- Order matters because MongoDB uses left-prefix rule. Index {a:1, b:1} works for queries on a or a+b, but not b alone.
  Wrong order makes index useless. Always design index based on query patterns. This is a common interview trap.

34. What is covered query?

- A query is covered when all fields are satisfied by index alone. No need to fetch actual document. This makes queries
  extremely fast. Requires projection fields to be part of index. It reduces disk I/O.

35. What is index cardinality?

- Cardinality refers to uniqueness of values. High cardinality = many unique values (good for indexing). Low
  cardinality =
  repeated values (poor performance). Indexing low-cardinality fields may not help much. Combine with other fields if
  needed.

36. When should you NOT create an index?

**Avoid indexing:**

- Low cardinality fields
- Fields not used in queries
- Write-heavy collections
- Too many indexes slow down writes. Each insert/update must update indexes.
- Index blindly = bad design.

37. What is TTL index?

- TTL (Time-To-Live) index automatically deletes documents after a certain time.
- Used for logs, sessions, cache. Defined on a date field.
- MongoDB periodically cleans expired data. Helps manage storage automatically.

38. What is sparse index?

- Sparse index only indexes documents that contain the indexed field. Documents without the field are ignored. Saves
  space. Useful when fields are optional. But queries must be designed carefully.

39. What is partial index?

- Partial index indexes only documents that match a filter condition. More flexible than sparse index. Reduces index
  size.
  Improves performance. Useful for filtered queries like “active users only”.

40. How do indexes impact write performance?

- Each write must update all indexes. More indexes = slower writes. This is a trade-off. Read-heavy systems benefit from
  indexes. Write-heavy systems need minimal indexes. Balance is key. Over-indexing is a common mistake.

41. What is aggregation pipeline?

- Aggregation pipeline is a framework to process data through multiple stages. Each stage transforms documents and
  passes output to the next. It’s similar to SQL GROUP BY but more powerful. It supports filtering, grouping, reshaping,
  and joining. Pipelines are optimized internally. Complex analytics can be done without moving data to application.

42. Difference between aggregation and find?

- find() is for simple queries and returns raw documents.
- Aggregation allows transformations like grouping, projections,calculations. Aggregation is more powerful but heavier.
- find() is faster for simple lookups. Aggregation is used for reporting and analytics.
- Choosing wrong one impacts performance.

43. Explain $match, $group, $project

- $match: filters documents (like WHERE)
- $group: groups documents and performs aggregation (like GROUP BY)
- $project: reshapes output (select specific fields or computed fields)
- These are core stages. Order matters for performance. $match should come early to reduce data volume.

44. What is $lookup?

- $lookup performs a join between collections. It’s equivalent to left outer join. It brings related data from another
  collection. It can be expensive and slow. Not recommended for high-frequency queries. Prefer embedding when possible.

45. What is $unwind?

- $unwind deconstructs an array into multiple documents. Each array element becomes a separate document. Useful before
  grouping or filtering. It can explode data size. Must be used carefully.

46. What is $facet?

- $facet runs multiple pipelines in parallel on the same input. It’s used for multi-dimensional analysis.
- Example: pagination + count in one query. It avoids multiple round trips. But it increases memory usage.

47. How do you optimize aggregation pipeline?

- Use $match early
- Use $project to reduce fields
- Avoid unnecessary $lookup
- Use indexes for $match
- Limit results early ($limit)
- Aggregation without optimization can kill performance. Always check execution plan.

48. What is pipeline vs map-reduce?

- Aggregation pipeline is modern and faster. Map-reduce is older and uses JavaScript. Pipeline is optimized and
  recommended. Map-reduce is rarely used now. Interviews expect you to prefer aggregation.

49. What is $sort + $limit optimization?

- If $sort is followed by $limit, MongoDB can optimize by limiting sorted data. With index support, it avoids sorting
  entire dataset. Without index, sorting is expensive. Proper indexing makes this efficient.

50. When aggregation becomes a performance bottleneck?

- Large dataset without filtering
- Heavy $lookup joins
- Sorting without indexes
- Excessive $unwind
- High memory usage
- In such cases, move logic to application or redesign schema.

51. How do you connect MongoDB with Spring Boot?

- Use Spring Data MongoDB dependency. Configure connection via application.properties or config class.
- Spring Boot auto-configures MongoTemplate and repositories. Connection pooling is handled internally.
- You can customize using MongoClient settings.

52. What is Spring Data MongoDB?

- It’s a module that simplifies MongoDB integration in Spring. It provides repository abstraction and template-based
  access. It reduces boilerplate code. Supports query methods, aggregation, and transactions. It’s widely used in
  microservices.

53. Difference between MongoRepository and MongoTemplate?

- MongoRepository is high-level abstraction with auto-generated queries. Easy to use but limited flexibility.
- MongoTemplate is low-level and gives full control. Used for complex queries and aggregations. Real projects often use
  both.

54. When to use MongoTemplate over repository?

Use MongoTemplate when:

- Complex queries
- Aggregation pipelines
- Dynamic queries
- Bulk operations
- Repository is good for simple CRUD. Template is for control and performance.

55. How do you define a document in Spring Boot?

- Use @Document annotation on class. Fields are mapped automatically.
- @Id defines primary key. You can customize field names using @Field.
- Nested objects are supported. Mapping is handled automatically.

56. What is @Document, @Id, @Field?

- @Document: marks class as MongoDB document
- @Id: primary key field
- @Field: custom field name mapping
- These annotations define how Java objects map to MongoDB documents.

57. How do you create custom queries?

- Use @Query annotation or MongoTemplate. Queries are written in JSON-like format.
- You can also define method names for auto query generation.
- Complex queries require MongoTemplate. Aggregation is also supported.

58. How do you handle transactions in MongoDB?

- MongoDB supports multi-document transactions (from version 4.0).
- In Spring Boot, use @Transactional. Works only in replica sets.
- Transactions ensure ACID properties. But they impact performance. Use only when necessary.

59. Is MongoDB transaction fully ACID?

- Yes, MongoDB supports ACID transactions. But only within replica sets or sharded clusters.
- Single-document operations are already atomic.
- Multi-document transactions are heavier. Overusing transactions reduces performance.

60. How do you configure multiple MongoDB databases?

- Define multiple MongoTemplate beans. Use different configurations for each database.
- Use @Qualifier to inject specific template.
- Useful in microservices handling multiple data sources. Requires careful configuration.

61. Why is MongoDB good for microservices?

- MongoDB fits microservices because it allows flexible schema per service.
- Each service can evolve independently without strict schema migrations.
- It supports horizontal scaling via sharding. JSON-like structure aligns well with APIs.
- Fast development is possible. However, misuse leads to data inconsistency.

62. Should multiple services share the same database?

- No. Each microservice should own its database. Sharing DB creates tight coupling. Schema changes in one service break
  others. It violates microservices principles. Instead, use APIs or events for communication. Shared DB is a common
  anti-pattern.

63. How do you handle data consistency across services?

- Use eventual consistency with event-driven architecture. Services communicate via events (Kafka, etc.).
- Avoid distributed transactions. Use Saga pattern for multi-step workflows. Accept temporary inconsistency.
- Design for failure and retries.

64. How do you implement Saga pattern with MongoDB?

- Each service updates its own MongoDB and publishes an event. Next service listens and continues process. On failure,
  compensating transactions are triggered.
- MongoDB doesn’t manage Saga—it’s handled at application level. Requires careful
  event design.

65. How do you handle distributed transactions?

- Avoid them. MongoDB supports transactions but not across services. Use Saga or choreography. Break operations into
  smaller steps. Ensure idempotency. Distributed transactions reduce scalability and increase complexity.

66. How do you manage schema evolution across services?

- Use versioning in documents. Keep backward compatibility. Gradually migrate old data. Avoid breaking changes. Each
  service evolves independently. Use feature flags if needed. Schema evolution is continuous.

67. What is eventual consistency?

- Data becomes consistent over time, not instantly. Common in distributed systems. Improves scalability and
  availability.
  Requires careful handling of stale data. Users may temporarily see outdated data.

68. How do you design read vs write models?

- Use CQRS pattern. Write model optimized for writes (normalized or minimal).
- Read model optimized for queries (denormalized). MongoDB is ideal for read models. Improves performance and
  scalability.

69. How does MongoDB work with Kafka?

- MongoDB stores data, Kafka handles event streaming. Changes in MongoDB can be published as events. Consumers process
  events and update their own data. Ensures decoupling. Useful for real-time systems.

70. How do you handle idempotency?

- Use unique identifiers for operations. Store processed request IDs. Avoid duplicate writes. Use upserts where
  possible.
  Essential in event-driven systems. Prevents duplicate processing during retries.

71. How do you identify slow queries?

- Use MongoDB profiler and logs. Analyze query execution time. Use explain() to understand execution plan.
- Check if indexes are used. Monitor CPU, memory, and disk I/O. Slow queries often lack proper indexing.

72. What is explain() in MongoDB?

- explain() shows how MongoDB executes a query. It provides details like index usage, scanned documents, and execution
  time. Helps identify inefficiencies. Critical for performance tuning.

73. What is working set?

- Working set is the portion of data frequently accessed. It should fit in RAM. If it exceeds RAM, performance drops due
  to disk I/O. Proper indexing reduces working set size. Memory is key for MongoDB performance.

74. How does RAM impact MongoDB performance?

- More RAM = better performance. MongoDB caches data in memory. If data fits in RAM, queries are fast. If not, disk
  reads
  slow things down. RAM is often the biggest performance factor.

75. How do you optimize large collections?

- Use proper indexes
- Archive old data
- Use sharding
- Limit document size
- Optimize queries
- Large collections without strategy lead to slow queries. Design for scale early.

76. What is sharding?

- Sharding splits data across multiple servers. Enables horizontal scaling. Each shard holds part of data.
- Improves performance and storage capacity. Requires careful shard key selection.

77. What is shard key? How to choose it?

- Shard key determines how data is distributed. Should have high cardinality and even distribution. Avoid monotonically
  increasing values (hotspot issue).
- Bad shard key leads to uneven load. Choosing wrong shard key is a major failure point.

78. What is chunk migration?

- Chunks are data partitions in sharding. MongoDB moves chunks between shards to balance load. Happens automatically.
- Too frequent migrations affect performance. Balanced distribution is goal.

79. What are hotspots in sharding?

- Hotspot occurs when most writes go to one shard. Happens with poor shard key (like timestamp). Leads to uneven load.
  Causes performance bottlenecks. Must choose shard key carefully.

80. Difference between vertical vs horizontal scaling?

- Vertical scaling = increase resources (CPU, RAM) on single server. Horizontal scaling = add more servers (sharding).
  MongoDB supports horizontal scaling. Vertical scaling has limits. Horizontal scaling is more scalable.

81. What happens if primary node goes down?

- In a replica set, if the primary fails, secondaries elect a new primary automatically. This election takes a few
  seconds. During this time, writes are unavailable. Reads may still work depending on read preference. Applications
  must
  handle this failover gracefully.

82. How does replication work internally?

- MongoDB uses oplog (operation log). Primary writes operations to oplog. Secondaries continuously pull and apply these
  operations. Replication is asynchronous by default. There may be slight lag. Ensures high availability but not instant
  consistency.

83. What is write concern?

- Write concern defines acknowledgment level for writes. Example: w=1, w=majority.
- Higher write concern = more durability but slower writes.
- Critical systems use majority. Choosing wrong write concern risks data loss.

84. What is read preference?

- Defines where reads are served from:
- primary
- secondary
- nearest
- Reading from secondary improves scalability. But may return stale data. Trade-off between consistency and performance.

85. What is eventual vs strong consistency?

- Strong consistency = always latest data. Eventual consistency = data syncs over time.
- MongoDB provides strong consistency for primary reads. Secondary reads are eventually consistent. Choice depends on
  use case.

86. How do you prevent duplicate records?

- Use unique indexes. Enforce constraints at DB level. Use idempotent operations. Handle retries carefully.
- Application-level checks alone are not reliable. DB-level uniqueness is mandatory.

87. What is idempotent write?

- An operation that produces same result even if executed multiple times. Example: upsert with unique key. Important in
  distributed systems. Prevents duplicate data during retries. Essential for Kafka/event-driven systems.

88. How do you handle large file storage?

- Use GridFS. It splits large files into chunks and stores them. Useful for files >16MB limit. Not ideal for
  high-performance file serving. Often better to use object storage (S3) instead.

89. What are limitations of MongoDB?

- No complex joins like RDBMS
- Document size limit (16MB)
- Memory-heavy
- Requires careful schema design
- Transactions impact performance
- Choosing MongoDB blindly is a mistake.

90. When should you NOT use MongoDB?

**Avoid MongoDB when:**

- Strong relational data needed
- Heavy joins required
- Strict ACID across large transactions
- Complex reporting queries
- In such cases, RDBMS is better.

91. Design a user + orders system in MongoDB

- Don’t blindly embed everything. If orders are small and limited → embed in user. If large/unbounded → separate
  collection with userId reference. Index userId in orders. Optimize based on query pattern (user view vs order
  analytics).

92. Optimize a slow query on 10M records

- First run explain(). Check if index is used. Add or fix index. Reduce fields using projection. Avoid full collection
  scan. Consider pagination. If still slow → redesign schema or shard collection.

93. Design schema for high write system (logs/events)

- Use append-only design. Avoid updates. Use time-based partitioning (bucket pattern). Add TTL index for cleanup. Keep
  documents small. Avoid heavy indexing. Write throughput is priority.

94. How would you paginate large datasets?

- Use range-based pagination instead of skip/limit. Skip becomes slow for large offsets. Use indexed fields like _id or
  timestamp. Example: “fetch next 10 where id > lastId”. This scales better.

95. How to handle real-time analytics?

- Use aggregation pipelines for small scale. For large scale, push data to streaming system (Kafka) and process
  separately. MongoDB is not ideal for heavy analytics at scale. Use specialized tools if needed.

96. How to avoid N+1 problem?

- Avoid multiple queries per request. Use embedding or $lookup where necessary. Batch queries instead of looping
  queries. Poor design leads to performance issues.

97. Design audit logging system

- Use separate collection. Append-only writes. Include metadata (user, timestamp, action). Use TTL if retention needed.
  Avoid updating logs. Optimize for writes.

98. Handle duplicate message processing

- Use idempotency keys. Store processed message IDs. Use upsert operations. Ensure duplicate events don’t create
  duplicate data. Critical in event-driven systems.

99. Design caching strategy

- Use in-memory cache (Redis) for frequent reads. Cache aggregated data. Invalidate cache on updates. MongoDB alone is
  not enough for high-performance reads. Cache reduces DB load.

100. Debug production latency issue

**Check:**

- slow queries (explain)
- missing indexes
- high disk I/O
- memory pressure
- replication lag
- network latency
- Fix root cause, not symptoms. Most issues come from bad schema or indexing.