## 1. How do you design idempotent Rest API? Why does it matter?

## 2. How do you handle partial failures in chained APIs or in distributed systems?

## 3. What HttpStatus codes are commonly misused?

## 4. How do you validate request payloads at scale?

## 5. How do you prevent over-fetching?

## 6. How do you version APIs without breaking clients? What are the trade-offs of each versioning strategy?

## 7. Where should mapping logic live - controller or service?

## 8. How do you design a RESP API that remains backward compatible as it evolves?

## 9. How do you test APIs without mocking everything?

## 10. What is difference between PUT and PATCH?

## 11. How are HTTP methods Categorized?

- Safe Methods (e.g., GET, HEAD) – Only retrieve data, no server changes.
- Idempotent Methods (e.g., PUT, DELETE) – Repeated requests have the same effect as one.
- Non-Idempotent Methods (e.g., POST, PATCH) – Each request may cause different effects.

## 12. How are HTTP Status Categorized?

### HTTP Status Code Categories

1. **1xx (Informational)** – Request received, continuing process.
2. **2xx (Success)** – Request successfully processed.
3. **xx (Redirection)** – Further action needed to complete the request.
4. **4xx (Client Error)** – Request contains an error (e.g., invalid data).
5. **5xx (Server Error)** – Server failed to fulfill a valid request.

## 13. What is Statelessness in RESTful Web Services?

- Statelessness means the server does not store any client state between requests. Each request from the client must
  contain all necessary information for the server to process it.
- Key Points:
  ✅ No Server-Side Sessions – The server does not maintain client data (e.g., session state).
  ✅ Client Provides Context – Every request must include all required data (e.g., tokens, IDs).
  ✅ Scalability & Reliability – Servers can handle requests independently, improving performance.
- Instead of server-stored sessions, the client sends an authentication token (JWT) in each request.
- The server validates the token without storing session data.

## 14. What is Addressing in RESTful Web Services?

- Addressing refers to how resources are located and identified on the server using URIs (Uniform Resource Identifiers).

## 15. What are core Components of an HTTP Request?

- **HTTP Method (Verb)**: Defines the action (e.g., GET, POST, PUT, DELETE).
- **URI (Uniform Resource Identifier)**: Identifies the resource (e.g., /api/users/123).
- **HTTP Version**:Specifies protocol version (e.g., HTTP/1.1 or HTTP/2).
- **Request Headers**: Metadata in key-value pairs (e.g., Content-Type: application/json, Authorization: Bearer token).
- **Request Body (Optional)**:Contains data sent to the server (e.g., JSON payload for POST/PUT).

## 16. What are Core Components of an HTTP Response

- **Status Code**: Indicates request success/failure (e.g., 200 OK, 404 Not Found, 500 Server Error).
- **HTTP Version**: Protocol version (e.g., HTTP/1.1).
- **Response Headers**: Metadata (e.g., Content-Type: application/json, Cache-Control: no-store).
- **Response Body (Optional)**:Contains the requested data or error details (e.g., JSON response).

## 17. How do you expose a springboot microservices over HTTPs?

- Add SSL cert (JKS file)
- configure application.properties

```properties
server.port=8080
server.ssl.enabled=true
server.ssl.key-store=classpath:keystore.jks
server.ssl.key-store-password={PASSWORD}
server.ssl.key-store-type=JKS
```

## 18. What factors influence your choice between REST, GraphQL and gRPC?

## 19. How would you design pagination for large, frequently changing datasets?

## 20. How do you structure error responses so they are useful for both developers and systems?

## 21. How do you design an API to support rate limiting without breaking client experience?

## 22. What security concerns do you consider first when designing a public API?

## 23. How do you design an API that needs to scale to millions of requests per seconds?

## 24. How do you decide between synchronous and asynchronous communication?

## 25. How do you design APIs that support extensibility without frequent breaking changes?

## 26. What role do HTTP status codes play in communicating API behavior to clients?

## 27. How would you design APIs to support multi tenant systems?

## 28. How would you handle long-running operations in API design?

## 29. How do you design APIs that are resilient to network latency and retries?

## 30. How do you design an API contract between microservices owned by different teams?

## 31. How do you approach API documentation so it stays accurate as the system evolves?

## 32. How do you measure whether an API design is successful in production?

## 33. What trade-offs do you consider when designing APIs for internal vs external consumers?