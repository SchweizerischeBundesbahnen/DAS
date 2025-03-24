package ch.sbb.backend.logging;

import ch.sbb.backend.logging.domain.LogDestination;
import ch.sbb.backend.logging.domain.LogEntry;
import ch.sbb.backend.logging.domain.LogLevel;
import ch.sbb.backend.logging.domain.Tenant;
import ch.sbb.backend.logging.domain.repository.TenantRepository;
import ch.sbb.backend.logging.domain.service.DomainLoggingService;
import ch.sbb.backend.logging.infrastructure.SplunkLoggingRepository;
import java.time.OffsetDateTime;
import java.util.Collections;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class DomainLoggingServiceTest {

    private DomainLoggingService sut;
    private TenantRepository tenantRepository;
    private SplunkLoggingRepository splunkLoggingRepository;

    @BeforeEach
    void setUp() {
        tenantRepository = Mockito.mock(TenantRepository.class);
        splunkLoggingRepository = Mockito.mock(SplunkLoggingRepository.class);
        sut = new DomainLoggingService(splunkLoggingRepository);
    }

    @Test
    void shouldLogMessagesToSplunk() {
        Tenant tenantConfig = new Tenant("test", "10", "", "", LogDestination.SPLUNK);
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

