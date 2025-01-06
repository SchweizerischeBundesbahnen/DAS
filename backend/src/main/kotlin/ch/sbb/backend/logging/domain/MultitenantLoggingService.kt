package ch.sbb.backend.logging.domain

import ch.sbb.backend.logging.domain.service.LoggingService
import ch.sbb.backend.logging.domain.service.TenantService

class MultitenantLoggingService(
    private val tenantService: TenantService,
    private val splunkLoggingService: LoggingService,
    private val consoleLoggingService: LoggingService): LoggingService {

    override fun saveAll(logEntries: List<LogEntry>) {
        when(tenantService.current().logDestination) {
            LogDestination.SPLUNK -> splunkLoggingService.saveAll(logEntries)
            LogDestination.CONSOLE -> consoleLoggingService.saveAll(logEntries)
        }
    }
}
