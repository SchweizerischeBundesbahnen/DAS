package ch.sbb.backend.logging

import ch.sbb.backend.BaseIT
import ch.sbb.backend.TestContainerConfiguration
import ch.sbb.backend.logging.domain.LogEntry
import ch.sbb.backend.logging.domain.LogLevel
import ch.sbb.backend.logging.infrastructure.rest.SplunkHecClient
import org.junit.jupiter.api.Test
import org.mockito.Mockito.verify
import org.springframework.context.annotation.Import
import org.springframework.http.MediaType
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.time.OffsetDateTime

@Import(TestContainerConfiguration::class)
class LoggingControllerTest : BaseIT() {

    @MockitoBean
    private lateinit var splunkHecClient: SplunkHecClient

    @Test
    fun `should log messages with seconds since epoch timestamp`() {
        val logEntriesJson = """
            [
                {
                    "time": 1728147499.452,
                    "source": "itest",
                    "message": "my message",
                    "level": "INFO"
                }
            ]
        """.trimIndent()

        mockMvc.perform(
            post("/api/v1/logging/logs")
                .with(
                    jwt()
                        .jwt { jwt ->
                            jwt.claims { claims ->
                                claims.put(
                                    "tid",
                                    "3409e798-d567-49b1-9bae-f0be66427c54"
                                )
                            }
                        }
                        .authorities(SimpleGrantedAuthority("ROLE_admin"))
                )
                .contentType(MediaType.APPLICATION_JSON)
                .content(logEntriesJson)
        )
            .andExpect(status().isOk)

        val expectedLogs = listOf(
            LogEntry(
                OffsetDateTime.parse("2024-10-05T18:58:19.452+02:00"),
                "itest",
                "my message",
                LogLevel.INFO
            )
        )

        verify(splunkHecClient).sendLogs(expectedLogs)
    }

    @Test
    fun `should log messages with UTC timestamp`() {
        val logEntriesJson = """
            [
                {
                    "time": "2024-10-01T12:34:56.789Z",
                    "source": "itest",
                    "message": "my message",
                    "level": "error",
                    "metadata": {
                        "key1": "value1",
                        "key2": "value2"
                    }
                },
                {
                    "time": "2024-10-01T12:36:12.546Z",
                    "source": "itest",
                    "message": "my warning",
                    "level": "warning"
                }
            ]
        """.trimIndent()

        mockMvc.perform(
            post("/api/v1/logging/logs")
                .with(
                    jwt()
                        .jwt { jwt ->
                            jwt.claims { claims ->
                                claims.put(
                                    "tid",
                                    "3409e798-d567-49b1-9bae-f0be66427c54"
                                )
                            }
                        }
                        .authorities(SimpleGrantedAuthority("ROLE_admin"))
                )
                .contentType(MediaType.APPLICATION_JSON)
                .content(logEntriesJson)
        )
            .andExpect(status().isOk)

        val expectedLogs = listOf(
            LogEntry(
                OffsetDateTime.parse("2024-10-01T14:34:56.789+02:00"),
                "itest",
                "my message",
                LogLevel.ERROR,
                mapOf("key1" to "value1", "key2" to "value2")
            ),
            LogEntry(
                OffsetDateTime.parse("2024-10-01T14:36:12.546+02:00"),
                "itest",
                "my warning",
                LogLevel.WARNING
            )
        )

        verify(splunkHecClient).sendLogs(expectedLogs)
    }

    @Test
    fun `should fail when required request params missing`() {
        val logEntriesJson = """
            [
                {
                    "time": 1728147499.452,
                    "message": "my message",
                    "level": "INFO"
                }
            ]
        """.trimIndent()

        mockMvc.perform(
            post("/api/v1/logging/logs")
                .with(
                    jwt()
                        .jwt { jwt ->
                            jwt.claims { claims ->
                                claims.put(
                                    "tid",
                                    "3409e798-d567-49b1-9bae-f0be66427c54"
                                )
                            }
                        }
                        .authorities(SimpleGrantedAuthority("ROLE_admin"))
                )
                .contentType(MediaType.APPLICATION_JSON)
                .content(logEntriesJson)
        )
            .andExpect(status().isBadRequest)
    }
}
