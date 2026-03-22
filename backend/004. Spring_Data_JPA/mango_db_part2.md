1. What is MongoDB and how is it different from a relational database?
   MongoDB is a document‑oriented NoSQL database that stores data as BSON documents (similar to JSON) inside
   collections. Unlike relational databases, it does not enforce a fixed schema and does not require joins. It scales
   horizontally via sharding and emphasizes performance and developer productivity. Relationships are denormalized
   using embedded arrays or references instead of foreign‑key constraints.

2. Explain the core concepts: database, collection, document, and BSON.
   A database is a logical container for collections. A collection is a group of documents, similar to a table in RDBMS
   but without a fixed schema. A document is a data record in key‑value format, stored in BSON (Binary JSON). BSON
   supports richer types (e.g., ObjectId, Date, Binary) and allows efficient indexing and querying.

3. What is a replica set in MongoDB? How does it help with high availability?
   A replica set is a group of MongoDB servers that maintain the same data set, with one primary and multiple
   secondaries. Clients write to the primary and read from the primary or secondaries. If the primary fails, an
   automatic election promotes a secondary to primary. This ensures continuous availability and data redundancy.

4. How does MongoDB handle sharding? What role does the config server and mongos play?
   Sharding distributes data across multiple shards based on a shard key. The config servers store metadata about which
   chunks belong to which shards. The mongos router processes client queries, routes them to the correct shards, and
   merges results. This allows horizontal scaling for large, high‑throughput workloads.

5. What is the difference between a capped collection and a normal collection?
   A capped collection has a fixed size and behaves like a circular buffer. When it reaches its size limit, oldest
   documents are automatically overwritten. Insert order is preserved, and capped collections support high‑throughput
   logging and time‑series‑like use cases. Normal collections grow dynamically and support arbitrary deletes and
   updates.

### Collections & Schemas

1. How do you create a collection in MongoDB? When is it created implicitly?
   You can create a collection explicitly using db.createCollection("name") or let it be created implicitly when
   inserting
   the first document into that collection. In Spring Boot, the collection is usually created automatically when the
   first
   entity is saved via MongoRepository or MongoTemplate. You can also specify options like size or validation in the
   options.

2. What is the relationship between a Java @Document POJO and a MongoDB collection?
   A Java class annotated with @Document(collection = "orders") maps to a MongoDB collection named orders. Each instance
   of
   the class becomes a document in that collection. Spring Data MongoDB uses MongoConverter to serialize the object into
   BSON and deserialize it back. The _id field typically maps to the @Id‑annotated field.

3. How do you choose between embedding vs referencing documents in a schema?
   Embed documents when the data is small, frequently read together, and changes less often (e.g., an address inside a
   user). Use references when the data is large, shared across many parents, or updated independently (e.g., many orders
   referencing a product). Embedding reduces joins but can cause duplication; referencing keeps data normalized but
   requires $lookup‑like stages.

4. What are the pros and cons of schema‑less design in MongoDB?
   Pros: flexible schema, easy evolution, and quick iteration for microservices. You can add fields per document without
   migrations. Cons: no enforced constraints, harder to document schema, and risk of inconsistent data if not
   controlled.
   You still need discipline through application‑level validation and evolving ODM mappings.

5. How would you model a one‑to‑many relationship vs a many‑to‑many relationship in MongoDB?
   For one‑to‑many, either embed the “many” as an array inside the “one” or store references using an array of ObjectId.
   For many‑to‑many, store references in both sides (e.g., userIds in orders and orderIds in users) or maintain a
   separate
   linking collection. Aggregation $lookup can then join them on demand.

### CRUD Operations (Mongo Shell & Java)

1. Write a MongoDB shell command to insert a document and then upsert it.
   Insert: db.users.insertOne({ name: "Alice", email: "alice@example.com" }).
   Upsert update: db.users.updateOne({ email: "alice@example.com" }, { $set: { phone: "+123456789" } }, { upsert:
   true }).
   With upsert: true, MongoDB will insert a new document if no match is found or update the existing one.

