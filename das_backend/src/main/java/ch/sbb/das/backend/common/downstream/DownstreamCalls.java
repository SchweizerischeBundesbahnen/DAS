package ch.sbb.das.backend.common.downstream;

import ch.sbb.das.backend.common.LogKeys;
import ch.sbb.das.backend.common.error.DownstreamCallException;
import java.util.EnumMap;
import java.util.Map;
import java.util.function.Supplier;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.retry.RetryException;
import org.springframework.core.retry.RetryListener;
import org.springframework.core.retry.RetryPolicy;
import org.springframework.core.retry.RetryState;
import org.springframework.core.retry.RetryTemplate;
import org.springframework.core.retry.Retryable;
import org.springframework.http.HttpStatus;

/**
 * Runs a downstream call with the retry policy of its {@link Downstream} ({@code downstream.clients.*.retry}):
 * <ul>
 *     <li>every failed attempt is logged once at WARN, without stack trace</li>
 *     <li>after the last attempt, a timeout becomes a {@link DownstreamCallException} with 504, a connection failure or a failed Entra ID token call one with
 *     502</li>
 *     <li>any other failure, like an error status of the downstream, is thrown as is</li>
 * </ul>
 * Uses the {@link RetryTemplate} of Spring Framework instead of {@link org.springframework.resilience.annotation.Retryable}: only its {@link RetryListener}
 * knows the attempt number.
 */
@Slf4j
public class DownstreamCalls {

    static final String DETAIL_TIMEOUT = "Downstream service did not respond in time.";
    static final String DETAIL_CONNECTION = "Downstream service could not be reached.";
    static final String DETAIL_TOKEN = "Downstream service could not be authorized.";

    private final Map<Downstream, RetryTemplate> retryTemplates = new EnumMap<>(Downstream.class);

    public DownstreamCalls(DownstreamProperties properties) {
        properties.clients().forEach((downstream, client) -> retryTemplates.put(downstream, createRetryTemplate(client.retry())));
    }

    /**
     * @param operation logged with each failed attempt, like {@code subscribe}
     * @param call      the whole HTTP exchange, repeated on each attempt
     */
    public <T> T call(Downstream downstream, String operation, Supplier<T> call) {
        final RetryTemplate retryTemplate = retryTemplates.get(downstream);
        if (retryTemplate == null) {
            throw new IllegalStateException("No downstream.clients." + downstream.getLogName() + " configured");
        }
        try {
            return retryTemplate.execute(new Attempt<>(downstream, operation, call));
        } catch (RetryException e) {
            throw translate(downstream, e.getCause());
        }
    }

    private static RuntimeException translate(Downstream downstream, Throwable failure) {
        if (failure instanceof Error error) {
            throw error;
        }
        final DownstreamFailure classified = DownstreamFailure.of(failure);
        final String logName = classified.logName(downstream);
        return switch (classified.kind()) {
            case CONNECT_TIMEOUT, READ_TIMEOUT -> new DownstreamCallException(logName, HttpStatus.GATEWAY_TIMEOUT, DETAIL_TIMEOUT, failure);
            case CONNECTION -> new DownstreamCallException(logName, HttpStatus.BAD_GATEWAY, DETAIL_CONNECTION, failure);
            case RESPONSE_STATUS, OTHER -> classified.token()
                ? new DownstreamCallException(logName, HttpStatus.BAD_GATEWAY, DETAIL_TOKEN, failure)
                : (RuntimeException) failure;
        };
    }

    private static RetryTemplate createRetryTemplate(DownstreamProperties.Retry retry) {
        final RetryTemplate retryTemplate = new RetryTemplate(RetryPolicy.builder()
            .maxRetries(retry.maxRetries())
            .delay(retry.delay())
            .multiplier(retry.multiplier())
            .predicate(failure -> DownstreamFailure.of(failure).isRetryable(retry))
            .build());
        retryTemplate.setRetryListener(new AttemptLogger());
        return retryTemplate;
    }

    /**
     * One execution of the call, measuring its duration for the log.
     */
    private static final class Attempt<T> implements Retryable<T> {

        private final Downstream downstream;
        private final String operation;
        private final Supplier<T> call;
        private long durationMs;

        private Attempt(Downstream downstream, String operation, Supplier<T> call) {
            this.downstream = downstream;
            this.operation = operation;
            this.call = call;
        }

        @Override
        public T execute() {
            final long start = System.nanoTime();
            try {
                return call.get();
            } finally {
                durationMs = (System.nanoTime() - start) / 1_000_000;
            }
        }

        @Override
        public String getName() {
            return downstream.getLogName() + " " + operation;
        }
    }

    private static final class AttemptLogger implements RetryListener {

        @Override
        public void onRetryableExecution(RetryPolicy retryPolicy, Retryable<?> retryable, RetryState retryState) {
            if (retryState.isSuccessful() || !(retryable instanceof Attempt<?> attempt)) {
                return;
            }
            final DownstreamFailure failure = DownstreamFailure.of(retryState.getLastException());
            log.atWarn()
                .addKeyValue(LogKeys.DOWNSTREAM, failure.logName(attempt.downstream))
                .addKeyValue(LogKeys.OPERATION, attempt.operation)
                .addKeyValue(LogKeys.ATTEMPT, retryState.getRetryCount() + 1)
                .addKeyValue(LogKeys.DURATION_MS, attempt.durationMs)
                .addKeyValue(LogKeys.REASON, failure.reason())
                .log("Downstream call attempt failed");
        }
    }
}
