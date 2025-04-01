package ch.sbb.backend.logging.domain.service;

import ch.sbb.backend.logging.domain.model.LogEntry;
import ch.sbb.backend.logging.domain.repository.LoggingRepository;
import java.util.List;

public class DomainLoggingService implements LoggingService {

    private final LoggingRepository loggingRepository;

    public DomainLoggingService(LoggingRepository loggingRepository) {
        this.loggingRepository = loggingRepository;
    }

    @Override
    public void saveAll(List<LogEntry> logEntries) {
        loggingRepository.saveAll(logEntries);
    }
}
