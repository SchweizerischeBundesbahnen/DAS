package ch.sbb.das.backend.departures.internal;

import ch.sbb.das.backend.common.downstream.Downstream;
import ch.sbb.das.backend.common.downstream.DownstreamCalls;
import ch.sbb.das.backend.common.downstream.DownstreamRestClients;
import java.util.Base64;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * REST client that integrates DAS-Client with GEMS (subscription system for customer oriented departure), with DAS-Backend acting as the proxy layer. Datasource: GEMS
 */
@Component
public class GemsRestClient {

    private final RestClient restClient;
    private final DownstreamCalls downstreamCalls;

    public GemsRestClient(
        DownstreamRestClients downstreamRestClients,
        DownstreamCalls downstreamCalls,
        @Value("${proxy.base-url}") String baseUrl,
        @Value("${proxy.basic-auth}") String auth
    ) {
        String encodedAuth = "Basic " + Base64.getEncoder().encodeToString(auth.getBytes());

        this.restClient = downstreamRestClients.builder(Downstream.GEMS)
            .baseUrl(baseUrl)
            .defaultHeaders(h -> h.set(HttpHeaders.AUTHORIZATION, encodedAuth))
            .build();
        this.downstreamCalls = downstreamCalls;
    }

    // A retry may subscribe or confirm twice. GEMS accepts that, because DAS-Client resends a subscription with the same messageId until it is confirmed.
    public ResponseEntity<?> subscribe(SubscribeRequest request) {
        return downstreamCalls.call(Downstream.GEMS, "subscribe", () -> restClient.post()
            .uri("/rest/das/subscribe")
            .body(request)
            .retrieve()
            .toEntity(String.class));
    }

    public ResponseEntity<?> confirm(String messageId, String deviceId) {
        return downstreamCalls.call(Downstream.GEMS, "confirm", () -> restClient.post()
            .uri("/rest/das/confirm/{messageId}/{deviceId}", messageId, deviceId)
            .retrieve()
            .toEntity(String.class));
    }
}