2. How do you perform a bulk insert in MongoDB using the Java driver?
   Use MongoCollection<Bson> with insertMany() or Spring Data’s MongoTemplate.insertAll()/MongoRepository.saveAll().
   In Java driver, create List<Document> and call getCollection("users").insertMany(docs).
   This reduces round‑trips and improves performance for large datasets.

3. What is the difference between update and updateMany? When would you use each?
   updateOne (or legacy update) modifies at most one matched document; updateMany updates all matching documents.
   Use updateOne when you want to change a single specific document (e.g., by _id). Use updateMany for bulk‑like
   updates (
   e.g., marking all expired entries as inactive).

4. How do you perform a conditional update with array operators (e.g., $push, $addToSet)?
   Use $push to add an element to an array, even if duplicates are allowed. Use $addToSet to add only if not already
   present.
   Example: { $push: { tags: "java" } } or { $addToSet: { tags: "mongodb" } }.
   Combine with $ or $[<identifier>] to target array elements by position or condition.

5. How do you delete a document vs delete multiple documents vs drop an entire collection?
   Delete one: db.collection.deleteOne({ _id: ObjectId("...") }).
   Delete many: db.collection.deleteMany({ status: "draft" }).
   Drop collection: db.collection.drop(), which deletes all documents and indexes. Use delete operations for selective
   cleanup and drop only when the whole collection is no longer needed.

6. How do you implement soft‑delete in MongoDB and map it in Spring Boot entities?
   Store a deleted or status field (e.g., boolean or enum) instead of physically removing the document.
   In Java, add a @Field("deleted") private boolean deleted and expose helper methods like markAsDeleted().
   Use query filters like deleted: false in your repository/custom queries and aggregation pipelines.

7. What does the upsert flag do in an update operation?
   When upsert is true, MongoDB inserts a new document if no matching document exists, using the query filter and update
   fields.
   It is useful for idempotent operations such as “set this configuration” or “update user profile if exists, else
   create”.
   But be cautious with compound filters to avoid unintended multiple inserts.

### Querying & Projections

1. How do you retrieve documents with a simple equality filter vs a range filter?
   Equality: db.users.find({ name: "Alice" }).
   Range: db.users.find({ age: { $gte: 18, $lte: 65 } }).
   These filters are translated in Spring Data using Criteria.where("age").gte(18).lte(65).

2. How do you use $in, $and, $or, and $not in MongoDB queries?
   $in matches any value in the given array: { status: { $in: [ "active", "pending" ] } }.
   $and is implicit for multiple fields; $or is explicit for disjunctions.
   $not negates a condition, e.g., { status: { $not: { $eq: "deleted" } } }.

3. How do you query arrays using $elemMatch and when do you use it?
   Use $elemMatch when you want to match multiple criteria on the same element of an array.
   Example: db.users.find({ addresses: { $elemMatch: { city: "Hyderabad", type: "home" } } }).
   Without $elemMatch, each condition can match any element, which may be too permissive.

4. How do you perform text search with a text index in MongoDB?
   First create a text index: db.collection.createIndex({ content: "text" }).
   Then use { $text: { $search: "keyword" } } in the query.
   In Spring Data, you can use @TextIndex annotations or TextCriteria with MongoTemplate.

5. How do you handle pagination using skip, limit, and sort in MongoDB?
   Query: db.collection.find().sort({ createdAt: -1 }).skip(10).limit(10) for page 2.
   In Java, you can use Sort.by(Sort.Direction.DESC, "createdAt").skip(10).limit(10) in MongoRepository.
   Avoid skip for deep pagination; use “next‑token” style with a cursor or range.

6. Why is skip + limit not recommended for deep pagination? What is an alternative?
   skip must scan all skipped documents, which becomes slow on large offsets. An alternative is to use a range‑based
   cursor (e.g., createdAt > lastSeenCreatedAt and limit(n)) or a cursor‑like field. This is more efficient as the index
   can seek directly to the start.

### Indexing & Query Performance

1. What is the role of indexes in MongoDB? How do they affect query performance?
   Indexes allow MongoDB to find and return documents quickly without scanning the entire collection. They speed up
   queries, sort operations, and joins ($lookup). But they consume extra disk space and slow down writes because they
   need to be updated. Good indexing is a balance between read and write performance.

