## 1. There are two threads A and B operating on a shared Resource R. A needs to inform B that some important changes has happened in R. What technoique would you use in java to achieve?

### **1. Using wait() and notify()/notifyAll()**

- This is a classic Java mechanism for inter-thread communication using the intrinsic lock of the shared resource

```java
class Resource {
    private boolean hasChanged = false;

    public synchronized void updateResource() {
        // Thread A updates resource R
        hasChanged = true;
        notify(); // Notify Thread B
    }

    public synchronized void processResource() throws InterruptedException {
        while (!hasChanged) {
            wait(); // Thread B waits for changes
        }
        // Process the updated resource
        hasChanged = false; // Reset flag
    }
}
```

- Thread A calls updateResource(), modifies R, sets a flag, and calls notify() to wake up Thread B. Thread B, in processResource(), waits using wait() until notified. The synchronized keyword ensures mutual exclusion.
- Use notifyAll() instead of notify() if multiple threads are waiting, to avoid missing notifications.

### **2. Using Condition with ReentrantLock**

- A more flexible approach using Java’s java.util.concurrent.locks package.

```java
import java.util.concurrent.locks.*;

class Resource {
    private final ReentrantLock lock = new ReentrantLock();
    private final Condition condition = lock.newCondition();
    private boolean hasChanged = false;

    public void updateResource() {
        lock.lock();
        try {
            // Update resource R
            hasChanged = true;
            condition.signal(); // Notify Thread B
        } finally {
            lock.unlock();
        }
    }

    public void processResource() throws InterruptedException {
        lock.lock();
        try {
            while (!hasChanged) {
                condition.await(); // Wait for changes
            }
            // Process the updated resource
            hasChanged = false; // Reset flag
        } finally {
            lock.unlock();
        }
    }
}
```

- Similar to wait()/notify(), but uses a ReentrantLock and Condition for more explicit control over locking. Thread A signals Thread B using condition.signal(), and Thread B waits using condition.await().

- Always use try-finally to ensure the lock is released.

### **3. Using BlockingQueue**

- If the communication involves passing specific updates or messages about the resource, a BlockingQueue can be used.

```java
import java.util.concurrent.*;

class Resource {
    private final BlockingQueue<String> queue = new LinkedBlockingQueue<>();

    public void updateResource() {
        // Update resource R
        queue.offer("Resource Updated"); // Notify Thread B
    }

    public void processResource() throws InterruptedException {
        String message = queue.take(); // Blocks until message is available
        // Process the updated resource
        System.out.println("Received: " + message);
    }
}
```

- Thread A places a message in the queue, and Thread B blocks on take() until a message is available.
- Ideal for producer-consumer patterns where updates are events or messages. Simplifies communication when the resource change itself is complex.
- Use a bounded queue if you need to limit memory usage.

### **4.Using CountDownLatch or CyclicBarrier**

- If Thread A needs to signal Thread B exactly once (or a fixed number of times), a CountDownLatch can be used.

```java
import java.util.concurrent.*;

class Resource {
    private final CountDownLatch latch = new CountDownLatch(1);

    public void updateResource() {
        // Update resource R
        latch.countDown(); // Signal Thread B
    }

    public void processResource() throws InterruptedException {
        latch.await(); // Wait for signal
        // Process the updated resource
    }
}
```

- Thread A calls countDown() after updating R, and Thread B waits on await() until the latch reaches zero.
- Suitable for one-time or fixed-number notifications, such as initialization completion. Use CyclicBarrier if the signaling needs to be reusable.

----------------------------------------------------------------------------


## 2. Design and implement a pure-Java order-processing subsystem that must satisfy the following non-functional and functional requirements: **Continuous Ingestion** Accept an unbounded stream of Order objects that arrive in real time. **Categorisation** Every Order carries a type field (e.g., “electronics”, “books”, “groceries”). The system must group orders by this type at runtime. **Sequential Consistency per Type** All orders that share the same type must be processed strictly in the order they arrive (FIFO). **Parallelism across Types** Orders of different types may be processed concurrently to maximise throughput.**Horizontal Elasticity** Order Volume: if millions of orders arrive, processing threads must scale up without manual tuning.**Type Cardinality:** new order types can appear at any moment; the system must automatically create the necessary processing resources without restart or code change. **Graceful Degradation** When traffic subsides, unused resources (threads) must be released.

