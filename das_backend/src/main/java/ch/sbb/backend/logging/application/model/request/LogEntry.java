package ch.sbb.backend.logging.application.model.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.Map;

// todo: check model from popular libs like slf4j-api (#769)
public class LogEntry {

    @NotNull
    @Schema(
        type = "number",
        format = "double",
        description = "Timestamp of the log entry in seconds since epoch or ISO-8601 timestamp",
        example = "1727188352.001"
    )
    // todo: define dateTime format on API spec/doc --> @DateTimeFormat(iso = ISO.DATE_TIME) (#768)
    // todo: rename into dateTime (#769)
    public OffsetDateTime time;

    @NotBlank
    @Schema(description = "Source of the log entry", example = "das_client")
    public String source;

    @NotBlank
    @Schema(
        description = "Message of the log entry",
        example = "Error: Could not connect to server"
    )
    public String message;

    @NotNull
    @Schema(description = "Level of the log entry", example = "ERROR")
    public LogLevel level;

    @Schema(
        description = "Metadata of the log entry",
        example = "{\"deviceId\": \"abcde123\", \"appVersion\": \"1.2.0\"}"
    )
    public Map<String, String> metadata = Collections.emptyMap();

    public ch.sbb.backend.logging.domain.model.LogEntry toLogEntry() {
        return new ch.sbb.backend.logging.domain.model.LogEntry(time, source, message, new ch.sbb.backend.logging.domain.model.LogLevel(level.name()), metadata);
    }
}
