# Java Date-Time API (JSR-310, java.time package)

- Introduced in Java 8 (java.time package) to replace legacy Date, Calendar, SimpleDateFormat.
- Immutable & thread-safe classes.
- Fluent API design → easy chaining.
- Based on ISO-8601 standards.
- Supports time zones, calendar systems, DST rules, UTC/Greenwich.

## Key Packages & Classes

| Package              | Core Classes/Interfaces                                                    | Purpose                                |
|----------------------|----------------------------------------------------------------------------|----------------------------------------|
| `java.time`          | `LocalDate`, `LocalTime`, `LocalDateTime`, `Instant`, `Period`, `Duration` | Date & time **without** zone or offset |
| `java.time.zone`     | `ZoneId`, `ZoneOffset`, `ZoneRules`                                        | Time-zone handling                     |
| `java.time.chrono`   | `Chronology`, `JapaneseChronology`, etc.                                   | Alternate calendar systems             |
| `java.time.format`   | `DateTimeFormatter`, `DateTimeFormatterBuilder`                            | Parsing & formatting                   |
| `java.time.temporal` | `Temporal`, `TemporalField`, `ChronoUnit`, `TemporalAdjusters`             | Advanced date-time arithmetic          |

## Factory & Factory-like Creation

| Factory / Method             | Description                         | Example                                                       |
|------------------------------|-------------------------------------|---------------------------------------------------------------|
| `now()`                      | Current date/time from system clock | `LocalDate.now()`                                             |
| `of(...)`                    | Build from explicit fields          | `LocalDate.of(2025, 8, 8)`                                    |
| `parse(CharSequence)`        | Parse ISO string                    | `LocalDate.parse("2025-08-08")`                               |
| `ofInstant(Instant, ZoneId)` | Convert `Instant` to zoned type     | `ZonedDateTime.ofInstant(instant, ZoneId.of("Asia/Kolkata"))` |
| `from(TemporalAccessor)`     | Generic conversion                  | `LocalDate.from(temporal)`                                    |
| `now(Clock)`                 | Use custom clock for testing        | `LocalDate.now(Clock.fixed(...))`                             |

## Basic Date-Time Classes

| Class            | Contains                                       | Common Factory / Getter                         | Example                                 |
|------------------|------------------------------------------------|-------------------------------------------------|-----------------------------------------|
| `LocalDate`      | Date only (year-month-day)                     | `LocalDate.of(2025, 8, 8)`                      | `2025-08-08`                            |
| `LocalTime`      | Time only (hour-minute-second-nano)            | `LocalTime.of(14, 30)`                          | `14:30`                                 |
| `LocalDateTime`  | Date + Time without zone                       | `LocalDateTime.of(date, time)`                  | `2025-08-08T14:30`                      |
| `ZonedDateTime`  | Date + Time + Zone                             | `ZonedDateTime.now(ZoneId.of("Europe/London"))` | `2025-08-08T14:30+01:00[Europe/London]` |
| `OffsetDateTime` | Date + Time + Offset from UTC                  | `OffsetDateTime.of(ldt, ZoneOffset.ofHours(2))` | `2025-08-08T14:30+02:00`                |
| `Instant`        | Point on the UTC timeline (epoch millis/nanos) | `Instant.now()`                                 | `2025-08-08T09:15:30Z`                  |

## Amounts of Time (Immutable)

| Class        | Represents                                  | Factory / Usage                   | Example                 |
|--------------|---------------------------------------------|-----------------------------------|-------------------------|
| `Period`     | **Date-based** amount (years, months, days) | `Period.of(1, 2, 15)`             | 1 year 2 months 15 days |
| `Duration`   | **Time-based** amount (seconds, nanos)      | `Duration.ofMinutes(30)`          | PT30M                   |
| `ChronoUnit` | Enum of standard units                      | `ChronoUnit.DAYS.between(d1, d2)` | 42 days                 |

