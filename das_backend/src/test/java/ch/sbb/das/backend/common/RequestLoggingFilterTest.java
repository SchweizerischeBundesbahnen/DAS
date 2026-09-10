package ch.sbb.das.backend.common;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.read.ListAppender;
import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
class RequestLoggingFilterTest {

    @Autowired
    private MockMvc mockMvc;

    private ListAppender<ILoggingEvent> appender;
    private Logger requestLogger;

    @BeforeEach
    void setUp() {
        requestLogger = (Logger) LoggerFactory.getLogger(RequestLogger.class);
        appender = new ListAppender<>();
        appender.start();
        requestLogger.addAppender(appender);
    }

    @AfterEach
    void tearDown() {
        requestLogger.detachAppender(appender);
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void filter_logsRequest() throws Exception {
        mockMvc.perform(get("/driver/v1/personal-notes"));

        assertThat(appender.list)
            .anySatisfy(event -> {
                assertThat(event.getLevel()).isEqualTo(Level.INFO);
                assertThat(event.getFormattedMessage()).contains("Request path=/driver/v1/personal-notes");
            });
    }
}
