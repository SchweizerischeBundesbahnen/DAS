package ch.sbb.das.backend.cargo.infrastructure;

import static org.springframework.security.oauth2.client.web.ClientAttributes.clientRegistrationId;

import ch.sbb.das.backend.cargo.infrastructure.model.TransportPaperLinkResponse;
import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.client.OAuth2ClientHttpRequestInterceptor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;

@Component
@ConditionalOnProperty(name = "formation.transport-paper.mock.enabled", havingValue = "false", matchIfMissing = true)
public class SbbchTransportPaperClient implements TransportPaperClient {

    private static final String OAUTH2_CLIENT_REGISTRATION_ID = "orca";
    private final RestClient restClient;

    public SbbchTransportPaperClient(
        OAuth2AuthorizedClientManager authorizedClientManager,
        @Value("${formation.transport-paper.orca.base-url:}") String baseUrl
    ) {
        OAuth2ClientHttpRequestInterceptor requestInterceptor =
            new OAuth2ClientHttpRequestInterceptor(authorizedClientManager);

        RestClient.Builder builder = RestClient.builder()
            .requestInterceptor(requestInterceptor);
        if (StringUtils.hasText(baseUrl)) {
            builder.baseUrl(baseUrl);
        }
        this.restClient = builder.build();
    }

    @Override
    public String getDownloadUrl(
        String trainPathId,
        LocalDate operatingDay,
        String countryCodeIso,
        Integer locationPrimaryCode,
        Integer passIndex
    ) {
        TransportPaperLinkResponse response = restClient.get()
            .uri(uriBuilder -> uriBuilder
                .path("/transport-paper/{trainPathId}/{operatingDay}")
                .queryParam("countryCodeIso", countryCodeIso)
                .queryParam("locationPrimaryCode", locationPrimaryCode)
                .queryParam("bpZusatzId", passIndex)
                .build(trainPathId, operatingDay)
            )
            .attributes(clientRegistrationId(OAUTH2_CLIENT_REGISTRATION_ID))
            .retrieve()
            .body(TransportPaperLinkResponse.class);

        if (response == null) {
            throw new IllegalStateException("No response body returned from transport paper API");
        }
        return response.downloadUrl();
    }
}