2. What are the different types of indexes in MongoDB (single‑field, compound, multikey, text, geo, TTL)?
   Single‑field: on one field.
   Compound: on multiple fields, useful for queries with multiple conditions.
   Multikey: on array fields. Text: for full‑text search. Geo: for geospatial queries. TTL: auto‑deletes documents after
   a
   time. Each supports different access patterns.

2. Explain the difference between a single‑field and a compound index. How does key order matter?
   A single‑field index is straightforward for queries on that field only. A compound index is ordered; the order of
   fields
   affects which queries can use the index. For example, an index on { a: 1, b: 1 } can support a‑only queries but not
   b‑only queries efficiently. Leftmost prefix rules apply.

3. How do you create an index in MongoDB, and how do you verify if a query is using that index?
   Use db.collection.createIndex({ field: 1 }) or Spring Data’s @Indexed annotation.
   Run the query with .explain("executionStats") to see IXSCAN vs COLLSCAN.
   In Spring Data, enable query logging or use mongoTemplate’s explain()‑like pattern.

4. What is a covered query? How can you design an index to support one?
   A covered query returns data entirely from the index without touching the document. For example, an index { a: 1, b:
   1 }
   can cover { a: 1, b: 1, _id: 0 } projections. To design one, include all projected fields in the index and ensure the
   query filters are satisfied by the index.

5. What happens if an index does not fit into RAM? How does it impact performance?
   If the index is larger than available RAM, parts of it must be read from disk, increasing latency and I/O. Frequently
   used parts may stay in RAM, but cold parts cause spikes. Large indexes can also increase recovery time and storage
   overhead.

6. How do you handle index build long‑running operations on a large collection?
   Use background: true to build indexes in the background so writes are not blocked.
   Consider building indexes during low‑traffic periods or on a replica set primary.
   For very large collections, you can pre‑build indexes on a secondary and then promote it.

7. What is index hinting using the hint() method, and when would you use it?
   hint() forces MongoDB to use a specific index even if the planner chooses another.
   Use it when you know the data distribution better than the planner (e.g., for skewed queries).
   Misuse can hurt performance, so it should be used sparingly and validated with explain().

### Spring Data MongoDB in Java / Spring Boot

1. How do you configure Spring Data MongoDB to connect to a MongoDB instance in application.yml?
   In application.yml:

text
spring:
data:
mongodb:
uri: mongodb://localhost:27017/myapp
Or specify host, port, database, and authentication separately.
Spring Boot auto‑configures MongoClient, MongoTemplate, and repositories.

2. What is the role of MongoTemplate vs MongoRepository? When would you choose each?
   MongoRepository is a high‑level CRUD interface with query methods and derived queries.
   MongoTemplate is lower‑level, exposing the full MongoDB Java driver API (e.g., aggregations, custom operations).
   Use MongoRepository for simple CRUD and MongoTemplate for complex aggregations or custom logic.

3. How do you map a Java POJO to a MongoDB document using @Document, @Id, etc.?
   Mark the class with @Document(collection = "orders"), and the _id field with @Id.
   Other fields are mapped by name by default; use @Field("custom_name") to override.
   Spring Data handles serialization/deserialization using MongoConverter (e.g., MappingMongoConverter).

4. How would you implement a custom query using MongoTemplate and Criteria DSL?
   Use Criteria.where("status").is("ACTIVE").and("userId").is(userId) and pass it to Query.query(criteria).
   Then call mongoTemplate.find(query, Order.class, "orders").
   This is useful for dynamic queries that cannot be expressed as method names in MongoRepository.

5. How do you handle optimistic locking / versioning with MongoDB in Spring Boot (e.g., @Version)?
   Annotate a Long version field with @Version. Spring Data increments it on each update and validates it.
   If the client’s version is stale, the update fails (optimistic lock exception).
   This is useful for avoiding lost updates in concurrent scenarios without strong transactions.

