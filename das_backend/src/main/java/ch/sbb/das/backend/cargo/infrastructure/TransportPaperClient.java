package ch.sbb.das.backend.cargo.infrastructure;

import static org.springframework.security.oauth2.client.web.ClientAttributes.clientRegistrationId;

import ch.sbb.das.backend.cargo.infrastructure.model.TransportPaperLinkResponse;
import ch.sbb.das.backend.common.ProxyClientException;
import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.client.OAuth2ClientHttpRequestInterceptor;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;

/**
 * Datasource: ORCA
 *
 * @see <a href="https://developer-int.sbb.ch/apis/orca-api-test/information">ORCA API</a>
 */
@Component
public class TransportPaperClient {

    private static final String OAUTH2_CLIENT_REGISTRATION_ID = "orca";
    private final RestClient restClient;

    public TransportPaperClient(
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

    public String getDownloadUrl(
        String trainPathId,
        LocalDate operationalDay,
        String countryCodeIso,
        Integer locationPrimaryCode,
        Integer passIndex,
        String acceptLanguage
    ) {
        TransportPaperLinkResponse response = restClient.get()
            .uri(uriBuilder -> uriBuilder
                .path("/transport-paper/1.0/train-path/{trainPathId}/{operationalDay}")
                .queryParam("countryCodeIso", countryCodeIso)
                .queryParam("locationPrimaryCode", locationPrimaryCode)
                .queryParam("bpZusatzId", passIndex)
                .build(trainPathId, operationalDay)
            )
            .header(HttpHeaders.ACCEPT_LANGUAGE, acceptLanguage)
            .attributes(clientRegistrationId(OAUTH2_CLIENT_REGISTRATION_ID))
            .retrieve()
            .body(TransportPaperLinkResponse.class);

        if (response == null) {
            throw new ProxyClientException(HttpStatus.BAD_GATEWAY, "No response body returned from transport paper API");
        }
        return response.downloadUrl();
    }
}
