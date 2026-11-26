package ch.sbb.das.backend.common.downstream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.das.backend.common.error.DownstreamCallException;
import java.net.ConnectException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.client.ResourceAccessException;

class DownstreamCallHandlerTest {

    private final AtomicInteger attempts = new AtomicInteger();

    @Test
    void call_retryTimeoutExceededByNextDelay_stopsRetrying() {
        // Given
        final DownstreamCallHandler handler = handler(new DownstreamProperties.Retry(2, Duration.ofMillis(200), 2, false, Duration.ofMillis(300)));

        // When, Then
        assertThatThrownBy(() -> handler.call(Downstream.GEMS, "subscribe", this::refuseConnection))
            .isInstanceOfSatisfying(DownstreamCallException.class, e -> assertThat(e.getStatus()).isEqualTo(HttpStatus.BAD_GATEWAY));
        assertThat(attempts).hasValue(2);
    }

    @Test
    void call_noRetryTimeout_usesAllRetries() {
        // Given
        final DownstreamCallHandler handler = handler(new DownstreamProperties.Retry(2, Duration.ofMillis(10), 2, false, null));

        // When, Then
        assertThatThrownBy(() -> handler.call(Downstream.GEMS, "subscribe", this::refuseConnection))
            .isInstanceOf(DownstreamCallException.class);
        assertThat(attempts).hasValue(3);
    }

    private String refuseConnection() {
        attempts.incrementAndGet();
        throw new ResourceAccessException("I/O error", new ConnectException("Connection refused"));
    }

    private static DownstreamCallHandler handler(DownstreamProperties.Retry retry) {
        return new DownstreamCallHandler(new DownstreamProperties(null, Map.of(Downstream.GEMS, new DownstreamProperties.Client(null, null, retry))));
    }
}
