package ch.sbb.das.backend.common;

import static ch.sbb.das.backend.personalnotes.internal.PersonalNoteController.API_PERSONAL_NOTES;
import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.error.ProblemFactory;
import ch.sbb.das.backend.common.security.UserRole;
import java.util.List;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.logging.LoggingInitializationContext;
import org.springframework.boot.logging.LoggingSystem;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.core.env.StandardEnvironment;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/**
 * The stage configuration (every profile but {@code local}) writes one ECS JSON object per log line with the request context as fields.
 * <p>
 * The test profile switches the console back to text, so this test re-enables the structured format. Spring Boot initialises Logback only once per JVM, hence the
 * logging system is reset before this context boots and restored afterwards.
 */
@IntegrationTest
@TestPropertySource(properties = {"logging.structured.format.console=ecs", "STAGE=dev"})
@ExtendWith(OutputCaptureExtension.class)
class StructuredLoggingIntegrationTest {

    private static final String REQUEST_ID = "0c6f3d2e-8a4b-4f1e-9b7d-2e5a1c9f4b83";
    private static final String TRACE_ID = "4bf92f3577b34da6";

    private static final LoggingSystem LOGGING_SYSTEM = LoggingSystem.get(StructuredLoggingIntegrationTest.class.getClassLoader());
    private static final JsonMapper JSON = JsonMapper.builder().build();

    @Autowired
    private MockMvc mockMvc;

    @BeforeAll
    static void resetLoggingSystem() {
        // lets the application context of this test re-initialise Logback with the structured format
        LOGGING_SYSTEM.cleanUp();
    }

    @AfterAll
    static void restoreLoggingSystem() {
        // back to the text default now, and let the next application context re-initialise Logback with its own settings
        LOGGING_SYSTEM.cleanUp();
        LOGGING_SYSTEM.initialize(new LoggingInitializationContext(new StandardEnvironment()), null, null);
        LOGGING_SYSTEM.cleanUp();
    }

    @AfterEach
    void clearMdc() {
        MDC.remove(ProblemFactory.MDC_INSTANA_TRACE_ID);
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("stageConfiguration_request_logsEcsJsonWithRequestContext|gHfacgBAdiB05aHJ0p2c|tests:2651")
    void stageConfiguration_request_logsEcsJsonWithRequestContext(CapturedOutput output) throws Exception {
        // the Instana agent puts the trace id into the MDC of the request thread
        MDC.put(ProblemFactory.MDC_INSTANA_TRACE_ID, TRACE_ID);

        mockMvc.perform(get(API_PERSONAL_NOTES).header(RequestIdFilter.HEADER_REQUEST_ID, REQUEST_ID));

        final JsonNode accessLine = jsonLines(output).stream()
            .filter(line -> "Request handled".equals(line.path("message").asString()))
            .findFirst()
            .orElseThrow(() -> new AssertionError("no JSON access line in:\n" + output.getOut()));

        assertThat(accessLine.path("@timestamp").asString()).endsWith("Z");
        assertThat(accessLine.at("/log/level").asString()).isEqualTo("INFO");
        assertThat(accessLine.at("/log/logger").asString()).isEqualTo(RequestLogger.class.getName());
        assertThat(accessLine.at("/service/name").asString()).isEqualTo("backend");
        assertThat(accessLine.at("/service/environment").asString()).isEqualTo("dev");
        assertThat(accessLine.path("requestId").asString()).isEqualTo(REQUEST_ID);
        assertThat(accessLine.at("/http/request/method").asString()).isEqualTo("GET");
        assertThat(accessLine.at("/url/path").asString()).isEqualTo(API_PERSONAL_NOTES);
        assertThat(accessLine.at("/http/response/status_code").asInt()).isEqualTo(200);
        assertThat(accessLine.path("mdc.instana").at("/trace/id").asString()).isEqualTo(TRACE_ID);
        assertThat(accessLine.has("ecs")).isFalse();
        assertThat(accessLine.at("/process/pid").isMissingNode()).isTrue();
    }

    private static List<JsonNode> jsonLines(CapturedOutput output) {
        return output.getOut().lines()
            .filter(line -> line.startsWith("{"))
            .map(JSON::readTree)
            .toList();
    }
}
