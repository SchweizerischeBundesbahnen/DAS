package ch.sbb.backend.logging

import ch.sbb.backend.logging.domain.LogDestination
import ch.sbb.backend.logging.domain.LogEntry
import ch.sbb.backend.logging.domain.LogLevel
import ch.sbb.backend.logging.domain.Tenant
import ch.sbb.backend.logging.domain.repository.TenantRepository
import ch.sbb.backend.logging.domain.service.DomainLoggingService
import ch.sbb.backend.logging.infrastructure.SplunkLoggingRepository
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.springframework.security.core.Authentication
import org.springframework.security.core.context.SecurityContext
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import java.time.Instant
import java.time.OffsetDateTime
import java.util.*

class DomainLoggingServiceTest {

    private lateinit var sut: DomainLoggingService
    private lateinit var tenantRepository: TenantRepository
    private lateinit var splunkLoggingRepository: SplunkLoggingRepository

    private val tid = UUID.randomUUID().toString()

    @BeforeEach
    fun setUp() {
        tenantRepository = mock(TenantRepository::class.java)
        splunkLoggingRepository = mock(SplunkLoggingRepository::class.java)
        sut = DomainLoggingService(splunkLoggingRepository)
        val securityContext: SecurityContext = mock(SecurityContext::class.java)
        val jwt = Jwt(
            "token",
            Instant.now(),
            Instant.now(),
            mapOf("header" to "value"),
            mapOf("tid" to tid)
        )
        val authentication = mock(Authentication::class.java)
        `when`(authentication.principal).thenReturn(jwt)
        `when`(securityContext.authentication).thenReturn(authentication)
        SecurityContextHolder.setContext(securityContext)
    }

    @Test
    fun `should log messages to splunk`() {
        val tenantConfig = Tenant("test", "10", "", "", LogDestination.SPLUNK)
        `when`(tenantRepository.current()).thenReturn(tenantConfig)

        val timestamp = OffsetDateTime.now()
        val logEntries = listOf(
            LogEntry(timestamp, "source", "message", LogLevel.INFO)
        )

        sut.saveAll(logEntries)

        val expectedLogs = listOf(
            LogEntry(timestamp, "source", "message", LogLevel.INFO)
        )
        verify(splunkLoggingRepository, times(1)).saveAll(expectedLogs)
    }
}
