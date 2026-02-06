# Java Stream Methods

- Streams are introduced in java 8. They allow processing of collections in a functional style chaining multiple
  operations together.
- Streams do not store data, they process data.
- Streams are consumed once - you cannot reuse a stream after a terminal operation.
- Stream operations can be chained.
- prefer parallelStreams only when it can truly improve performance [large data + non-thread blocking code]

## Key Interfaces

- Stream<T>
- Instream, LongStream, DoubleStream

## Creation of Streams

| Method               | Description                                    | Example                          |
|----------------------|------------------------------------------------|----------------------------------|
| stream()             | Converts a collection into a sequential stream | list.stream()                    |
| parallelStream()     | converts collection into a parallel stream     | list.parallelStream()            |
| Stream.of(..)        | creates a stream from values                   | Stream.of(1,2,3)                 |
| Arrays.stream(array) | Creates a stream from a array                  | Arrays.stream(new int[] {1,2,3}) |

## Intermediate Operations (returns a new Stream, lazy evaluation)

- Intermediate Operations are lazy - no processing happens until a terminal operation is called.

| Method               | Description                                                                           | Example                                    |
|----------------------|---------------------------------------------------------------------------------------|--------------------------------------------|
| `filter(Predicate)`  | Keep only elements that satisfy the predicate                                         | `stream.filter(x -> x > 5)`                |
| `map(Function)`      | Transform each element with the provided function                                     | `stream.map(String::toUpperCase)`          |
| `flatMap(Function)`  | Flatten one-to-many structures into a single stream                                   | `stream.flatMap(list -> list.stream())`    |
| `distinct()`         | Remove duplicates (based on `equals()`)                                               | `stream.distinct()`                        |
| `sorted()`           | Sort by natural order                                                                 | `stream.sorted()`                          |
| `sorted(Comparator)` | Sort with a custom comparator                                                         | `stream.sorted(Comparator.comparing(...))` |
| `limit(n)`           | Truncate the stream to at most `n` elements                                           | `stream.limit(5)`                          |
| `skip(n)`            | Discard the first `n` elements                                                        | `stream.skip(3)`                           |
| `peek(Consumer)`     | Perform an action on each element without consuming the stream (mainly for debugging) | `stream.peek(System.out::println)`         |

## Terminal Operations (triggers Stream Processing)

| Method                   | Description                                                        | Typical Usage                                |
|--------------------------|--------------------------------------------------------------------|----------------------------------------------|
| `collect(Collector)`     | Gather elements into a collection or other container               | `stream.collect(Collectors.toList())`        |
| `forEach(Consumer)`      | Apply an action to each element                                    | `stream.forEach(System.out::println)`        |
| `toArray()`              | Convert the stream into an array                                   | `stream.toArray()`                           |
| `reduce(BinaryOperator)` | Combine elements into a single result via an associative operation | `stream.reduce(0, Integer::sum)`             |
| `count()`                | Count the number of elements                                       | `stream.count()`                             |
| `min(Comparator)`        | Return the smallest element according to the comparator            | `stream.min(Comparator.naturalOrder())`      |
| `max(Comparator)`        | Return the largest element according to the comparator             | `stream.max(Comparator.naturalOrder())`      |
| `anyMatch(Predicate)`    | Return `true` if **any** element matches the predicate             | `stream.anyMatch(x -> x > 0)`                |
| `allMatch(Predicate)`    | Return `true` if **all** elements match the predicate              | `stream.allMatch(x -> x > 0)`                |
| `noneMatch(Predicate)`   | Return `true` if **no** element matches the predicate              | `stream.noneMatch(x -> x < 0)`               |
| `findFirst()`            | Return the **first** element (order-preserving)                    | `stream.findFirst()` (returns `Optional<T>`) |
| `findAny()`              | Return **any** element (useful in parallel streams)                | `stream.findAny()` (returns `Optional<T>`)   |

## Collectors (used with collect)

| Collector Factory                          | Purpose                                               | Example                                                            |
|--------------------------------------------|-------------------------------------------------------|--------------------------------------------------------------------|
| `Collectors.toList()`                      | Collect elements into a `List`                        | `stream.collect(Collectors.toList())`                              |
| `Collectors.toSet()`                       | Collect elements into a `Set`                         | `stream.collect(Collectors.toSet())`                               |
| `Collectors.toMap(keyMapper, valueMapper)` | Collect elements into a `Map`                         | `stream.collect(Collectors.toMap(Person::getId, Person::getName))` |
| `Collectors.groupingBy(Function)`          | Group elements by a key extractor function            | `names.stream().collect(Collectors.groupingBy(String::length))`    |
| `Collectors.partitioningBy(Predicate)`     | Partition the stream into two groups (`true`/`false`) | `stream.collect(Collectors.partitioningBy(x -> x > 10))`           |
| counting()                                 | Count Elements                                        | Collectors.counting()                                              |
| averagingDouble()                          | calculate average                                     | Collectors.averagingDouble(Employee::getSalary)                    |
| summingDouble()                            | Calculate Sum                                         | Collectors.summingDouble(Employee::getSalary)                      |

