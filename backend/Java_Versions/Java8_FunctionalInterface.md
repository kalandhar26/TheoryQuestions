#### Functional Interface

- A Functional Interface is an interface that has exactly one abstract method (SAM – Single Abstract Method).
- They can have multiple default, static, and private methods, but only one abstract method.
- They are the foundation of Lambda Expressions and Method References in Java.
- Annotated with @FunctionalInterface (optional but recommended).

```java

@FunctionalInterface
interface MyFunctionalInterface {
    void execute();  // Single abstract method
}
```

#### Why Default, Static, and Private Methods?

- Functional interfaces can include:
- Default methods → Provide reusable implementations without breaking existing code.
- Static methods → Utility/helper methods inside the interface.
- Private methods → Encapsulate common or shared logic used by default methods.

```java

@FunctionalInterface
interface Calculator {
    int operate(int a, int b);

    default void printResult(int result) {
        System.out.println("Result: " + result);
    }

    static void info() {
        System.out.println("Functional Interface for arithmetic operations");
    }

    private void helper() {
        System.out.println("Helper logic");
    }
}
```

| Interface             | Abstract Method       | Purpose                              | Example                                                        |
|-----------------------|-----------------------|--------------------------------------|----------------------------------------------------------------|
| `Predicate<T>`        | `boolean test(T t)`   | Tests a boolean condition            | `Predicate<Integer> isEven = x -> x % 2 == 0;`                 |
| `Function<T, R>`      | `R apply(T t)`        | Maps input to output                 | `Function<String, Integer> length = String::length;`           |
| `Supplier<T>`         | `T get()`             | Supplies a value (no input)          | `Supplier<Double> random = Math::random;`                      |
| `Consumer<T>`         | `void accept(T t)`    | Consumes input, no return            | `Consumer<String> print = System.out::println;`                |
| `BiFunction<T, U, R>` | `R apply(T t, U u)`   | Maps two inputs to one output        | `BiFunction<Integer, Integer, Integer> sum = (a, b) -> a + b;` |
| `UnaryOperator<T>`    | `T apply(T t)`        | Function with same input/output type | `UnaryOperator<Integer> square = x -> x * x;`                  |
| `BinaryOperator<T>`   | `T apply(T t1, T t2)` | Combines two values of same type     | `BinaryOperator<Integer> max = Integer::max;`                  |

#### Creating a Custom Functional Interface

- Step 1 : Define interface

```java

@FunctionalInterface
interface StringProcessor {
    String process(String input);
}
```

- Step 2: Use with Lambda. Lambdas provide a concise way to implement functional interfaces.

```java
public class Demo {
    public static void main(String[] args) {
        StringProcessor toUpper = s -> s.toUpperCase();
        System.out.println(toUpper.process("hello")); // Output: HELLO
    }
}
```

- Step 3 : Use with Method Reference. Method references are shorthand for lambdas when an existing method matches the
  signature.

```java
public class Demo {
    public static void main(String[] args) {
        StringProcessor trimProcessor = String::trim;
        System.out.println(trimProcessor.process("   hello   ")); // Output: hello
    }
}
```
