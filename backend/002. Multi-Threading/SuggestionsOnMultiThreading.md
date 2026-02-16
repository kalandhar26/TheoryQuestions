### Proper Thread Management (Production Reality)

**In real systems:**
❌ Don’t create threads manually
❌ Don’t use extends Thread
❌ Don’t spawn unlimited threads
**Instead:**

✔ Use ExecutorService
✔ Use ThreadPoolExecutor
✔ Use CompletableFuture
✔ Use parallel streams cautiously

### When to Use Threads?

**Use threads when:**

- CPU intensive tasks
- Parallel processing
- Background tasks
- IO-bound operations
- Microservices request handling

**Avoid threads when:**

- Simple sequential logic
- Shared mutable state heavy systems
- Blocking calls without pooling

| Situation              | What To Use        |
|------------------------|--------------------|
| Small demo             | Thread + Runnable  |
| Real application       | ExecutorService    |
| Async chaining         | CompletableFuture  |
| High throughput server | ThreadPoolExecutor |
| Reactive system        | Project Reactor    |

We can go into:

- Thread pool internals
- Context switching cost
- CPU core mapping
- Java Memory Model
- Deadlock detection
- Executor tuning for performance
- Designing thread-safe microservices
- thenCompose vs thenCombine deep difference
- Thread starvation problem
- Performance tuning