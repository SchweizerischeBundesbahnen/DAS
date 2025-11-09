package ch.sbb.das.backend.restapi.iam.ssoutils;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.net.URI;
import lombok.Getter;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.client.ClientResponse;
import org.springframework.web.reactive.function.client.WebClient;

/**
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Slf4j
public abstract class RestRequester {

    @Getter
    private final ObjectMapper mapper;
    private final MappingErrorHandler mappingErrorHandler;
    private final RequestContextHolder requestContextHolder;

    /**
     * Create RestRequester Tool-instance
     *
     * @param mapper Json to POJO
     * @param customMappingErrorHandler custom mapping-error handling.
     * @see MappingErrorHandler#createDefaultMappingErrorHandler()
     */
    public RestRequester(
        @NonNull ObjectMapper mapper,
        @NonNull MappingErrorHandler customMappingErrorHandler,
        RequestContextHolder requestContextHolder) {

        this.mapper = mapper;
        this.mappingErrorHandler = customMappingErrorHandler;
        this.requestContextHolder = requestContextHolder;
    }

    /**
     * No payload assumed, therefore no Content-Type will be set.
     *
     * @return Header for HTTP GET requests
     * @see <a href="https://tools.ietf.org/html/rfc7231#section-3.1.1.5">RFC 7231</a>
     * @see <a href="https://en.wikipedia.org/wiki/List_of_HTTP_header_fields>HTTP header fields</a>
     * @see <a href="https://confluence.sbb.ch/display/MON/Instana+-+HTTP+Header+Konfiguration">INSTANA monitoring Headers</a>
     * @see <a href="https://stackoverflow.com/questions/5661596/do-i-need-a-content-type-header-for-http-get-requests">Content-Type for HTTP GET requests</a>
     * @see <a href="https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Encoding">Accept-Encoding</a>
     */
    public HttpHeaders createHeaders() {
        HttpHeaders headers = new HttpHeaders();
        if (requestContextHolder != null && requestContextHolder.getRequestContext() != null) {
            headers.putAll(requestContextHolder.getRequestContext().getContent());
        }
        return headers;
    }

    /**
     * All RestRequester must return a WebClient due to async-calls with the WebClient.
     *
     * @return WebClient configured WebClient-Instance
     */
    public abstract WebClient getWebClient();

    /**
     * Perform POST request with default JSON header.
     * <p>
     * UTF-8 encoding is expected for each relevant query-parameter inside the builder
     *
     * @param query POST Request (final URI)
     * @param bodyBuilder HTTP body
     * @return original header and body of HTTP Response.
     * @throws RequesterExchangeException REST-Client exception
     * @see HttpErrorHandler#onResponseError(ClientResponse, URI)
     */
    public abstract ResponseEntity<String> requestPost(@NonNull URI query, @NonNull MultiValueMap<String, String> bodyBuilder)
        throws RequesterExchangeException;

    public <T> T requestAndMap(@NonNull Class<T> clazz, @NonNull URI uri, @NonNull MultiValueMap<String, String> bodyBuilder)
        throws RequesterExchangeException, RequesterMappingException {
        return map(clazz, requestPost(uri, bodyBuilder));
    }

    private <T> T map(@NonNull Class<T> clazz, @NonNull ResponseEntity<String> entity) throws RequesterMappingException {
        if (HttpStatus.OK.isSameCodeAs(entity.getStatusCode())) {
            mappingErrorHandler.handleEmptyResponse(entity.getBody());
            return mapClass(entity, clazz);
        } else if (HttpStatus.NOT_FOUND.isSameCodeAs(entity.getStatusCode())) {
            log.debug("HTTP={} handled -> defaults to null", entity.getStatusCode().value());
            return null;
        } else {
            throw mappingErrorHandler.toRequesterMappingException(entity.getStatusCode() + " Developer bug: Unexpected REST-Service response: " + entity.getBody());
        }
    }

    private <T> T mapClass(ResponseEntity<String> entity, Class<T> clazz) throws RequesterMappingException {
        try {
            return mapper.readValue(entity.getBody(), clazz);
        } catch (JsonParseException ex) {
            throw mappingErrorHandler.handle(ex, clazz, entity.getBody());
        } catch (JsonMappingException ex) {
            throw mappingErrorHandler.handle(ex, clazz, entity.getBody());
        } catch (IOException ex) {
            throw mappingErrorHandler.handle(ex, clazz);
        }
    }
}