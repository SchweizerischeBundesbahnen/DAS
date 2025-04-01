package ch.sbb.backend.logging.domain.repository;

import ch.sbb.backend.logging.domain.model.LogEntry;
import java.util.List;

public interface LoggingRepository {

    void saveAll(List<LogEntry> logs);
}
