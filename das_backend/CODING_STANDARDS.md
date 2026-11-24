# DAS Backend Coding Standards

Follow the [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html). This file holds the rules that go beyond it.

## Logging

On the stages (every profile but `local`) each log line is one JSON object in Elastic Common Schema shape, written by Spring Boot's structured logging
(`application.yaml`). MDC entries and key-value pairs become Splunk fields. Locally and in tests the console shows text with the same pairs.

### Levels

| Level | Meaning                                                              | Examples from this codebase                                                         |
|-------|----------------------------------------------------------------------|------------------------------------------------------------------------------------|
| ERROR | Unexpected, a human must look.                                       | 5xx response, preload attempt failed, SFERA OAuth2 authorization failed            |
| WARN  | Degraded but handled, nobody has to act right now.                   | preload time budget exceeded, preload attempt timed out, segment zip missing, 502  |
| INFO  | Business and lifecycle events, one access line per request, all 4xx. | preload run finished, segment zip published, authentication failed (401)           |
| DEBUG | Diagnostics, off on the stages.                                      | train formation saved, probe requests                                              |
| TRACE | Payload level.                                                       | Kafka record lag                                                                   |

`root` and `ch.sbb.das.backend` are INFO. Library loggers are lowered only with evidence from Splunk and a comment in `application.yaml`.

### Message style

A statement is a short fixed sentence plus key-value pairs through the SLF4J fluent API. No value is interpolated into the message, no `key={}` in the text,
no string concatenation.

```java
log.atInfo()
    .addKeyValue(LogKeys.ZIP_KEY, zipKey)
    .addKeyValue("added", added.size())
    .log("Segment zip published");
```

- Values keep their type: numbers as numbers, collections as arrays, maps as objects.
- A time value is an `Instant`, `OffsetDateTime` or `LocalDate`; never a `LocalDateTime`, a formatted string or epoch millis. Line timestamps are UTC.
- Context that spans several lines goes into the MDC and is removed on every exit path (`MDC.putCloseable` in try-with-resources, or `MDC.remove` in a
  `finally`), see `RequestIdFilter`. A key is never both in the MDC and a key-value pair of the same line: the formatter rejects duplicates.
- `error.*` is written by the formatter from the throwable, never as a key-value pair.

### Key registry

Shared keys are constants in `LogKeys`. ECS names where ECS has one, camelCase domain names where it does not. A new shared key is added there and here.

| Key                         | Where                              | Value                                            |
|-----------------------------|------------------------------------|--------------------------------------------------|
| `requestId`                 | MDC, `RequestIdFilter`             | `Request-ID` header if the caller sent one       |
| `http.request.method`       | MDC, `RequestIdFilter`             | `GET`, `POST`, ...                               |
| `url.path`                  | MDC, `RequestIdFilter`             | request path                                     |
| `url.query`                 | access line                        | raw query string                                 |
| `http.response.status_code` | access line, error handlers        | status as number                                 |
| `user_agent.original`       | access line                        | `User-Agent` header                              |
| `durationMs`                | access line, jobs                  | elapsed milliseconds (not ECS `event.duration`)  |
| `mdc.instana.trace.id`      | MDC, Instana agent                 | trace id, correlates with `Problem.traceId`      |
| `trainNumber`               | preload attempt, Kafka record      | operational train number                         |
| `operationalDay`            | Kafka record                       | `LocalDate`                                      |
| `kafka.partition`           | Kafka consumers                    | partition                                        |
| `kafka.offset`              | Kafka consumers                    | offset                                           |
| `zipKey`                    | preload bucket                     | object key of a zip                              |
| `downstreamStatusCode`      | 502 handler                        | status of the downstream service                 |
| `problemTitle`, `problemDetail` | 4xx handler                    | title and detail of the `Problem` response       |
| `reason`                    | rejections, skipped work           | free text, e.g. the exception message            |
| `resource`, `resourceId`    | tenant checks                      | resource type and id treated as not found        |

Line-local keys (counts such as `requested`, `processed`, `rows`) are camelCase nouns and need no registration.

### Exceptions

Whenever a throwable is in hand at WARN or ERROR, pass it with `setCause`, never only its message. An exception is logged once, at the boundary that handles
it (exception handler, scheduler, consumer); no log-and-rethrow. 4xx lines carry no stack trace.

### Privacy

Never log token values, user object ids, or request and response bodies. Query strings and the `User-Agent` header are logged.

### Reading logs in the pod shell

```sh
oc logs deploy/das-backend-dev -f | jq -r '"\(.["@timestamp"]) \(.log.level) \(.log.logger | split(".") | last): \(.message) \(del(.["@timestamp"], .log, .message, .process, .service, .ecs) | tostring)"'
```
