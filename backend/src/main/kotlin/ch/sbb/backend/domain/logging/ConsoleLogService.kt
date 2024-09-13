package ch.sbb.backend.domain.logging

class ConsoleLogService : LogService {

    override fun logs(logEntries: List<LogEntry>) {
        logEntries.forEach { println(it) }
    }
}
