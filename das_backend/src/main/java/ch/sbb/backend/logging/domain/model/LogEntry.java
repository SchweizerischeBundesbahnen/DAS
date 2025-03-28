package ch.sbb.backend.logging.domain.model;

import java.time.OffsetDateTime;
import java.util.Map;

public record LogEntry(
    OffsetDateTime time,
    String source,
    String message,
    LogLevel level,
    Map<String, String> metadata
) {

}
