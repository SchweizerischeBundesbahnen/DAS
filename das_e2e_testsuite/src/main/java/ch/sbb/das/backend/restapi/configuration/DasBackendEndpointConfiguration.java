package ch.sbb.das.backend.restapi.configuration;

import lombok.extern.slf4j.Slf4j;
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

@Slf4j
@Configuration
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend_SAMPLE.properties")
// override sample with concrete env settings
@PropertySource(value = "file:../das_e2e_testsuite/src/main/resources/DAS-Backend.properties", ignoreResourceNotFound = true)
public class DasBackendEndpointConfiguration {

    /**
     * @see <a href="https://www.microsoft.com/en-us/security/business/identity-access/microsoft-entra-id">MS Entra Id</a>
     */
    public static final String AUTHORIZATION_PROVIDER = "azure";

    @Value("${AUTH_TOKEN_ENDPOINT}")
    private String ssoTokenEndpoint;
    @Value("${AUTH_SCOPE}")
    private String scope;
    @Value("${AUTH_CLIENT_ID}")
    private String clientId;
    @Value("${AUTH_CLIENT_SECRET}")
    private String clientSecret;

    @Value("${DAS_BACKEND_ENDPOINT}")
    private String endpoint;
    @Value("${DAS_BACKEND_PORT}")
    private String port;

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

    @Bean
    public DasBackendEndpoint endpoint() {
        final DasBackendEndpoint backendEndpoint = DasBackendEndpoint.builder()
            .endpoint(endpoint)
            .port(port)
            .build();

        if (backendEndpoint.isLocalHost()) {
            log.info("localhost data under test");
        } else if (backendEndpoint.isDev()) {
            log.info("DEV data under test");
        } else {
            log.warn("Environment under test unclear");
        }

        return backendEndpoint;
    }

    public String getEndpointAndPort() {
        return endpoint + ":" + port;
    }
}
