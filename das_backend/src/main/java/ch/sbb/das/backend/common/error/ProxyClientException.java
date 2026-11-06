package ch.sbb.das.backend.common.error;

import lombok.Getter;
import org.springframework.http.HttpStatusCode;

/**
 * A downstream service called by the backend failed; answered by {@link GlobalExceptionHandler} with 502.
 */
@Getter
public class ProxyClientException extends RuntimeException {

    private final HttpStatusCode statusCode;
    private final String proxyErrorMessage;

    public ProxyClientException(HttpStatusCode statusCode, String proxyErrorMessage) {
        super("Proxy service error: " + proxyErrorMessage);
        this.statusCode = statusCode;
        this.proxyErrorMessage = proxyErrorMessage;
    }
}
