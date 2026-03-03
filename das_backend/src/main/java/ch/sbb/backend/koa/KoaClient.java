package ch.sbb.backend.koa;

import ch.sbb.backend.koa.api.v1.SubscribeRequest;
import java.util.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class KoaClient {

    private final RestClient restClient;

    public KoaClient(
        @Value("${koa.base-url}") String baseUrl,
        @Value("${koa.basic-auth}") String auth
    ) {
        String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes());

        this.restClient = RestClient.builder()
            .baseUrl(baseUrl)
            .defaultHeaders(h -> h.set(HttpHeaders.AUTHORIZATION, encodedAuth))
            .build();
    }

    public ResponseEntity<?> subscribe(SubscribeRequest request) {
        return restClient.post()
            .uri("/rest/das/subscibe")
            .body(request)
            .retrieve()
            .toEntity(String.class);
    }

    public ResponseEntity<?> confirm(String messageId, String deviceId) {
        return restClient.post()
            .uri("/rest/das/confirm/" + messageId + "/" + deviceId)
            .retrieve()
            .toEntity(String.class);
    }
}
