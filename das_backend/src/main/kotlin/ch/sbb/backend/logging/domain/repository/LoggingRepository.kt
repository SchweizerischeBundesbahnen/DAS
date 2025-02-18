package ch.sbb.backend.logging.domain.repository

import ch.sbb.backend.logging.domain.LogEntry

interface LoggingRepository {
    fun saveAll(logs: List<LogEntry>)
}
