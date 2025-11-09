package ch.sbb.das.backend.restapi.iam.ssoutils;

import java.net.URI;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.jetbrains.annotations.NotNull;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.ClientResponse;

/**
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
public interface RestRequestObserver {

    /**
     * observes an HTTP call with this callback method
     *
     * @param responseEntity the responded entity in success case, null otherwise
     * @param responseClient the raw response with status code, etc.
     * @param requestInfo some information about the HTTP request
     */
    void observeResponse(ResponseEntity<String> responseEntity, @NonNull ClientResponse responseClient, @NonNull RestRequestInfo requestInfo);

    @Component
    @Slf4j
    class RestRequestResponseBodyLoggingObserver implements RestRequestObserver {

        private static final int MONITORING_BODY_MAXLENGTH = 40;

        @Override
        public void observeResponse(ResponseEntity<String> responseEntity, @NotNull ClientResponse responseClient, @NotNull RestRequestInfo requestInfo) {
            HttpMethod requestMethod = requestInfo.getRequestMethod();
            URI requestUri = requestInfo.getRequestUri();
            // more or less similar to old RestRequester.logRequest()
            if (responseEntity == null) {
                log.debug("HTTP {} {} responded code={} without body",
                    requestMethod, requestUri, (responseClient != null) ? responseClient.statusCode() : null);
                return;
            }
            HttpStatusCode statusCode = responseEntity.getStatusCode();
            String responseBody = responseEntity.getBody();
            if (statusCode.is2xxSuccessful()) {
                if (log.isTraceEnabled()) {
                    log.trace("HTTP {} {} responded code={} body={}",
                        requestMethod, requestUri, statusCode, responseBody);
                } else if (log.isDebugEnabled()) {
                    log.debug("HTTP {} {} responded code={} body={}",
                        requestMethod, requestUri, statusCode, StringUtils.abbreviate(responseBody, MONITORING_BODY_MAXLENGTH));
                }
            } else {
                if (log.isDebugEnabled()) {
                    log.debug("HTTP {} {} responded code={} body={}",
                        requestMethod, requestUri, statusCode, responseBody);
                }
            }
        }
    }
}
