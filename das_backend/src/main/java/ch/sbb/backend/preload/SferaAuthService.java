package ch.sbb.backend.preload;

import java.time.Instant;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.OAuth2AuthorizationException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;

@Service
@Slf4j
public class SferaAuthService {

    public static final String REGISTRATION_ID = "azure";
    private final OAuth2AuthorizedClientManager authorizedClientManager;

    private OAuth2AccessToken accessToken;

    public SferaAuthService(OAuth2AuthorizedClientManager authorizedClientManager) {
        this.authorizedClientManager = authorizedClientManager;
    }

    private static boolean isTokenValid(OAuth2AccessToken token) {
        return token != null && token.getExpiresAt() != null && token.getExpiresAt().isAfter(Instant.now());
    }

    public OAuth2AccessToken getAccessToken() {
        if (!isTokenValid(accessToken)) {
            setAccessToken();
        }
        return accessToken;
    }

    private void setAccessToken() {
        accessToken = null;
        try {
            OAuth2AuthorizeRequest request = OAuth2AuthorizeRequest
                .withClientRegistrationId(REGISTRATION_ID)
                .principal(REGISTRATION_ID)
                .build();
            OAuth2AuthorizedClient authorizedClient = authorizedClientManager.authorize(request);
            if (authorizedClient == null) {
                log.error("Failed to obtain OAuth2 token");
                return;
            }
            this.accessToken = authorizedClient.getAccessToken();
        } catch (OAuth2AuthorizationException ex) {
            // Handle different types of OAuth2 errors here (e.g., invalid credentials, etc.)
            log.error("OAuth2 Token API authorization failed: " + ex.getMessage(), ex);
        } catch (RestClientException ex) {
            // Handle connection issues, timeouts, etc.
            log.error("Error while connecting to the OAuth2 Token API: " + ex.getMessage(), ex);
        }
    }
}
