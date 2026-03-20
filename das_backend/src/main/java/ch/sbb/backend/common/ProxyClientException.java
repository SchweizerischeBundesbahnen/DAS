package ch.sbb.backend.common;

import lombok.Getter;
import org.springframework.http.HttpStatusCode;

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
