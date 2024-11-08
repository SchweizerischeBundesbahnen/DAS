package ch.sbb.backend.domain.logging

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import org.springframework.web.reactive.function.client.WebClient
import org.springframework.web.reactive.function.client.WebClientResponseException
import org.springframework.web.server.ResponseStatusException

@Service
class SplunkLogService(
    @Value("\${splunk.url}") private val url: String,
    @Value("\${splunk.token}") private val token: String
) : LogService {
    private val log = LoggerFactory.getLogger(SplunkLogService::class.java)
    private val webClient: WebClient = WebClient.create(url)

    override fun logs(logEntries: List<LogEntry>) {
        webClient.post()
            .headers { it["Authorization"] = "Splunk $token" }
            .bodyValue(logEntries.map { it.toSplunkRequest() })
            .retrieve()
            .bodyToMono(Object::class.java)
            .doOnError(WebClientResponseException::class.java) {
                log.error("Error sending logs to Splunk status=${it.statusCode} body=${it.responseBodyAsString}")
                throw ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR)
            }
            .block()
    }
}
