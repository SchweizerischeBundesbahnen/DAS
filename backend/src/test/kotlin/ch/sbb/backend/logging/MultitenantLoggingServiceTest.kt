package ch.sbb.backend.logging

import ch.sbb.backend.logging.domain.*
import ch.sbb.backend.logging.domain.service.LoggingService
import ch.sbb.backend.logging.domain.service.TenantService
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import java.time.OffsetDateTime

class MultitenantLoggingServiceTest {

    private lateinit var sut: MultitenantLoggingService
    private lateinit var tenantService: TenantService
    private lateinit var splunkLoggingService: LoggingService
    private lateinit var consoleLoggingService: LoggingService

    @BeforeEach
    fun setUp() {
        tenantService = mock(TenantService::class.java)
        splunkLoggingService = mock(LoggingService::class.java)
        consoleLoggingService = mock(LoggingService::class.java)
        sut = MultitenantLoggingService(tenantService, splunkLoggingService, consoleLoggingService)
    }

    @Test
    fun `should log messages to splunk`() {
        val tenantConfig = Tenant("test", "10", "", "", LogDestination.SPLUNK)
        `when`(tenantService.current()).thenReturn(tenantConfig)

        val timestamp = OffsetDateTime.now()
        val logEntries = listOf(
            LogEntry(timestamp, "source", "message", LogLevel.INFO)
        )

        sut.saveAll(logEntries)

        val expectedLogs = listOf(
            LogEntry(timestamp, "source", "message", LogLevel.INFO)
        )
        verify(splunkLoggingService, times(1)).saveAll(expectedLogs)
    }

    @Test
    fun `should log messages to console`() {
        val tenantConfig = Tenant("other", "20", "", "", LogDestination.CONSOLE)
        `when`(tenantService.current()).thenReturn(tenantConfig)

        val timestamp = OffsetDateTime.now()
        val logEntries = listOf(
            LogEntry(timestamp, "mobile", "hello", LogLevel.WARNING)
        )

        sut.saveAll(logEntries)

        val expectedLogs = listOf(
            LogEntry(timestamp, "mobile", "hello", LogLevel.WARNING)
        )
        verify(consoleLoggingService, times(1)).saveAll(expectedLogs)
    }
}
