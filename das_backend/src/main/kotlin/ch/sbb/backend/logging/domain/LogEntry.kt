package ch.sbb.backend.logging.domain

import java.time.OffsetDateTime

data class LogEntry(
    val time: OffsetDateTime,
    val source: String,
    val message: String,
    val level: LogLevel,
    val metadata: Map<String, String>? = emptyMap()
)
