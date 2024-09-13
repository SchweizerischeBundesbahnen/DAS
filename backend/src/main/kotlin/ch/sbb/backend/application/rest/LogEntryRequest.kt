package ch.sbb.backend.application.rest

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema(name = "LogEntry")
data class LogEntryRequest(
    @Schema(
        type = "number",
        format = "double",
        description = "Timestamp of the log entry in seconds since epoch or timestamp",
        example = "1727188352.001"
    )
    val time: OffsetDateTime,

    @Schema(description = "Source of the log entry", example = "mobile_flutter")
    val source: String,

    @Schema(
        description = "Message of the log entry",
        example = "Error: Could not connect to server"
    )
    val message: String,

    @Schema(description = "Level of the log entry", example = "ERROR")
    val level: LogLevelRequest,

    @Schema(
        description = "Metadata of the log entry",
        example = "{\"deviceId\": \"abcde123\", \"appVersion\": \"1.2.0\"}"
    )
    val metadata: Map<String, String>? = emptyMap()
)
