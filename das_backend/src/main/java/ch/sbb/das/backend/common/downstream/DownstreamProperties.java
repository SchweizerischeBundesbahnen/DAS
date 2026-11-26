package ch.sbb.das.backend.common.downstream;

import java.time.Duration;
import java.util.Map;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Timeouts and retries of the downstream calls. A timeout left empty falls back to {@code spring.http.clients}.
 *
 * @param oauth2Token timeouts of the Entra ID token calls of every OAuth2 client registration
 * @param clients     per downstream service
 */
@ConfigurationProperties(prefix = "downstream")
public record DownstreamProperties(Timeouts oauth2Token, Map<Downstream, Client> clients) {

    Client client(Downstream downstream) {
        final Client client = clients.get(downstream);
        if (client == null) {
            throw new IllegalStateException("No downstream.clients." + downstream.getLogName() + " configured");
        }
        return client;
    }

    public record Timeouts(Duration connectTimeout, Duration readTimeout) {

    }

    /**
     * @param retry of the whole call, including the Entra ID token call made by its OAuth2 interceptor
     */
    public record Client(Duration connectTimeout, Duration readTimeout, Retry retry) {

        Timeouts timeouts() {
            return new Timeouts(connectTimeout, readTimeout);
        }
    }

    /**
     * Connection failures, connect timeouts and the status codes 502, 503 and 504 are always retried, other status codes never.
     *
     * @param maxRetries         retries after the first attempt
     * @param delay              before the first retry
     * @param multiplier         applied to the delay before each further retry
     * @param readTimeoutRetried whether a read timeout is retried; false where a user waits, the downstream may have processed the request anyway
     * @param timeout            no retry starts once the attempts and delays would exceed it; empty for no limit. A running attempt is bounded by its
     *                           connect and read timeouts only.
     */
    public record Retry(long maxRetries, Duration delay, double multiplier, boolean readTimeoutRetried, Duration timeout) {

    }
}
