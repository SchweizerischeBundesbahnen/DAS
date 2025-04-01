package ch.sbb.backend.logging.infrastructure.rest;

import ch.sbb.backend.logging.domain.model.LogEntry;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SplunkHecClient {

    private final Logger log = LoggerFactory.getLogger(SplunkHecClient.class);
    private final RestClient restClient;

    @Value("${splunk.url}")
    private String url;

    @Value("${splunk.token}")
    private String token;

    public SplunkHecClient() {
        this.restClient = RestClient.create();
    }

    public void sendLogs(List<LogEntry> logEntries) {
        if (logEntries == null || logEntries.isEmpty()) {
            return;
        }
        restClient
            .post()
            .uri(url)
            .headers(headers -> headers.set(HttpHeaders.AUTHORIZATION, "Splunk " + token))
            .body(logEntries.stream().map(this::mapToRequest).toList())
            .retrieve()
            .onStatus(HttpStatusCode::isError, ((request, response) -> {
                log.error("Error sending logs to Splunk status={} body={}", response.getStatusCode().value(), new String(response.getBody().readAllBytes()));
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR);
            }))
            .toBodilessEntity();
    }

    private SplunkRequest mapToRequest(LogEntry logEntry) {
        Map<String, String> fields = logEntry.metadata() != null ? new HashMap<>(logEntry.metadata()) : new HashMap<>();
        fields.put("level", logEntry.level().value());
        return new SplunkRequest(
            logEntry.message(),
            fields,
            logEntry.source(),
            logEntry.time()
        );
    }
}
