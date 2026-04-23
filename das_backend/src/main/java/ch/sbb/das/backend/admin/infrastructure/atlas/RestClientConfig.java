package ch.sbb.das.backend.admin.infrastructure.atlas;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.client.OAuth2ClientHttpRequestInterceptor;
import org.springframework.web.client.RestClient;

@Configuration
public class RestClientConfig {

    public static final String OAUTH2_CLIENT_REGISTRATION_ID = "atlas";

    @Value("${atlas.base-url}")
    private String apiBaseUrl;

    @Bean
    public RestClient.Builder restClient(OAuth2AuthorizedClientManager authorizedClientManager) {
        OAuth2ClientHttpRequestInterceptor requestInterceptor =
            new OAuth2ClientHttpRequestInterceptor(authorizedClientManager);

        return RestClient.builder()
            .baseUrl(apiBaseUrl)
            .requestInterceptor(requestInterceptor);
    }
}
