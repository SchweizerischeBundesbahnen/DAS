package ch.sbb.backend.logging;

import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.logging.domain.model.LogEntry;
import ch.sbb.backend.logging.domain.model.LogLevel;
import ch.sbb.backend.logging.infrastructure.rest.SplunkHecClient;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestContainerConfiguration.class)
class LoggingControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private SplunkHecClient splunkHecClient;

    @Test
    void should_log_messages_with_seconds_since_epoch_timestamp() throws Exception {
        String logEntriesJson = """
                [
                    {
                        "time": 1728147499.452,
                        "source": "itest",
                        "message": "my message",
                        "level": "INFO"
                    }
                ]
            """;

        mockMvc.perform(
                post("/api/v1/logging/logs")
                    .with(jwt()
                        .jwt(jwt -> jwt.claims(claims -> claims.put("tid", "3409e798-d567-49b1-9bae-f0be66427c54")))
                        .authorities(new SimpleGrantedAuthority("ROLE_admin")))
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(logEntriesJson)
            )
            .andExpect(status().isOk());

        var expectedLogs = List.of(new LogEntry(
            OffsetDateTime.parse("2024-10-05T18:58:19.452+02:00"),
            "itest",
            "my message",
            LogLevel.INFO,
            Collections.emptyMap()
        ));

        verify(splunkHecClient).sendLogs(expectedLogs);

    }

    @Test
    void shoud_log_messages_with_UTC_timestamp() throws Exception {
        String logEntriesJson = """
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
            """;

        mockMvc.perform(
                post("/api/v1/logging/logs")
                    .with(jwt()
                        .jwt(jwt -> jwt.claims(claims -> claims.put("tid", "3409e798-d567-49b1-9bae-f0be66427c54")))
                        .authorities(new SimpleGrantedAuthority("ROLE_admin")))
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(logEntriesJson)
            )
            .andExpect(status().isOk());

        var expectedLogs = List.of(new LogEntry(
            OffsetDateTime.parse("2024-10-01T14:34:56.789+02:00"),
            "itest",
            "my message",
            LogLevel.ERROR,
            Map.of("key1", "value1", "key2", "value2")
        ), new LogEntry(
            OffsetDateTime.parse("2024-10-01T14:36:12.546+02:00"),
            "itest",
            "my warning",
            LogLevel.WARNING,
            Collections.emptyMap()
        ));

        verify(splunkHecClient).sendLogs(expectedLogs);

    }

    @Test
    void should_bad_request_when_required_param_level_missing() throws Exception {
        String logEntriesJson = """
                [
                    {
                        "time": "2025-02-16T12:03:17+01:00",
                        "source": "ittest",
                        "message": "message without level"
                    }
                ]
            """;

        mockMvc.perform(
                post("/api/v1/logging/logs")
                    .with(jwt()
                        .jwt(jwt -> jwt.claims(claims -> claims.put("tid", "3409e798-d567-49b1-9bae-f0be66427c54")))
                        .authorities(new SimpleGrantedAuthority("ROLE_admin")))
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(logEntriesJson)
            )
            .andExpect(status().isBadRequest());

        verify(splunkHecClient, times(0)).sendLogs(null);
    }
}
