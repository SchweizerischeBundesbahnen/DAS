package ch.sbb.das.backend.restapi.configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.security.oauth2.client.AuthorizedClientServiceReactiveOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.InMemoryReactiveOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.ReactiveOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.ReactiveOAuth2AuthorizedClientProvider;
import org.springframework.security.oauth2.client.ReactiveOAuth2AuthorizedClientProviderBuilder;
import org.springframework.security.oauth2.client.ReactiveOAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.InMemoryReactiveClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.ReactiveClientRegistrationRepository;
import org.springframework.security.oauth2.core.AuthorizationGrantType;

@Configuration
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend_SAMPLE.properties")
// override sample with concrete env settings
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend.properties", ignoreResourceNotFound = true)
public class OAuth2Configuration {

    /**
     * @see <a href="https://www.microsoft.com/en-us/security/business/identity-access/microsoft-entra-id">MS Entra Id</a>
     */
    public static final String AUTHORIZATION_PROVIDER = "azure";

    @Value("${auth.token-endpoint}")
    private String ssoTokenEndpoint;
    @Value("${auth.scope}")
    private String scope;
    @Value("${auth.client-id}")
    private String clientId;
    @Value("${auth.client-secret}")
    private String clientSecret;

    @Bean
    public ReactiveOAuth2AuthorizedClientManager authorizedClientManager(
        ReactiveClientRegistrationRepository clientRegistrationRepository,
        ReactiveOAuth2AuthorizedClientService authorizedClientService) {

        ReactiveOAuth2AuthorizedClientProvider authorizedClientProvider =
            ReactiveOAuth2AuthorizedClientProviderBuilder.builder()
                .clientCredentials()
                .build();

        AuthorizedClientServiceReactiveOAuth2AuthorizedClientManager authorizedClientManager =
            new AuthorizedClientServiceReactiveOAuth2AuthorizedClientManager(
                clientRegistrationRepository, authorizedClientService);
        authorizedClientManager.setAuthorizedClientProvider(authorizedClientProvider);

        return authorizedClientManager;
    }

    @Bean
    public ReactiveClientRegistrationRepository clientRegistrationRepository() {
        ClientRegistration registration = ClientRegistration.withRegistrationId(AUTHORIZATION_PROVIDER)
            .clientId(clientId)
            .clientSecret(clientSecret)
            .authorizationGrantType(AuthorizationGrantType.CLIENT_CREDENTIALS)
            .scope(scope)
            .tokenUri(ssoTokenEndpoint)
            .build();
        return new InMemoryReactiveClientRegistrationRepository(registration);
    }

    @Bean
    public ReactiveOAuth2AuthorizedClientService authorizedClientService(
        ReactiveClientRegistrationRepository clientRegistrationRepository) {
        return new InMemoryReactiveOAuth2AuthorizedClientService(clientRegistrationRepository);
    }
}
