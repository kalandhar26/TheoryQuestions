#### var keyword (Java 11)

- Local variable type inference allows the compiler to infer the type of a local variable from its initializer, reducing
  verbosity while maintaining static typing.
- Eliminates redundant type declarations that clutter code without adding information (the "left-hand side duplication"
  problem). Particularly valuable for generic types with long type signatures, improving readability while preserving
  compile-time type safety.

#### Sealed classes (Java 17)

- A sealed class or interface restricts which other classes or interfaces may extend or implement it, providing
  fine-grained control over inheritance hierarchies.
- Addresses the fragile base class problem and exhaustiveness checking in pattern matching. Before sealed classes, any
  class could be extended anywhere, making it impossible to reason about all possible subtypes. Now the compiler knows
  the complete domain, enabling total pattern matching and preventing unauthorized extensions.

#### Pattern Matching for Switch (Java 17)

- Extends switch expressions to support pattern matching, allowing type-based selection with automatic destructuring and
  null handling.
- Replaces verbose visitor patterns and instanceof chains with declarative, exhaustively-checkable control flow. Solves
  the "expression problem" elegantly—adding new operations without modifying existing classes.

#### Records (Java 17)

- A compact class declaration for immutable data carriers, automatically generating constructors, accessors, equals(),
  hashCode(), and toString().
- Eliminates boilerplate in data-centric classes (DTOs, messages, configuration). Records make the code's intent—"this
  is just data"—immediately visible. They also guarantee immutability and shallow structural equality by default,
  preventing common bugs from mutable state and incorrect equals() implementations.

#### Virtual Threads (Java 21)

- Lightweight, JVM-managed threads that are cheap to create and block, enabling millions of concurrent tasks without OS
  thread exhaustion.
- Solves the thread-per-request scalability ceiling. Traditional OS threads (~1MB stack, expensive context switch)
  limited concurrent connections to thousands. Virtual threads (~1KB stack, user-mode scheduling) allow the "one thread
  per connection" model to scale to millions, eliminating callback hell and reactive programming complexity for
  I/O-bound workloads.

#### Structured Concurrency (Java 25)

- An API (primarily StructuredTaskScope) that treats multiple concurrent subtasks as a single unit of work with defined
  entry/exit points, automatic cancellation propagation, and failure handling.
- Eliminates unstructured concurrency hazards: thread leaks, lost exceptions, zombie tasks, and difficult cancellation.
  Brings the clarity of structured programming (single entry/exit) to concurrent code, making it composable and
  reasoning about failure straightforward.

#### Scoped Value (Java 25)

- Immutable, inheritable data bindings that are bound for a specific scope (code execution block) and automatically
  available to all child threads, without the mutability and cleanup issues of ThreadLocal.
- Replaces ThreadLocal's mutability and memory leak risks with a functional, immutable model. Critical for virtual
  threads (ThreadLocal is too expensive per-virtual-thread) and for implicit context propagation (tracing, security,
  request metadata) across structured concurrency boundaries without polluting method signatures.