```java
/*
 *  Main.java
 *
 *  A minimal, pure-Java 17 demonstration of a scalable order-processing engine.
 *
 *  Functional guarantees
 *  ---------------------
 *  1. Orders of the SAME type are always handled sequentially (FIFO).
 *  2. Orders of DIFFERENT types are handled concurrently.
 *  3. New types can appear at any moment – the system spins up a new worker
 *     automatically (no restarts, no code changes).
 *  4. The number of concurrent “type workers” grows and shrinks with the
 *     actual number of active order types (horizontal scalability).
 *
 *  Architectural overview
 *  ----------------------
 *  OrderProcessor
 *      └─ maintains one PerTypeWorker per distinct order type
 *         └─ each worker runs a single dedicated thread that drains
 *            a private LinkedBlockingQueue sequentially
 *
 *  Threading model
 *  ---------------
 *  - A shared cached thread pool (Executors.newCachedThreadPool) supplies
 *    the threads.  The pool reuses previously constructed threads and
 *    creates new ones on demand, so the JVM never blocks waiting for threads.
 *  - Every worker thread is named “TypeWorker-<hash>” for easy debugging.
 *
 *  Lifecycle
 *  ---------
 *  start()      – currently a no-op; workers are created lazily.
 *  submit()     – non-blocking call that places the order in the appropriate
 *                 per-type queue (creates the queue+worker if absent).
 *  shutdown()   – pushes a POISON pill to every worker, then shuts the pool
 *                 down gracefully (max 10 s wait).
 *
 *  Extensibility
 *  -------------
 *  - Replace the Consumer<Order> businessLogic in the constructor to plug in
 *    real domain logic (payment, inventory, shipping, …).
 *  - Swap LinkedBlockingQueue for a ring-buffer if ultra-low latency is
 *    required.
 *  - Add metrics by exposing queue size or processing latency counters.
 */

import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;
import java.util.function.Consumer;

public class Main {
    public static void main(String[] args) throws Exception {
        OrderProcessor proc = new OrderProcessor();
        proc.start();

        // Simulate 10 000 orders across 5 types
        Random rnd = new Random();
        for (int i = 0; i < 10_000; i++) {
            String type = "TYPE-" + rnd.nextInt(5);
            proc.submit(new Order(UUID.randomUUID().toString(), type, "payload-" + i));
        }

        Thread.sleep(2_000);
        proc.shutdown();
    }
}

/* ---------- Immutable value object representing an order ---------- */
record Order(String id, String type, Object payload) {}

/* ---------- Public façade for submitting orders ---------- */
final class OrderProcessor {

    /* Map from order-type → single-thread worker that handles that type */
    private final ConcurrentMap<String, PerTypeWorker> workers = new ConcurrentHashMap<>();

    /* Actual business logic to execute for each order */
    private final Consumer<Order> businessLogic;

    /* Shared thread pool; each worker borrows one thread from here */
    private final ExecutorService globalPool;

    /* Guard to reject new orders after shutdown() */
    private final AtomicBoolean running = new AtomicBoolean(true);

    /* Convenience ctor with a no-op business logic */
    public OrderProcessor() {
        this(order -> {
            // Simulate real work
            try { Thread.sleep(10); } catch (InterruptedException ignored) {}
            System.out.println(Thread.currentThread().getName() + " processed " + order);
        });
    }

    /* Custom business logic supplied by caller */
    public OrderProcessor(Consumer<Order> businessLogic) {
        this.businessLogic = businessLogic;
        this.globalPool = Executors.newCachedThreadPool(r -> {
            Thread t = new Thread(r, "TypeWorker-" + r.hashCode());
            t.setDaemon(true);                // JVM can exit even if threads are alive
            return t;
        });
    }

    /* Optional explicit start – currently a no-op because workers start lazily */
    public void start() { }

    /**
     * Thread-safe, non-blocking submission.
     * Creates a new PerTypeWorker on first sight of a new type.
     */
    public void submit(Order order) {
        if (!running.get()) throw new IllegalStateException("Processor shut down");
        workers.computeIfAbsent(order.type(),
                                t -> new PerTypeWorker(t, businessLogic, globalPool))
               .enqueue(order);
    }

    /**
     * Graceful shutdown: send POISON pill to every worker,
     * then wait (max 10 s) for the global pool to terminate.
     */
    public void shutdown() throws InterruptedException {
        if (running.compareAndSet(true, false)) {
            workers.values().forEach(PerTypeWorker::shutdown);
            globalPool.shutdown();
            globalPool.awaitTermination(10, TimeUnit.SECONDS);
        }
    }

    /* ---------- Worker dedicated to ONE order type ---------- */
    private static final class PerTypeWorker {
        /* Unbounded, thread-safe queue holding orders for this type */
        private final BlockingQueue<Order> queue = new LinkedBlockingQueue<>();

        /* Handle returned by the thread-pool so we can cancel/interrupt */
        private final Future<?> runner;

        /* Sentinel object signalling the worker to exit */
        private static final Order POISON = new Order(null, null, null);

        PerTypeWorker(String type,
                      Consumer<Order> logic,
                      ExecutorService pool) {

            /* Submit the worker’s main loop to the shared pool */
            runner = pool.submit(() -> {
                while (true) {
                    try {
                        Order o = queue.take();   // blocks when idle
                        if (o == POISON) break;   // graceful exit
                        logic.accept(o);          // sequential processing
                    } catch (InterruptedException ignored) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                }
            });
        }

        /* Enqueue another order; never blocks */
        void enqueue(Order o) { queue.add(o); }

        /* Push POISON pill then cancel the underlying task */
        void shutdown() {
            queue.add(POISON);
            runner.cancel(true);   // interrupt if still waiting in take()
        }
    }
}
```
---------------------------------------------------
- **Another Simpler way**

