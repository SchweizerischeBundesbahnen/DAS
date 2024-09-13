package ch.sbb.sferamock.controller;

import ch.sbb.sferamock.model.azure.Action;
import ch.sbb.sferamock.model.azure.Claims;
import ch.sbb.sferamock.model.azure.TokenIssuanceStartRequest;
import ch.sbb.sferamock.model.azure.TokenIssuanceStartResponse;
import ch.sbb.sferamock.model.azure.TokenIssuanceStartResponseData;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("customClaim")
public class CustomClaimController {

    private static final Logger log = LoggerFactory.getLogger(CustomClaimController.class);
    private final Map<String, Claims> tokenClaimDataMap = new HashMap<>();

    private final OAuth2AuthorizedClientManager manager;

    public CustomClaimController(@Qualifier("authorizedClientManager") OAuth2AuthorizedClientManager manager) {
        this.manager = manager;
    }

    @GetMapping("requestToken")
    String tokenRequest(Authentication authentication, String ru, String train, String role) {

        String userId = (String) ((Jwt) (authentication.getPrincipal())).getClaims().get("oid");
        log.info("Received token request for {} with ru={} train={} role={}", userId, ru, train, role);

        tokenClaimDataMap.put(userId, new Claims(ru, train, role));

        OAuth2AuthorizeRequest oAuth2AuthorizeRequest = OAuth2AuthorizeRequest.withClientRegistrationId("exchange")
            .principal(authentication)
            .build();

        OAuth2AuthorizedClient client = manager.authorize(oAuth2AuthorizeRequest);
        if (client == null) {
            throw new IllegalStateException(
                "failed to retrieve sfera-token failed, client is null");
        }
        return client.getAccessToken().getTokenValue();
    }

    @PostMapping
    TokenIssuanceStartResponse tokenIssuanceStartEvent(Authentication authentication, @RequestBody TokenIssuanceStartRequest body) {
        log.info("Received tokenUssuanceStartEvent with authentication: {}", authentication);

        String userId = body.data().authenticationContext().user().id();
        Claims claims;

        if (tokenClaimDataMap.containsKey(userId)) {
            log.info("Returning user provided claims");
            claims = tokenClaimDataMap.get(userId);
            tokenClaimDataMap.remove(userId);
        } else {
            log.info("Returning default claims");
            claims = new Claims("1085", "719_2024-06-13", "active");
        }

        Action action = new Action("microsoft.graph.tokenIssuanceStart.provideClaimsForToken", claims);
        TokenIssuanceStartResponseData responseData = new TokenIssuanceStartResponseData("microsoft.graph.onTokenIssuanceStartResponseData", List.of(action));
        TokenIssuanceStartResponse response = new TokenIssuanceStartResponse(responseData);
        log.info("Response: {}", response);
        return response;
    }

}