6. How do you map MongoDB collections to multiple microservices without tight coupling at the schema level?
   Each microservice owns its own collections and contracts through its API.
   Avoid sharing the same domain objects directly; instead, define DTOs or events.
   Use clear ownership and eventual consistency rather than tight schema coupling.

7. How would you implement pagination and sorting in a Spring Boot REST API over MongoDB?
   Use Pageable in your MongoRepository methods: Page<Order> findByUserId(String userId, Pageable pageable).
   In the controller, accept page, size, and sort parameters and pass them to the repository.
   This integrates seamlessly with Spring Data’s built‑in pagination support.

### Aggregation Pipelines

1. What is an aggregation pipeline? Name the most common stages ($match, $group, $sort, $lookup, etc.).
   An aggregation pipeline is a sequence of stages that transform and analyze documents.
   Common stages: $match (filter), $group (aggregate), $sort (order), $lookup (join), $project (reshape), $unwind (
   de‑structure arrays).
   Each stage passes results to the next, enabling powerful analytics.

2. Write a sample pipeline to group documents by a field and calculate a sum (e.g., order totals).
   Example:

js
db.orders.aggregate([
{ $match: { status: "COMPLETED" } },
{ $group: { _id: "$customerId", total: { $sum: "$amount" } } }
])
This groups completed orders by customerId and sums the amount field.
In Java, you build this with Aggregation.newAggregation(...) and mongoTemplate.aggregate().

3. When and how would you use $lookup to perform a “join‑like” operation between two collections?
   Use $lookup when you need to enrich documents from one collection with data from another (e.g., orders + customers).
   Example:
   js
   { $lookup: { from: "customers", localField: "customerId", foreignField: "_id", as: "customer" } }
   It is useful for read‑only analytics or reporting in microservices.

4. How do you optimize an aggregation pipeline to avoid full‑collection scans and reduce memory usage?
   Use $match early to filter data and reduce the document set.
   Add relevant indexes on fields used in $match and $group.
   Avoid $unwind on large arrays unless necessary; consider restructuring or pre‑computing.

5. What is the role of $project and $addFields in an aggregation pipeline?
   $project reshapes documents by including, excluding, or renaming fields (e.g., hiding internal fields from the result).
   $addFields adds new computed fields without removing existing ones (e.g., totalWithTax).
   Together, they let you control the output shape and pre‑compute fields for downstream stages.

6. How do you perform multi‑level grouping and ranking (e.g., “top 3 customers by total amount”)?
   First group by a primary field (e.g., customerId) and sum the amount. Then $sort by total and $group again by a
   higher level (e.g., region) using $push to collect all customers. Finally $slice or $limit to keep top‑N within each
   group.
   This pattern works well for leaderboard‑style queries in microservices.

### Schema Design & Microservices

1. How would you design a MongoDB collection for a microservice that owns a bounded context (e.g., OrderService)?
   Model the collection around the domain aggregate root (e.g., Order), embedding related entities like items or
   addresses.
   Avoid cross‑service foreign keys; instead, store only IDs or minimal snapshot data (e.g., productId, productName).
   This keeps the microservice autonomous and loosely coupled.

2. When should you denormalize data in MongoDB for a microservice architecture?
   Denormalize when reads are frequent and read performance is critical (e.g., dashboards, search views).
   Embed commonly read‑together data (e.g., user name with their order) to avoid joins and reduce latency.
   Accept eventual consistency for updates in other services (e.g., via events or CQRS).

3. How do you handle eventual consistency and referential integrity when using MongoDB in a microservices ecosystem?
   Use event‑driven patterns (e.g., domain events, Kafka) to propagate changes between services.
   Each service updates its own copy of the data asynchronously, allowing temporary inconsistency.
   Design compensating actions or reconciliation jobs for critical constraints.

4. How do you model audit trails or event‑sourcing‑style data in MongoDB?
   Store events as documents in a capped or time‑series‑like collection, with fields such as eventType, aggregateId,
   timestamp, and payload.
   Use an index on aggregateId and timestamp for fast replay.
   Aggregate state can be rebuilt from events or cached in a separate “current state” collection.

