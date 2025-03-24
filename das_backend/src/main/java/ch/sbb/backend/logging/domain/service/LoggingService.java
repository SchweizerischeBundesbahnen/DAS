package ch.sbb.backend.logging.domain.service;

import ch.sbb.backend.logging.domain.LogEntry;
import java.util.List;

public interface LoggingService {

    void saveAll(List<LogEntry> logEntries);
}
