package ch.sbb.backend.domain.logging

import java.time.OffsetDateTime

data class LogEntry(
    private val time: OffsetDateTime,
    private val source: String,
    private val message: String,
    private val level: LogLevel,
    private val metadata: Map<String, String>? = emptyMap()
) {
    override fun toString(): String {
        return "${time}\t${level}\t${source}\t${message} ${metadata}"
    }
}
