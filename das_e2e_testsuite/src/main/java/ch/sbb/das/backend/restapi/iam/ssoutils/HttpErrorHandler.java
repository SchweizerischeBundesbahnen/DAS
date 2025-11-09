package ch.sbb.das.backend.restapi.iam.ssoutils;

import ch.sbb.das.backend.restapi.helper.DeveloperException;
import io.netty.channel.ConnectTimeoutException;
import io.netty.handler.timeout.ReadTimeoutException;
import java.net.URI;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.springframework.http.HttpStatus;
import org.springframework.web.reactive.function.client.ClientResponse;
import org.springframework.web.reactive.function.client.WebClientException;
import reactor.core.publisher.Mono;

/**
 * Handles erroneous responses like 400 or 500.
 *
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Slf4j
public abstract class HttpErrorHandler {

    /**
     * Concerns HTTP Requests
     *
     * @return Default Http-Error-Handler.
     */
    public static HttpErrorHandler createDefaultHttpErrorHandler() {
        return new HttpErrorHandler() {
        };
    }

    public static DeveloperException unexpectedError(Throwable cause, URI requestUri) {
        return new DeveloperException(
            "Exception=" + ExceptionUtils.getMessage(cause) +
                (cause == null ? StringUtils.EMPTY : ", cause=" + ExceptionUtils.getRootCauseMessage(cause)) +
                ", URI=" + requestUri,
            cause);
    }

    public RequesterExchangeException onRequestError(Throwable exception, URI requestUri) {
        if (exception.getCause() instanceof ReadTimeoutException) {
            return toRequesterExchangeException(exception, HttpStatus.BAD_GATEWAY, "RestRequester failed due to a read-timeout.", requestUri);
        } else if (exception.getCause() instanceof ConnectTimeoutException) {
            return toRequesterExchangeException(exception, HttpStatus.BAD_GATEWAY, "RestRequester failed due to a connect-timeout.", requestUri);
        } else if (exception instanceof WebClientException) {
            return toRequesterExchangeException(exception, HttpStatus.INTERNAL_SERVER_ERROR, "RestRequester failed.", requestUri);
        }
        throw HttpErrorHandler.unexpectedError(exception, requestUri);
    }

    public Mono<? extends RequesterExchangeException> onResponseError(ClientResponse response, URI requestUri) {
        if (response.statusCode().is4xxClientError()) {
            return handleClientSideException(response, requestUri);
        }
        if (response.statusCode().is5xxServerError()) {
            return handleServerSideException(response, requestUri);
        }
        throw new DeveloperException("Unexpected Error-Response-Code: " + response.statusCode());
    }

    /**
     * Dispatches http-500 errors and returns Mono with server-side exception.
     *
     * @return Mono of server-side exception
     */
    public Mono<? extends RequesterExchangeException> handleServerSideException(ClientResponse response, URI requestUri) {
        log.debug("Handling server-side exception. response={}", response);
        return response
            .bodyToMono(String.class)
            .map(body -> toException(response, body, requestUri));
    }

    /**
     * Dispatches http-400 errors and returns Mono with client-side exception.
     *
     * @return Mono of client-side exception
     */
    public Mono<? extends RequesterExchangeException> handleClientSideException(ClientResponse response, URI requestUri) {
        log.debug("Handling client-side exception. response={}", response);

        return response
            .bodyToMono(String.class)
            .map(body -> toException(response, body, requestUri));
    }

    public RequesterExchangeException toException(ClientResponse response, String responseBody, URI requestUri) {
        return RequesterExchangeException.builder()
            .rootResponse(response)
            .requestedUrl(requestUri.toString())
            .status(response.statusCode())
            .body(responseBody)
            .build();
    }

    public RequesterExchangeException toRequesterExchangeException(Throwable exception, HttpStatus httpStatus, String responseBody, URI requestUri) {
        return RequesterExchangeException.builder()
            .rootResponse(exception.getMessage())
            .requestedUrl(requestUri.toString())
            .status(httpStatus)
            .body(responseBody)
            .cause(exception)
            .build();
    }
}
