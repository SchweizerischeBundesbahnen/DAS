package ch.sbb.backend.domain.logging

import org.slf4j.LoggerFactory

/** example of a log service implementation without the expected behaviour */
class SplunkLogService: LogService {
    private val log = LoggerFactory.getLogger(SplunkLogService::class.java)

    override fun logs( logEntries: List<LogEntry>) {
        logEntries.forEach { log.info("SPLUNK: $it") }
        // todo: instead of logging to console, log to splunk
    }
}
