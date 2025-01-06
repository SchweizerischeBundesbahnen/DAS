package ch.sbb.backend.logging.infrastructure

import ch.sbb.backend.logging.domain.LogEntry
import ch.sbb.backend.logging.domain.repository.LoggingRepository
import org.springframework.stereotype.Component

@Component
class ConsoleLoggingRepository : LoggingRepository {
    override fun saveAll(logs: List<LogEntry>) {
        logs.forEach { println(it) }
    }
}
