package ch.sbb.sferamock.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.ClientRegistrations;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimNames;

@Configuration
public class DynamicClientRegistrationRepository implements ClientRegistrationRepository {

    @Value("${auth.exchange.client-id}")
    private String clientId;

    @Value("${auth.exchange.client-secret}")
    private String clientSecret;

    @Value("${auth.exchange.scope}")
    private String scope;

    @Override
    public ClientRegistration findByRegistrationId(String registrationId) {
        String issuerUri = (String) ((Jwt) (SecurityContextHolder.getContext().getAuthentication().getPrincipal())).getClaims().get(JwtClaimNames.ISS);
        return ClientRegistrations.fromIssuerLocation(issuerUri)
            .authorizationGrantType(AuthorizationGrantType.JWT_BEARER)
            .clientId(clientId)
            .clientSecret(clientSecret)
            .scope(scope)
            .build();
    }
}
