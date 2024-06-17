package ch.sbb.playgroundbackend.controller;

import ch.sbb.playgroundbackend.model.azure.Action;
import ch.sbb.playgroundbackend.model.azure.Claims;
import ch.sbb.playgroundbackend.model.azure.TokenIssuanceStartRequest;
import ch.sbb.playgroundbackend.model.azure.TokenIssuanceStartResponse;
import ch.sbb.playgroundbackend.model.azure.TokenIssuanceStartResponseData;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("customClaim")
@RequiredArgsConstructor
public class CustomClaimController {

    private static final Logger log = LoggerFactory.getLogger(CustomClaimController.class);

    private final OAuth2AuthorizedClientManager manager;
    private final ClientRegistrationRepository clientRegistrationRepository;
    public static final String SFERA_TOKEN_REGISTRATION = "sfera-token";

    private final Map<String, Claims> tokenClaimDataMap = new HashMap<>();

    @GetMapping("requestToken")
    String tokenRequest(Authentication authentication, @RequestHeader Map<String, String> headers, String ru, String train, String role) {

        String userId = (String) ((Jwt) (authentication.getPrincipal())).getClaims().get("oid");
        log.info("Received token request for {} with ru={} train={} role={}", userId, ru, train, role);

        tokenClaimDataMap.put(userId, new Claims(ru, train, role));

        var clientRegistration = clientRegistrationRepository.findByRegistrationId(SFERA_TOKEN_REGISTRATION);

        OAuth2AuthorizeRequest oAuth2AuthorizeRequest = OAuth2AuthorizeRequest.withClientRegistrationId(
                        clientRegistration.getRegistrationId())
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
    TokenIssuanceStartResponse tokenIssuanceStartEvent(Authentication authentication, @RequestHeader Map<String, String> headers, @RequestBody TokenIssuanceStartRequest body) {
        log.info("Received tokenUssuanceStartEvent with authentication: {}", authentication);

        log.info("Token:");
        ((Jwt)authentication.getPrincipal()).getClaims().forEach((k, v) -> log.info("{} -> {}", k, v));
        
        log.info("Headers:");
        headers.forEach((k, v) -> log.info("{} -> {}", k, v));

        log.info("Client: {}", body.data().authenticationContext().client());
        log.info("ClientServicePrincipal: {}", body.data().authenticationContext().clientServicePrincipal());
        log.info("ResourceServicePrincipal: {}", body.data().authenticationContext().resourceServicePrincipal());
        log.info("User: {}", body.data().authenticationContext().user());

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
