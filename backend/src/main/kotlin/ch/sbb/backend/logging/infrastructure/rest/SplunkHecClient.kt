package ch.sbb.backend.logging.infrastructure.rest

import ch.sbb.backend.logging.domain.LogEntry
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.WebClientResponseException
import org.springframework.web.server.ResponseStatusException

@Service
class SplunkHecClient(
    @Value("\${splunk.url}") private val url: String,
    @Value("\${splunk.token}") private val token: String
) {
    private val log = LoggerFactory.getLogger(SplunkHecClient::class.java)
    private val webClient: WebClient = WebClient.create(url)

    fun sendLogs(logEntries: List<LogEntry>) {
        webClient.post()
            .headers { it["Authorization"] = "Splunk $token" }
            .bodyValue(logEntries.map { mapToRequest(it) })
            .retrieve()
            .bodyToMono(Object::class.java)
            .doOnError(WebClientResponseException::class.java) {
                log.error("Error sending logs to Splunk status=${it.statusCode} body=${it.responseBodyAsString}")
                throw ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR)
            }
            .block()
    }

    private fun mapToRequest(logEntry: LogEntry): SplunkRequest {
        val fields = logEntry.metadata?.toMutableMap() ?: mutableMapOf()
        fields["level"] = logEntry.level.value
        return SplunkRequest(
            event = logEntry.message,
            fields = fields,
            source = logEntry.source,
            time = logEntry.time,
        )
    }
}
