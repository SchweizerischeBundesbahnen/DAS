package ch.sbb.das.backend.common.downstream;

import java.io.IOException;
import java.net.SocketTimeoutException;
import java.net.http.HttpConnectTimeoutException;
import java.net.http.HttpTimeoutException;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.hc.client5.http.ConnectTimeoutException;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.security.oauth2.core.OAuth2AuthorizationException;
import org.springframework.web.client.RestClientResponseException;

/**
 * Classifies the failure of a downstream call by its cause chain.
 *
 * @param token  the Entra ID token call failed (Spring Security wraps its failures into an {@link OAuth2AuthorizationException})
 * @param status of the downstream response, only for {@link Kind#RESPONSE_STATUS}
 * @param reason for the log, never contains a response body
 */
record DownstreamFailure(Kind kind, boolean token, HttpStatusCode status, String reason) {

    enum Kind {
        CONNECT_TIMEOUT,
        READ_TIMEOUT,
        /**
         * Refused, reset or closed before the response was read.
         */
        CONNECTION,
        RESPONSE_STATUS,
        OTHER
    }

    static DownstreamFailure of(Throwable failure) {
        boolean token = false;
        for (Throwable cause : ExceptionUtils.getThrowableList(failure)) {
            token |= cause instanceof OAuth2AuthorizationException;
            // Apache HttpClient or JDK HttpClient
            if (cause instanceof ConnectTimeoutException || cause instanceof HttpConnectTimeoutException) {
                return new DownstreamFailure(Kind.CONNECT_TIMEOUT, token, null, describe(cause));
            }
            if (cause instanceof HttpTimeoutException || cause instanceof SocketTimeoutException) {
                return new DownstreamFailure(Kind.READ_TIMEOUT, token, null, describe(cause));
            }
            if (cause instanceof RestClientResponseException responseException) {
                // its message contains the response body
                return new DownstreamFailure(Kind.RESPONSE_STATUS, token, responseException.getStatusCode(), "status " + responseException.getStatusCode().value());
            }
            if (cause instanceof IOException) {
                return new DownstreamFailure(Kind.CONNECTION, token, null, describe(cause));
            }
        }
        if (failure instanceof OAuth2AuthorizationException authorizationException) {
            return new DownstreamFailure(Kind.OTHER, true, null, "OAuth2 error " + authorizationException.getError().getErrorCode());
        }
        return new DownstreamFailure(Kind.OTHER, token, null, failure.getClass().getSimpleName());
    }

    boolean isRetryable(DownstreamProperties.Retry retry) {
        return switch (kind) {
            case CONNECT_TIMEOUT, CONNECTION -> true;
            case READ_TIMEOUT -> retry.readTimeoutRetried();
            case RESPONSE_STATUS -> status.isSameCodeAs(HttpStatus.BAD_GATEWAY) || status.isSameCodeAs(HttpStatus.SERVICE_UNAVAILABLE)
                || status.isSameCodeAs(HttpStatus.GATEWAY_TIMEOUT);
            case OTHER -> false;
        };
    }

    String logName(Downstream downstream) {
        return token ? downstream.getTokenLogName() : downstream.getLogName();
    }

    private static String describe(Throwable cause) {
        return cause.getClass().getSimpleName() + ": " + cause.getMessage();
    }
}
