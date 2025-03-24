package ch.sbb.backend.logging.application.rest;

import ch.sbb.backend.logging.domain.LogEntry;
import ch.sbb.backend.logging.domain.LogLevel;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.Map;

@Schema(name = "LogEntry")
public class LogEntryRequest {

    @NotNull
    @Schema(
        type = "number",
        format = "double",
        description = "Timestamp of the log entry in seconds since epoch or timestamp",
        example = "1727188352.001"
    )
    public OffsetDateTime time;

    @NotBlank
    @Schema(description = "Source of the log entry", example = "mobile_flutter")
    public String source;

    @NotBlank
    @Schema(
        description = "Message of the log entry",
        example = "Error: Could not connect to server"
    )
    public String message;

    @NotNull
    @Schema(description = "Level of the log entry", example = "ERROR")
    public LogLevelRequest level;

    @Schema(
        description = "Metadata of the log entry",
        example = "{\"deviceId\": \"abcde123\", \"appVersion\": \"1.2.0\"}"
    )
    public Map<String, String> metadata = Collections.emptyMap();

    LogEntry toLogEntry() {
        return new LogEntry(time, source, message, new LogLevel(level.name()), metadata);
    }
}
