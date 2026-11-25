package ch.sbb.das.backend.common.downstream;

import java.time.Duration;
import org.apache.hc.client5.http.impl.classic.HttpClientBuilder;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.http.client.ClientHttpRequestFactoryBuilder;
import org.springframework.boot.http.client.HttpComponentsClientHttpRequestFactoryBuilder;
import org.springframework.boot.http.client.HttpClientSettings;
import org.springframework.boot.restclient.RestClientCustomizer;
import org.springframework.http.client.ClientHttpRequestFactory;
import org.springframework.http.converter.FormHttpMessageConverter;
import org.springframework.security.oauth2.client.http.OAuth2ErrorResponseErrorHandler;
import org.springframework.security.oauth2.core.http.converter.OAuth2AccessTokenResponseHttpMessageConverter;
import org.springframework.web.client.RestClient;

/**
 * Creates the {@link RestClient}s to downstream services with the timeouts of {@code downstream.*}, falling back to {@code spring.http.clients}.
 */
public class DownstreamRestClients {

    private final DownstreamProperties properties;
    private final ClientHttpRequestFactoryBuilder<?> requestFactoryBuilder;
    private final HttpClientSettings clientSettings;
    private final ObjectProvider<RestClientCustomizer> customizers;

    public DownstreamRestClients(DownstreamProperties properties, ObjectProvider<ClientHttpRequestFactoryBuilder<?>> requestFactoryBuilder,
        ObjectProvider<HttpClientSettings> clientSettings, ObjectProvider<RestClientCustomizer> customizers) {
        this.properties = properties;
        this.requestFactoryBuilder = withoutAutomaticRetries(requestFactoryBuilder.getIfAvailable(ClientHttpRequestFactoryBuilder::detect));
        this.clientSettings = clientSettings.getIfAvailable(HttpClientSettings::defaults);
        this.customizers = customizers;
    }

    /**
     * Like the {@link RestClient.Builder} of Spring Boot (message converters, observation and test customizers like {@code MockRestServiceServer} applied), but
     * with the timeouts of the downstream.
     */
    public RestClient.Builder builder(Downstream downstream) {
        final RestClient.Builder builder = RestClient.builder().requestFactory(requestFactory(properties.client(downstream).timeouts()));
        customizers.orderedStream().forEach(customizer -> customizer.customize(builder));
        return builder;
    }

    /**
     * For the Entra ID token calls, configured like the default of {@link org.springframework.security.oauth2.client.endpoint.RestClientClientCredentialsTokenResponseClient}
     * but with the timeouts of {@code downstream.oauth2-token}.
     */
    public RestClient oauth2TokenRestClient() {
        return RestClient.builder()
            .requestFactory(requestFactory(properties.oauth2Token()))
            .configureMessageConverters(converters -> converters
                .addCustomConverter(new FormHttpMessageConverter())
                .addCustomConverter(new OAuth2AccessTokenResponseHttpMessageConverter()))
            .defaultStatusHandler(new OAuth2ErrorResponseErrorHandler())
            .build();
    }

    private ClientHttpRequestFactory requestFactory(DownstreamProperties.Timeouts timeouts) {
        return requestFactoryBuilder.build(clientSettings.withTimeouts(
            orElse(timeouts.connectTimeout(), clientSettings.connectTimeout()),
            orElse(timeouts.readTimeout(), clientSettings.readTimeout())));
    }

    /**
     * Spring Cloud Vault puts Apache HttpClient on the classpath, so Spring Boot uses it. Apache HttpClient repeats a 503 and an idempotent request after an
     * I/O error once by itself, without logging. {@link DownstreamCalls} retries instead.
     */
    private static ClientHttpRequestFactoryBuilder<?> withoutAutomaticRetries(ClientHttpRequestFactoryBuilder<?> requestFactoryBuilder) {
        if (requestFactoryBuilder instanceof HttpComponentsClientHttpRequestFactoryBuilder httpComponents) {
            return httpComponents.withHttpClientCustomizer(HttpClientBuilder::disableAutomaticRetries);
        }
        return requestFactoryBuilder;
    }

    private static Duration orElse(Duration duration, Duration fallback) {
        return duration == null ? fallback : duration;
    }
}
