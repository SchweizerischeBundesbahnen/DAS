package ch.sbb.das.backend.restapi.iam.ssoutils;

import static org.apache.commons.lang3.StringUtils.isNotBlank;

import ch.sbb.das.backend.restapi.helper.DeveloperException;
import io.netty.channel.ChannelOption;
import io.netty.handler.timeout.ReadTimeoutHandler;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.function.UnaryOperator;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;
import reactor.netty.transport.ProxyProvider;

/**
 * Spring 5 {@link WebClient} configuration.
 *
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Slf4j
@Getter
@Setter
@Builder
public class WebClientConfiguration {

    // probably never used
    /**
     * The proxy-host
     */
    private String httpProxyHost;
    /**
     * The port of the proxy-host
     */
    private Integer httpProxyPort;
    /**
     * Domains to connect without a proxy
     */
    private String nonProxyHosts;

    private Integer timeoutConnect;
    private Integer timeoutRead;

    /**
     * true: gzip compression is enabled (default is false)
     */
    private boolean compress;

    /**
     * Whether to follow links when retrieving redirect-url.
     * <p>
     * Mostly this feature is used, when redirecting from http to https connections.
     * <p>
     * Default is true, which means requests will follow the redirects.
     */
    @Builder.Default
    private boolean followRedirects = true;

    /**
     * Declare additional exchange-filter-functions if needed
     * <p>
     * Configure your exchange-filters to be adapted for each query by WebClient, for e.g. for authentication or error-handling.
     * <p>
     * see AuthorizationFilter
     */
    private List<ExchangeFilterFunction> exchangeFilterFunctions;

    public WebClient createWebClient() {
        HttpClient httpClient = httpConnectTimeout()
            .andThen(httpReadTimeout())
            .andThen(httpProxy())
            .andThen(followRedirects())
            .apply(HttpClient.create())
            .compress(compress);

        WebClient.Builder webClientBuilder = WebClient.builder()
            .exchangeStrategies(new HttpGetExchangeStrategies(false))
            .clientConnector(new ReactorClientHttpConnector(httpClient));

        // check if additional FilterFunctions should be applied.
        // e.g. RepsonseErrorHandler or AuthorizationFilter are set with this feature
        if ((exchangeFilterFunctions == null) || exchangeFilterFunctions.isEmpty()) {
            log.debug("No custom exchange-filters applied");
        } else {
            webClientBuilder.filters(funcs -> funcs.addAll(exchangeFilterFunctions));
            log.debug("Exchange-filters applied: {}", exchangeFilterFunctions);
        }

        return webClientBuilder.build();
    }

    private UnaryOperator<HttpClient> followRedirects() {
        return client -> client.followRedirect(followRedirects);
    }

    private UnaryOperator<HttpClient> httpConnectTimeout() {
        return client -> client
            .tcpConfiguration(conf -> conf
                .option(
                    ChannelOption.CONNECT_TIMEOUT_MILLIS,
                    ExchangeConstants.restrictTimeout(timeoutConnect, true)));
    }

    private UnaryOperator<HttpClient> httpReadTimeout() {
        return client -> client
            .tcpConfiguration(conf -> conf
                .doOnConnected(connection -> connection
                    .addHandlerLast(new ReadTimeoutHandler(
                        ExchangeConstants.restrictTimeout(timeoutRead, false),
                        TimeUnit.MILLISECONDS))));
    }

    private UnaryOperator<HttpClient> httpProxy() {
        boolean httpProxyHostAssigned = isNotBlank(httpProxyHost);
        if (httpProxyHostAssigned && httpProxyPort == null) {
            throw new DeveloperException("httpProxyPort is required when using httpProxyHost!");
        } else if (!httpProxyHostAssigned) {
            log.trace("no httpProxy configured");
            return client -> client;
        }

        return client -> client
            .tcpConfiguration(conf -> conf
                .proxy(spec -> spec
                    .type(ProxyProvider.Proxy.HTTP)
                    .host(httpProxyHost)
                    .port(httpProxyPort)
                    .nonProxyHosts(nonProxyHosts)));
    }
}
