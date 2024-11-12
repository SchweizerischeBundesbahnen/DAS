package ch.sbb.backend.domain.logging

import java.time.OffsetDateTime

data class LogEntry(
    private val time: OffsetDateTime,
    private val source: String,
    private val message: String,
    private val level: LogLevel,
    private val metadata: Map<String, String>? = emptyMap()
) {
    fun toSplunkRequest(): SplunkRequest {
        val fields = metadata?.toMutableMap() ?: mutableMapOf()
        fields["level"] = level.name
        return SplunkRequest(
            event = message,
            fields = fields,
            source = source,
            time = time,
        )
    }
}
