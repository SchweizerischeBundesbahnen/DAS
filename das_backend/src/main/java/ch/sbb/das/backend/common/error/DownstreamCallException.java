package ch.sbb.das.backend.common.error;

import lombok.Getter;
import lombok.NonNull;
import org.springframework.http.HttpStatus;

/**
 * A downstream service did not answer (timeout, connection failure) or its Entra ID token could not be fetched, after all retries; answered by
 * {@link GlobalExceptionHandler} with the given status, 502 or 504.
 * <p>
 * An error status of the downstream itself is a {@link ProxyClientException} instead.
 */
@Getter
public class DownstreamCallException extends RuntimeException {

    private final String downstream;
    private final HttpStatus status;
    private final String detail;

    /**
     * @param downstream log name, never exposed to the caller
     * @param detail     of the {@link ch.sbb.das.backend.common.Problem}
     */
    public DownstreamCallException(@NonNull String downstream, @NonNull HttpStatus status, @NonNull String detail, Throwable cause) {
        super(downstream + ": " + detail, cause);
        this.downstream = downstream;
        this.status = status;
        this.detail = detail;
    }
}
