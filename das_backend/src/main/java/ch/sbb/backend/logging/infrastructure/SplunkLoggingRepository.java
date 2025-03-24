package ch.sbb.backend.logging.infrastructure;

import ch.sbb.backend.logging.domain.LogEntry;
import ch.sbb.backend.logging.domain.repository.LoggingRepository;
import ch.sbb.backend.logging.infrastructure.rest.SplunkHecClient;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class SplunkLoggingRepository implements LoggingRepository {

    private final SplunkHecClient splunkHecClient;

    public SplunkLoggingRepository(SplunkHecClient splunkHecClient) {
        this.splunkHecClient = splunkHecClient;
    }

    @Override
    public void saveAll(List<LogEntry> logs) {
        splunkHecClient.sendLogs(logs);
    }
}
