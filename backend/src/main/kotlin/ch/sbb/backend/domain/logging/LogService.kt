package ch.sbb.backend.domain.logging

interface LogService {
    fun logs(logEntries: List<LogEntry>)
}
