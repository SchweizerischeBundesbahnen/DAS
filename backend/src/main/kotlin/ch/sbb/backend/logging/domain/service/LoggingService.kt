package ch.sbb.backend.logging.domain.service

import ch.sbb.backend.logging.domain.LogEntry

interface LoggingService {
    fun saveAll(logEntries: List<LogEntry>)
}
