package ch.sbb.das.backend.restapi.configuration;

import static ch.sbb.das.backend.restapi.configuration.SSOConfiguration.AUTHORIZATION_PROVIDER_AZURE_AD;

import ch.sbb.backend.restclient.v1.ApiClient;
import ch.sbb.das.backend.restapi.helper.ObjectMapperFactory;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import io.netty.channel.ChannelOption;
import java.text.DateFormat;
import java.time.Duration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.security.oauth2.client.ReactiveOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.reactive.function.client.ServerOAuth2AuthorizedClientExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;

@Configuration
public class ApiClientConfiguration {

    private final DasBackendEndpointConfiguration dasBackendEndpointConfiguration;

    @Autowired
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
        final ObjectMapper objectMapper = objectMapper(false);
        ServerOAuth2AuthorizedClientExchangeFilterFunction oauth2 = new ServerOAuth2AuthorizedClientExchangeFilterFunction(
            authorizedClientManager);
        oauth2.setDefaultClientRegistrationId(AUTHORIZATION_PROVIDER_AZURE_AD);
        final WebClient webClient = ApiClient.buildWebClientBuilder(objectMapper)
            .filter(oauth2)
            .clientConnector(new ReactorClientHttpConnector(createHttpClient()))
            // ? .exchangeStrategies(createExchangeStrategies())
            .codecs(configurer -> configurer.defaultCodecs().maxInMemorySize(2 * 1024 * 1024))
            .build();
        final ApiClient apiClient = new ApiClient(webClient,
            objectMapper,
            // UTC OffsetDateTime relevant
            DateFormat.getDateTimeInstance());
        apiClient.setBasePath(dasBackendEndpointConfiguration.getEndpoint());
        // do not transfer null properties in (POST) requests
        apiClient.getObjectMapper().setSerializationInclusion(JsonInclude.Include.NON_NULL);
        return apiClient;
    }

    private ObjectMapper objectMapper(boolean strict) {
        final ObjectMapper mapper = ObjectMapperFactory.createMapper(strict);
        mapper.configure(SerializationFeature.WRITE_DATES_WITH_ZONE_ID, false);
        mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
        mapper.configure(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE, false);
        mapper.registerModule(new JavaTimeModule());
        mapper.configure(SerializationFeature.FAIL_ON_SELF_REFERENCES, strict);
        mapper.configure(SerializationFeature.FAIL_ON_UNWRAPPED_TYPE_IDENTIFIERS, strict);
        mapper.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, strict);
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, strict);
        mapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, strict);
        return mapper;
    }
}