## Primitive Specializations

| Primitive Stream | Factory / Range                | Key Methods                            |
|------------------|--------------------------------|----------------------------------------|
| `IntStream`      | `IntStream.range(1, 5)`        | `sum()`, `average()`, `min()`, `max()` |
| `LongStream`     | `LongStream.rangeClosed(1, 5)` | `sum()`, `average()`, `min()`, `max()` |
| `DoubleStream`   | `DoubleStream.of(1.2, 3.4)`    | `sum()`, `average()`, `min()`, `max()` |

## Which design patterns are followed while implementing lambda expressions and streams?

- **Strategy Pattern** : lambda expressions allow defining different algorithms or behaviors inline without creating
  concrete class.
- Streams and lambdas abstract the behavior of operations like filtering, mapping and sorting, fitting the strategy
  pattern model.
- **Factory Pattern** : Lambdas may replace concrete implementations with functional factories for object creation.
- **Command Pattern** : Lambdas encapsulate a request or action as an object that can be passed, stored, and executed.
- Streams operations or event handlers often use lambdas as commands to be executed later, aligning with this pattern.

### Design Patterns in Streams

#### Strategy Pattern

- Lambda expressions allow defining different algorithms inline without creating concrete classes.

```java
public class EmployeeSortingDemo {
    public static void main(String[] args) {
        List<Employee> employees = Arrays.asList(
                new Employee("Alice", 30, 75000.0),
                new Employee("Bob", 25, 60000.0),
                new Employee("Charlie", 35, 80000.0),
                new Employee("Diana", 28, 65000.0),
                new Employee("Eve", 32, 90000.0)
        );

        // Different sorting strategies
        Comparator<Employee> bySalary = Comparator.comparingDouble(Employee::getSalary);
        Comparator<Employee> byAge = Comparator.comparingInt(Employee::getAge);
        Comparator<Employee> byName = Comparator.comparing(Employee::getName);

        // Salary strategy (ascending)
        List<Employee> sortedBySalary = employees.stream().sorted(bySalary).collect(Collectors.toList());
        System.out.println("Sorted by Salary:");
        sortedBySalary.forEach(System.out::println);

        // Age strategy (ascending)
        List<Employee> sortedByAge = employees.stream().sorted(byAge).collect(Collectors.toList());
        System.out.println("\nSorted by Age:");
        sortedByAge.forEach(System.out::println);

        // Name strategy (ascending)
        List<Employee> sortedByName = employees.stream().sorted(byName).collect(Collectors.toList());
        System.out.println("\nSorted by Name:");
        sortedByName.forEach(System.out::println);
    }
}   // Name strategy
```

#### Factory Pattern

- Lambdas can replace concrete implementations with functional factories.

```java
import java.util.ArrayList;
import java.util.List;
import java.util.function.Function;
import java.util.function.Supplier;

public class FactoryPatternDemo {

    public static void main(String[] args) {

        // Functional Factory using Function
        Function<String, Employee> employeeFactory =
                name -> new Employee(name);

        Employee emp1 = employeeFactory.apply("Rahul");
        Employee emp2 = employeeFactory.apply("Ayesha");

        // Collection factory using Supplier
        Supplier<List<Employee>> listFactory = ArrayList::new;

        List<Employee> employees = listFactory.get();
        employees.add(emp1);
        employees.add(emp2);

        employees.forEach(System.out::println);
    }
}

```

#### Command Pattern

- Lambdas encapsulate actions that can be passed and executed later.

```java
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class CommandPatternDemo {

    public static void main(String[] args) {

        List<Employee> employees = Arrays.asList(
                new Employee("Arjun", 30),
                new Employee("Kiran", 22),
                new Employee("Sana", 28)
        );

        // Command as Lambda
        Runnable task = () -> processEmployees(employees);

        ExecutorService executor = Executors.newFixedThreadPool(2);
        executor.execute(task);

        executor.shutdown();
    }

    private static void processEmployees(List<Employee> employees) {
        System.out.println("Processing employees...");
        employees.forEach(System.out::println);
    }
}

```

#### Observer Pattern

- Stream operations can be chained like observers.

```java
import java.util.Arrays;
import java.util.List;

public class ObserverPatternDemo {

    public static void main(String[] args) {

        List<Employee> employees = Arrays.asList(
                new Employee("Aman", 24),
                new Employee("Riya", 27),
                new Employee("John", 32),
                new Employee("Sara", 21)
        );

        employees.stream()

                // Observer 1: Filter
                .filter(e -> e.getAge() > 25)

                // Observer 2: Transform
                .map(Employee::getName)

                // Observer 3: Final Action
                .forEach(System.out::println);
    }
}
```

### Collectors

