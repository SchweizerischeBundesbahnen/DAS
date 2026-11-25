package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.downstream.Downstream;
import ch.sbb.das.backend.common.downstream.DownstreamCalls;
import ch.sbb.das.backend.common.error.DownstreamCallException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class SferaAuthService {

    public static final String REGISTRATION_ID = "azure";
    public static final int TOKEN_REFRESH_MARGIN_SECONDS = 30;
    private final OAuth2AuthorizedClientManager authorizedClientManager;
    private final DownstreamCalls downstreamCalls;

    private OAuth2AccessToken accessToken;

    public SferaAuthService(OAuth2AuthorizedClientManager authorizedClientManager, DownstreamCalls downstreamCalls) {
        this.authorizedClientManager = authorizedClientManager;
        this.downstreamCalls = downstreamCalls;
    }

    private static boolean isTokenValid(OAuth2AccessToken token) {
        return token != null && token.getExpiresAt() != null && token.getExpiresAt().minusSeconds(TOKEN_REFRESH_MARGIN_SECONDS).isAfter(DateTimeUtil.now().toInstant());
    }

    public OAuth2AccessToken getAccessToken() {
        if (!isTokenValid(accessToken)) {
            synchronized (this) {
                if (!isTokenValid(accessToken)) {
                    setAccessToken();
                }
            }
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
            OAuth2AuthorizedClient authorizedClient = downstreamCalls.call(Downstream.SFERA, "authorize", () -> authorizedClientManager.authorize(request));
            if (authorizedClient == null) {
                log.atError().log("SFERA OAuth2 authorization returned no client");
                return;
            }
            this.accessToken = authorizedClient.getAccessToken();
        } catch (DownstreamCallException e) {
            // invalid credentials, timeouts and connection failures after the retries
            log.atError().setCause(e).log("SFERA OAuth2 authorization failed");
        }
    }
}