## Manipulation & Adjusters (all return new instance)

| Method / Adjuster                  | Description                     | Example                                              |
|------------------------------------|---------------------------------|------------------------------------------------------|
| `plusYears(n)` / `minusYears(n)`   | Add / subtract years            | `localDate.plusYears(2)`                             |
| `plus(Period)` / `minus(Duration)` | Add / subtract amount           | `localDateTime.plus(Duration.ofHours(3))`            |
| `with(TemporalField, value)`       | Set field to new value          | `localDate.with(ChronoField.DAY_OF_MONTH, 1)`        |
| `with(TemporalAdjuster)`           | Use built-in or custom adjuster | `localDate.with(TemporalAdjusters.lastDayOfMonth())` |
| `truncatedTo(TemporalUnit)`        | Truncate to unit                | `localTime.truncatedTo(ChronoUnit.MINUTES)`          |

## Formatting & Parsing

| Formatter                  | Pattern                  | Usage                                                        | Example      |
|----------------------------|--------------------------|--------------------------------------------------------------|--------------|
| Built-in constants         | ISO formats              | `DateTimeFormatter.ISO_LOCAL_DATE`                           | `2025-08-08` |
| `ofPattern(String)`        | Custom pattern           | `DateTimeFormatter.ofPattern("dd/MM/yyyy")`                  | `08/08/2025` |
| `DateTimeFormatterBuilder` | Complex custom formatter | Build step-by-step                                           |              |
| `parse` / `format`         | Parse or format          | `LocalDate.parse(str, formatter)` / `formatter.format(date)` |              |

## Time-Zone Handling

| Class           | Purpose                                 | Example                                        |
|-----------------|-----------------------------------------|------------------------------------------------|
| `ZoneId`        | Region-based ID (e.g., `Europe/London`) | `ZoneId.of("America/New_York")`                |
| `ZoneOffset`    | Fixed offset from UTC/Greenwich         | `ZoneOffset.ofHours(-5)`                       |
| `ZonedDateTime` | Full date-time with zone                | `ZonedDateTime.now(zoneId)`                    |
| `ZoneRules`     | DST transition rules                    | `zoneId.getRules().isDaylightSavings(instant)` |

## Alternate Calendar Systems

| Chronology               | Factory                                            | Example                 |
|--------------------------|----------------------------------------------------|-------------------------|
| `JapaneseChronology`     | `JapaneseChronology.INSTANCE.date(2025, 8, 8)`     | Japanese era `令和7年8月8日` |
| `ThaiBuddhistChronology` | `ThaiBuddhistChronology.INSTANCE.date(2568, 8, 8)` | Thai Buddhist year 2568 |

## Clock (for Testing / Dependency Injection)

| Factory                        | Description                     | Example                                                                |
|--------------------------------|---------------------------------|------------------------------------------------------------------------|
| `Clock.systemDefaultZone()`    | System clock                    |                                                                        |
| `Clock.fixed(Instant, ZoneId)` | Always returns the same instant | `Clock.fixed(Instant.parse("2025-08-08T09:00:00Z"), ZoneId.of("UTC"))` |

## Common Recipes Cheat-Sheet

| Task                                       | Code snippet                                                                                                 |
|--------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| Get tomorrow                               | `LocalDate tomorrow = LocalDate.now().plusDays(1);`                                                          |
| Age in years                               | `long age = ChronoUnit.YEARS.between(birthDate, LocalDate.now());`                                           |
| First Monday of next month                 | `LocalDate firstMon = LocalDate.now().with(TemporalAdjusters.firstInMonth(DayOfWeek.MONDAY)).plusMonths(1);` |
| Format to "dd-MM-yyyy HH:mm"               | `DateTimeFormatter f = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm"); String s = ldt.format(f);`           |
| Convert `java.util.Date` → `LocalDateTime` | `LocalDateTime.ofInstant(date.toInstant(), ZoneId.systemDefault());`                                         |

