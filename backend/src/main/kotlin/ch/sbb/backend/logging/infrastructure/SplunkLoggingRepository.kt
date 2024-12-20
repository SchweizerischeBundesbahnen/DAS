package ch.sbb.backend.logging.infrastructure

import ch.sbb.backend.logging.domain.LogEntry
import ch.sbb.backend.logging.domain.repository.LoggingRepository
import ch.sbb.backend.logging.infrastructure.rest.SplunkHecClient
import org.springframework.stereotype.Component

@Component
class SplunkLoggingRepository(private val splunkHecClient: SplunkHecClient) : LoggingRepository {
    override fun saveAll(logs: List<LogEntry>) {
        splunkHecClient.sendLogs(logs)
    }
}
