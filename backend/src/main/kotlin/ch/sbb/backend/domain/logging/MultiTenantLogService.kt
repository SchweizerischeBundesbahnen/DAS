package ch.sbb.backend.domain.logging

import ch.sbb.backend.application.TenantContext
import ch.sbb.backend.application.rest.LogEntryRequest
import ch.sbb.backend.application.rest.LogLevelRequest
import ch.sbb.backend.domain.tenancy.ConfigTenantService
import ch.sbb.backend.domain.tenancy.TenantId
import ch.sbb.backend.infrastructure.configuration.LogDestination
import org.springframework.stereotype.Service

@Service
class MultitenantLogService(
    private val tenantService: ConfigTenantService,
    private val splunkLogService: SplunkLogService
) {

    fun logs(logs: List<LogEntryRequest>) {
        getLogService(TenantContext.current().tenantId).logs(logs.map {
            LogEntry(
                it.time, it.source, it.message, level(it.level), it.metadata
            )
        })
    }

    private fun level(level: LogLevelRequest): LogLevel {
        return when (level) {
            LogLevelRequest.TRACE -> LogLevel.TRACE
            LogLevelRequest.DEBUG -> LogLevel.DEBUG
            LogLevelRequest.INFO -> LogLevel.INFO
            LogLevelRequest.WARNING -> LogLevel.WARNING
            LogLevelRequest.ERROR -> LogLevel.ERROR
            LogLevelRequest.FATAL -> LogLevel.FATAL
        }
    }

    private fun getLogService(tenantId: TenantId): LogService {
        val logDestination = tenantService.getById(tenantId).logDestination
        return when (logDestination) {
            LogDestination.SPLUNK -> splunkLogService
        }
    }
}