```java
import java.util.UUID;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.*;

public class Main {
    public static void main(String[] args) throws InterruptedException {
        OrderDispatcher dispatcher = new OrderDispatcher();

        String[] types = {"FOOD", "BOOK", "CLOTHES", "GADGET"};

        for (int i = 0; i < 20; i++) {
            String type = types[i % types.length];
            Order order = new Order(UUID.randomUUID().toString(), type, "Details " + i);
            dispatcher.dispatch(order);
            Thread.sleep(100); // simulate streaming delay
        }

        // Keep system alive to process
        Thread.sleep(10000);
        dispatcher.shutdown();
    }
}



class Order {
    private final String orderId;
    private final String type;
    private final String details;

    public Order(String orderId, String type, String details) {
        this.orderId = orderId;
        this.type = type;
        this.details = details;
    }

    public String getOrderId() { return orderId; }
    public String getType() { return type; }
    public String getDetails() { return details; }

    @Override
    public String toString() {
        return "Order{" + "orderId='" + orderId + "', type='" + type + "', details='" + details + "'}";
    }
}


class OrderProcessor implements Runnable {
    private final BlockingQueue<Order> queue;

    public OrderProcessor(BlockingQueue<Order> queue) {
        this.queue = queue;
    }

    @Override
    public void run() {
        try {
            while (true) {
                Order order = queue.take(); // blocks if empty
                process(order);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private void process(Order order) {
        System.out.println("Processing: " + order + " by " + Thread.currentThread().getName());
        try {
            Thread.sleep(500); // simulate processing delay
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}


class OrderDispatcher {
    private final ConcurrentMap<String, BlockingQueue<Order>> typeQueues = new ConcurrentHashMap<>();
    private final ExecutorService executor = Executors.newCachedThreadPool();

    public void dispatch(Order order) {
        typeQueues.computeIfAbsent(order.getType(), type -> {
            BlockingQueue<Order> queue = new LinkedBlockingQueue<>();
            executor.submit(new OrderProcessor(queue));
            return queue;
        }).add(order);
    }

    public void shutdown() {
        executor.shutdown();
    }
}
```
-------------------------------------------------------