| Collector Factory                                    | Purpose                                      | Example                                                                                            |
|------------------------------------------------------|----------------------------------------------|----------------------------------------------------------------------------------------------------|
| `Collectors.toList()`                                | Collect elements into a `List`               | `stream.collect(Collectors.toList())`                                                              |
| `Collectors.toSet()`                                 | Collect elements into a `Set`                | `stream.collect(Collectors.toSet())`                                                               |
| `Collectors.toMap(keyMapper, valueMapper)`           | Collect elements into a `Map`                | `stream.collect(Collectors.toMap(Person::getId, Person::getName))`                                 |
| `Collectors.groupingBy(Function)`                    | Group elements by a key extractor function   | `names.stream().collect(Collectors.groupingBy(String::length))`                                    |
| `Collectors.partitioningBy(Predicate)`               | Partition into two groups (`true` / `false`) | `stream.collect(Collectors.partitioningBy(x -> x > 10))`                                           |
| `Collectors.counting()`                              | Count number of elements                     | `stream.collect(Collectors.counting())`                                                            |
| `Collectors.averagingInt / Double / Long()`          | Calculate average of numeric values          | `stream.collect(Collectors.averagingDouble(Employee::getSalary))`                                  |
| `Collectors.summingInt / Double / Long()`            | Calculate sum of numeric values              | `stream.collect(Collectors.summingInt(Employee::getAge))`                                          |
| `Collectors.joining()`                               | Concatenate `String` elements                | `stream.collect(Collectors.joining(", "))`                                                         |
| `Collectors.maxBy(Comparator)`                       | Find maximum element                         | `stream.collect(Collectors.maxBy(Comparator.comparingInt(...)))`                                   |
| `Collectors.minBy(Comparator)`                       | Find minimum element                         | `stream.collect(Collectors.minBy(Comparator.comparingInt(...)))`                                   |
| `Collectors.collectingAndThen(downstream, finisher)` | Post-process collected result                | `stream.collect(Collectors.collectingAndThen(Collectors.toList(), Collections::unmodifiableList))` |

### Comparator

| Method / Factory                             | Purpose                                  | Example                                                                      |
|----------------------------------------------|------------------------------------------|------------------------------------------------------------------------------|
| `Comparator.naturalOrder()`                  | Sort elements by natural order           | `list.stream().sorted(Comparator.naturalOrder())`                            |
| `Comparator.reverseOrder()`                  | Sort elements in reverse natural order   | `list.stream().sorted(Comparator.reverseOrder())`                            |
| `Comparator.comparing(Function)`             | Compare objects by extracted key         | `Comparator.comparing(Employee::getSalary)`                                  |
| `Comparator.comparing(Function, Comparator)` | Compare by key using a custom comparator | `Comparator.comparing(Employee::getName, String.CASE_INSENSITIVE_ORDER)`     |
| `Comparator.comparingInt / Double / Long()`  | Compare by primitive key (avoids boxing) | `Comparator.comparingInt(Employee::getAge)`                                  |
| `Comparator.thenComparing(...)`              | Add tie-breaker comparison               | `Comparator.comparing(Employee::getSalary).thenComparing(Employee::getName)` |
| `Comparator.nullsFirst / nullsLast(...)`     | Handle `null` values safely              | `Comparator.nullsFirst(Comparator.comparing(Employee::getName))`             |

### Utility Methods

| Utility                                       | Purpose                                                        | Example                                                      |
|-----------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------|
| `Optional.orElse(value)`                      | Return value if present, otherwise default                     | `opt.orElse("default")`                                      |
| `Optional.orElseGet(Supplier)`                | Lazily compute default value                                   | `opt.orElseGet(() -> expensiveDefault())`                    |
| `Optional.orElseThrow()`                      | Throw `NoSuchElementException` if empty                        | `opt.orElseThrow()`                                          |
| `IntStream.range(start, end)`                 | Generate sequential int range (start inclusive, end exclusive) | `IntStream.range(1, 5).boxed().collect(Collectors.toList())` |
| `Stream.of(...)`                              | Create a stream from given values                              | `Stream.of("A", "B", "C")`                                   |
| `Arrays.stream(array)`                        | Create a stream from an array                                  | `Arrays.stream(new int[]{1, 2, 3})`                          |
| `Collectors.toUnmodifiableList / Set / Map()` | Collect into immutable collections                             | `stream.collect(Collectors.toUnmodifiableList())`            |
| `Stream.generate(Supplier)`                   | Create infinite stream (must be limited)                       | `Stream.generate(Math::random).limit(5)`                     |
| `Stream.iterate(seed, UnaryOperator)`         | Create iterative stream sequence                               | `Stream.iterate(1, n -> n + 1).limit(10)`                    |

### Key Insights

- Use Collectors when you need to gather results.
- Use Comparators when sorting or finding min/max.
- Use Optional utilities to handle empty results safely.
- Use Stream factories (of, generate, iterate) to create streams.