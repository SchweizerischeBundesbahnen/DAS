package ch.sbb.backend.domain.logging

import ch.sbb.backend.application.rest.LogEntryRequest
import ch.sbb.backend.application.rest.LogLevelRequest
import ch.sbb.backend.domain.tenancy.ConfigTenantService
import ch.sbb.backend.domain.tenancy.TenantId
import ch.sbb.backend.infrastructure.configuration.LogDestination
import ch.sbb.backend.infrastructure.configuration.Tenant
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.springframework.security.core.Authentication
import org.springframework.security.core.context.SecurityContext
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import java.io.ByteArrayOutputStream
import java.io.PrintStream
import java.time.Instant
import java.time.OffsetDateTime
import java.util.*

class MultitenantLogServiceTest {

    private lateinit var tenantService: ConfigTenantService
    private lateinit var sut: MultitenantLogService

    private val originalOut = System.out
    private val outputStreamCaptor = ByteArrayOutputStream()

    private val tid = UUID.randomUUID().toString()

    @BeforeEach
    fun setUp() {
        tenantService = mock(ConfigTenantService::class.java)
        sut = MultitenantLogService(tenantService)
        val securityContext: SecurityContext = mock(SecurityContext::class.java)
        System.setOut(PrintStream(outputStreamCaptor))

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
    fun `should log messages to console`() {
        val tenantId = TenantId(tid)
        val tenantConfig = Tenant().apply {
            logDestination = LogDestination.CONSOLE
        }
        `when`(tenantService.getById(tenantId)).thenReturn(tenantConfig)

        val timestamp =  OffsetDateTime.now()
        val logEntries = listOf(
            LogEntryRequest(timestamp, "source", "message", LogLevelRequest.INFO)
        )

        sut.logs(logEntries)

        val output = outputStreamCaptor.toString()
        assertTrue(output.contains("${timestamp.toString()}\tINFO\tsource\tmessage {}\n"))
    }

    @AfterEach
    fun tearDown() {
        System.setOut(originalOut)
    }
}
