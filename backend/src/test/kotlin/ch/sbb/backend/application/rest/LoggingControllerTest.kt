package ch.sbb.backend.application.rest

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.io.ByteArrayOutputStream
import java.io.PrintStream

@SpringBootTest
@AutoConfigureMockMvc
class LoggingControllerTest {

    @Autowired
    private lateinit var mockMvc: MockMvc

    private val originalOut = System.out
    private val outputStreamCaptor = ByteArrayOutputStream()

    @BeforeEach
    fun setUp() {
        System.setOut(PrintStream(outputStreamCaptor))
    }

    @AfterEach
    fun tearDown() {
        System.setOut(originalOut)
    }

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
                                    "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                                )
                            }
                        }
                        .authorities(SimpleGrantedAuthority("ROLE_admin"))
                )
                .contentType(MediaType.APPLICATION_JSON)
                .content(logEntriesJson)
        )
            .andExpect(status().isOk)

        val output = outputStreamCaptor.toString()
        assertTrue(output.contains("2024-10-05T18:58:19.452+02:00\tINFO\titest\tmy message {}"))
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
                                    "d653d01f-17a4-48a1-9aab-b780b61b4273"
                                )
                            }
                        }
                        .authorities(SimpleGrantedAuthority("ROLE_admin"))
                )
                .contentType(MediaType.APPLICATION_JSON)
                .content(logEntriesJson)
        )
            .andExpect(status().isOk)

        val output = outputStreamCaptor.toString()
        assertTrue(output.lines()[0].contains("SPLUNK: 2024-10-01T14:34:56.789+02:00\tERROR\titest\tmy message {key1=value1, key2=value2}"))
        assertTrue(output.lines()[1].contains("SPLUNK: 2024-10-01T14:36:12.546+02:00\tWARNING\titest\tmy warning {}"))
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
                                    "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
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
