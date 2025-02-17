package ch.sbb.backend.logging.domain.service

import ch.sbb.backend.logging.domain.LogEntry
import ch.sbb.backend.logging.domain.repository.LoggingRepository

class DomainLoggingService(
    private val loggingRepository: LoggingRepository
) : LoggingService {
    override fun saveAll(logEntries: List<LogEntry>) {
        loggingRepository.saveAll(logEntries)
    }
}