5. How would you design a multi‑tenant application using MongoDB (e.g., per‑tenant collections vs per‑tenant documents)?
   For moderate tenant counts, store a tenantId field in each document and index it; this keeps the schema simple.
   For very large tenants or strict isolation, use separate databases or collections per tenant.
   Choose based on scalability, security isolation, and operational complexity.

### Performance & Advanced Optimizations

1. What are the key performance considerations when using MongoDB in a high‑volume microservice?
   Ensure proper indexing for all query patterns, avoid full‑collection scans, and keep documents reasonably sized.
   Use connection pooling, replica‑set‑aware reads, and appropriate write concerns.
   Monitor slow queries and aggregation pipelines, and tune shard keys for write distribution.

2. How do you monitor slow queries and aggregation pipelines in MongoDB?
   Enable slowOpThresholdMs and inspect the system.profile collection or use Atlas/Cloud tools.
   Use explain() with executionStats to see where time is spent (e.g., IXSCAN vs COLLSCAN).
   Export slow‑query logs and correlate them with application traces.

3. Explain how you would use explain() to analyze query plans and optimize them.
   Run db.collection.find(filter).explain("executionStats") to see the winning plan, index usage, and execution time.
   Check if the plan uses an index, how many documents are scanned, and how many are returned.
   Based on that, add or reorder index fields, rewrite filters, or push down projections earlier.

4. How do you decide the right shard key for a large, write‑heavy collection?
   Choose a shard key with high cardinality and low monotonicity (avoid timestamp‑only keys).
   Ensure even distribution of writes across shards to avoid “hot” shards.
   Prefer keys that are frequently queried, so the query can target individual shards efficiently.

5. How can you reduce the impact of hot shards or uneven data distribution?
   Re‑evaluate the shard key and, if possible, choose a composite key with more randomness.
   Pre‑split or pre‑tag chunks to distribute data more evenly.
   Use hashed sharding on a suitable field when the natural key is too sequential.

6. How do you optimize MongoDB connections and connection pooling when using Spring Boot with MongoDB?
   Configure maxPoolSize, minPoolSize, maxWaitTime, and serverSelectionTimeout in the connection URI or configuration.
   Avoid creating too many short‑lived connections; rely on the built‑in MongoClient‑managed pool.
   Use connection‑aware retry mechanisms and circuit‑breaker patterns for transient failures.

7. What are the best practices for using TTL (time‑to‑live) indexes for log or cache‑like data?
   Create a TTL index on a timestamp field (e.g., createdAt or expiresAt) and set an expireAfterSeconds value.
   Use this for session data, logs, or temporary caches so MongoDB automatically removes expired documents.
   Monitor index size and TTL cleanup to avoid unexpected performance hits.

8. How do you handle write‑concern and read‑concern levels in MongoDB for different use cases?
   For critical data (e.g., payments), use majority write concern and majority read concern.
   For non‑critical or high‑throughput writes, use acknowledged or unacknowledged depending on durability needs.
   Match read‑concern (e.g., local, majority) to consistency requirements and latency tolerance.

9. How do you minimize the amount of data transferred over the network in aggregation pipelines?
   Use $match and $project early to filter and trim only needed fields.
   Push down projections and aggregations to the database instead of transferring raw documents to Java.
   Avoid unnecessary $unwind or $lookup stages on large datasets.

10. What are the trade‑offs between using a MongoDB‑native aggregation pipeline vs filtering in Java code?
    MongoDB aggregation pipelines run close to the data, reducing network traffic and leveraging indexes.
    Filtering in Java code gives more flexibility but can transfer large intermediate results and miss index
    optimizations.
    Prefer aggregation for large‑volume data; use Java filtering only for small datasets or complex logic not
    expressible in
    pipelines.

11. How would you design a microservices‑friendly caching layer sitting on top of MongoDB?
    Use a distributed cache (e.g., Redis) to store frequently accessed domain objects or read‑only views.
    Populate or invalidate cache entries via events or direct updates from the service.
    Keep MongoDB as the source of truth and cache only hot, read‑heavy data to reduce load on the database.