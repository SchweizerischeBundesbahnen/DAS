package ch.sbb.backend.logging.domain.service;

import ch.sbb.backend.logging.domain.model.LogEntry;
import ch.sbb.backend.logging.domain.model.LogLevel;
import ch.sbb.backend.logging.domain.model.LogTarget;
import ch.sbb.backend.logging.domain.model.Tenant;
import ch.sbb.backend.logging.domain.repository.TenantRepository;
import ch.sbb.backend.logging.infrastructure.SplunkLoggingRepository;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class LoggingServiceImplTest {

    private LoggingServiceImpl sut;
    private TenantRepository tenantRepository;
    private SplunkLoggingRepository splunkLoggingRepository;

    @BeforeEach
    void setUp() {
        tenantRepository = Mockito.mock(TenantRepository.class);
        splunkLoggingRepository = Mockito.mock(SplunkLoggingRepository.class);
        sut = new LoggingServiceImpl(splunkLoggingRepository);
    }

    @Test
    void shouldLogMessagesToSplunk() {
        Tenant tenantConfig = new Tenant("test", "10", "", "", LogTarget.SPLUNK);
        Mockito.when(tenantRepository.current()).thenReturn(tenantConfig);

        OffsetDateTime timestamp = OffsetDateTime.now();
        List<LogEntry> logEntries = Collections.singletonList(
            new LogEntry(timestamp, "source", "message", LogLevel.INFO, null)
        );

        sut.saveAll(logEntries);

        List<LogEntry> expectedLogs = Collections.singletonList(
            new LogEntry(timestamp, "source", "message", LogLevel.INFO, null)
        );
        Mockito.verify(splunkLoggingRepository, Mockito.times(1)).saveAll(expectedLogs);
    }
}

