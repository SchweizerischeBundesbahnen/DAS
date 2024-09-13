package ch.sbb.sferamock.config;

import ch.sbb.sferamock.auth.TenantJwsKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.proc.ConfigurableJWTProcessor;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;
import com.nimbusds.jwt.proc.JWTProcessor;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.function.Predicate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.JwtBearerOAuth2AuthorizedClientProvider;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientProvider;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientProviderBuilder;
import org.springframework.security.oauth2.client.endpoint.DefaultJwtBearerTokenResponseClient;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.DefaultOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.OAuth2AuthorizedClientRepository;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimNames;
import org.springframework.security.oauth2.jwt.JwtClaimValidator;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtTimestampValidator;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;

@Configuration
public class ApplicationConfiguration {

    // The audience is important because the JWT token is accepted only if the aud claim in the JWT token received by the server is the same as the client ID of the server.
    @Value("${spring.security.oauth2.resourceserver.jwt.audience}")
    String[] audiences;

    @Bean
    JwtDecoder jwtDecoder(TenantJwsKeySelector keySelector) {
        NimbusJwtDecoder nimbusJwtDecoder = new NimbusJwtDecoder(jwtProcessor(keySelector));
        nimbusJwtDecoder.setJwtValidator(jwtValidator());
        return nimbusJwtDecoder;
    }

    @Bean
    public JWTProcessor<SecurityContext> jwtProcessor(TenantJwsKeySelector keySelector) {
        ConfigurableJWTProcessor<SecurityContext> jwtProcessor = new DefaultJWTProcessor<>();
        jwtProcessor.setJWTClaimsSetAwareJWSKeySelector(keySelector);
        return jwtProcessor;
    }

    @Bean
    public OAuth2AuthorizedClientManager authorizedClientManager(
            ClientRegistrationRepository clientRegistrationRepository,
            OAuth2AuthorizedClientRepository authorizedClientRepository) {

        OAuth2AuthorizedClientProvider authorizedClientProvider = OAuth2AuthorizedClientProviderBuilder.builder()
                .provider(jwtBearerOAuth2AuthorizedClientProvider())
                .build();
        DefaultOAuth2AuthorizedClientManager authorizedClientManager = new DefaultOAuth2AuthorizedClientManager(clientRegistrationRepository, authorizedClientRepository);
        authorizedClientManager.setAuthorizedClientProvider(authorizedClientProvider);
        return authorizedClientManager;
    }

    private JwtBearerOAuth2AuthorizedClientProvider jwtBearerOAuth2AuthorizedClientProvider() {
        JwtBearerOAuth2AuthorizedClientProvider provider = new JwtBearerOAuth2AuthorizedClientProvider();
        provider.setAccessTokenResponseClient(oAuth2AccessTokenResponseClient());
        return provider;
    }

    private DefaultJwtBearerTokenResponseClient oAuth2AccessTokenResponseClient() {
        DefaultJwtBearerTokenResponseClient client = new DefaultJwtBearerTokenResponseClient();
        client.setRequestEntityConverter(new TokenExchangeJwtBearerGrantRequestEntityConverter());
        return client;
    }

    private OAuth2TokenValidator<Jwt> jwtValidator() {
        List<OAuth2TokenValidator<Jwt>> validators = new ArrayList<>();
        if (audiences != null && audiences.length > 0) {
            validators.add(new JwtClaimValidator<>(JwtClaimNames.AUD, audiencePredicate()));
        }
        validators.add(new JwtTimestampValidator());
        return new DelegatingOAuth2TokenValidator<>(validators);
    }

    Predicate<Object> audiencePredicate() {
        return aud -> {
            if (aud == null) {
                return false;
            } else if (aud instanceof String) {
                return Arrays.stream(audiences).toList().contains(aud);
            } else if (aud instanceof List) {
                return new HashSet<>(Arrays.stream(audiences).toList()).containsAll((List<?>) aud);
            } else {
                return false;
            }
        };
    }

}
