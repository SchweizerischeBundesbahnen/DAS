package ch.sbb.backend.domain.logging

import ch.sbb.backend.application.rest.LogEntryRequest
import ch.sbb.backend.application.rest.LogLevelRequest
import ch.sbb.backend.domain.tenancy.ConfigTenantService
import ch.sbb.backend.domain.tenancy.TenantId
import ch.sbb.backend.infrastructure.configuration.LogDestination
import ch.sbb.backend.infrastructure.configuration.Tenant
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

class MultitenantLogServiceTest {

    private lateinit var sut: MultitenantLogService
    private lateinit var tenantService: ConfigTenantService
    private lateinit var splunkLogService: SplunkLogService

    private val tid = UUID.randomUUID().toString()

    @BeforeEach
    fun setUp() {
        tenantService = mock(ConfigTenantService::class.java)
        splunkLogService = mock(SplunkLogService::class.java)
        sut = MultitenantLogService(tenantService, splunkLogService)
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
        `when`(securityContext.getAuthentication()).thenReturn(authentication)
        SecurityContextHolder.setContext(securityContext)
    }

    @Test
    fun `should log messages to splunk`() {
        val tenantId = TenantId(tid)
        val tenantConfig = Tenant("test", "10", "", "", LogDestination.SPLUNK)
        `when`(tenantService.getById(tenantId)).thenReturn(tenantConfig)

        val timestamp = OffsetDateTime.now()
        val logEntries = listOf(
            LogEntryRequest(timestamp, "source", "message", LogLevelRequest.INFO)
        )

        sut.logs(logEntries)

        val expectedLogs = listOf(
            LogEntry(timestamp, "source", "message", LogLevel.INFO)
        )
        verify(splunkLogService, times(1)).logs(expectedLogs)
    }
}
