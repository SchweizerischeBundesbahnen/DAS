package ch.sbb.das.backend.restapi.configuration;

import ch.sbb.das.backend.restapi.helper.ObjectMapperFactory;
import ch.sbb.das.backend.restclient.v1.ApiClient;
import io.netty.channel.ChannelOption;
import java.text.DateFormat;
import java.time.Duration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.security.oauth2.client.ReactiveOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.reactive.function.client.ServerOAuth2AuthorizedClientExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;
import tools.jackson.databind.json.JsonMapper;

@Configuration
public class ApiClientConfiguration {

    private final DasBackendEndpointConfiguration dasBackendEndpointConfiguration;

    public ApiClientConfiguration(DasBackendEndpointConfiguration dasBackendEndpointConfiguration) {
        this.dasBackendEndpointConfiguration = dasBackendEndpointConfiguration;
    }

    /**
     * @return HttpClient for Integration-Tests requirements.
     * @see <a href="https://www.baeldung.com/spring-webflux-timeout">configuring timeouts, keep alive, SSL/TSL, ..</a>
     */
    private static HttpClient createHttpClient() {
        return HttpClient.create()
            .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, 20000)
            .responseTimeout(Duration.ofSeconds(25));
    }

    @Bean
    public ApiClient apiClient(ReactiveOAuth2AuthorizedClientManager authorizedClientManager) {
        final JsonMapper objectMapper = ObjectMapperFactory.createMapper(false);
        ServerOAuth2AuthorizedClientExchangeFilterFunction oauth2 = new ServerOAuth2AuthorizedClientExchangeFilterFunction(
            authorizedClientManager);
        oauth2.setDefaultClientRegistrationId(DasBackendEndpointConfiguration.AUTHORIZATION_PROVIDER);
        //TODO use RestClient for synchroneous execution
        final WebClient webClient = ApiClient.buildWebClientBuilder(objectMapper)
            .filter(oauth2)
            .clientConnector(new ReactorClientHttpConnector(createHttpClient()))
            .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(2 * 1024 * 1024))
            .build();
        final ApiClient apiClient = new ApiClient(webClient,
            objectMapper,
            // UTC OffsetDateTime relevant
            DateFormat.getDateTimeInstance());
        apiClient.setBasePath(dasBackendEndpointConfiguration.getEndpointAndPort());
        return apiClient;
    }
}
