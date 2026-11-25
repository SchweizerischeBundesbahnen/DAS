package ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration;

import ch.sbb.das.backend.common.downstream.DownstreamRestClients;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.AuthorizedClientServiceOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientProviderBuilder;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.endpoint.RestClientClientCredentialsTokenResponseClient;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;

@Configuration
public class SferaAuthConfig {

    /**
     * Shared by every client registration (azure for SFERA, atlas, orca); the Entra ID token calls get the timeouts of {@code downstream.oauth2-token}.
     */
    @Bean
    public OAuth2AuthorizedClientManager authorizedClientManager(
        ClientRegistrationRepository clientRegistrationRepository,
        OAuth2AuthorizedClientService authorizedClientService,
        DownstreamRestClients downstreamRestClients) {
        RestClientClientCredentialsTokenResponseClient tokenResponseClient = new RestClientClientCredentialsTokenResponseClient();
        tokenResponseClient.setRestClient(downstreamRestClients.oauth2TokenRestClient());

        AuthorizedClientServiceOAuth2AuthorizedClientManager authorizedClientManager = new AuthorizedClientServiceOAuth2AuthorizedClientManager(
            clientRegistrationRepository, authorizedClientService);
        authorizedClientManager.setAuthorizedClientProvider(OAuth2AuthorizedClientProviderBuilder.builder()
            .clientCredentials(clientCredentials -> clientCredentials.accessTokenResponseClient(tokenResponseClient))
            .build());
        return authorizedClientManager;
    }
}

