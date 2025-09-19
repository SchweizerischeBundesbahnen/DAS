package ch.sbb.backend.preload;

import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.core.OAuth2AuthorizationException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

@Service
@Slf4j
public class SferaAuthService {

    private final OAuth2AuthorizedClientManager authorizedClientManager;

    public SferaAuthService(
        OAuth2AuthorizedClientManager authorizedClientManager) {
        this.authorizedClientManager = authorizedClientManager;
    }

    String fetchNewToken() {
        try {

            OAuth2AuthorizeRequest request = OAuth2AuthorizeRequest.withClientRegistrationId("azure")
                .principal("clientCredentials")
                .build();
            OAuth2AuthorizedClient authorizedClient = authorizedClientManager.authorize(request);
            if (authorizedClient == null || authorizedClient.getAccessToken() == null) {
                log.error("Failed to obtain OAuth2 token");
            }
            String accessToken = authorizedClient.getAccessToken().getTokenValue();
            System.out.println(accessToken);
            return accessToken;
        } catch (OAuth2AuthorizationException ex) {
            // Handle different types of OAuth2 errors here (e.g., invalid credentials, etc.)
            log.error("OAuth2 Token API authorization failed: " + ex.getMessage(), ex);
        } catch (RestClientException ex) {
            // Handle connection issues, timeouts, etc.
            log.error("Error while connecting to the OAuth2 Token API: " + ex.getMessage(), ex);
        }
        return null;
    }

    public void exchange(String token, String ru, String train, String role) {
        String url = "https://imts-token-provider-tms-vad-imtrackside-dev-main.apps.halon-hera-np.sbb-aws-test.net/token/exchange"; // ?ru=1085&train=715_2025-09-19&role=read-only
        var restClient = RestClient.builder()
            .baseUrl(url)
            .build();
        String response = restClient.get()
            .uri(uriBuilder -> uriBuilder
                .queryParam("ru", ru)
                .queryParam("train", train)
                .queryParam("role", role)
                .build())
            .header("Authorization", "Bearer " + token)
            .retrieve()
            .body(String.class);
        log.info("Exchange response: {}", response);
    }
}
