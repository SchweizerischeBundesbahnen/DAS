package ch.sbb.das.backend.restapi.iam.ssoutils;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.MDC;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.ClientResponse;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClient.ResponseSpec;
import org.springframework.web.reactive.function.client.WebClientException;
import reactor.core.publisher.Mono;

/**
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Slf4j
public class WebClientRestRequester extends RestRequester {

    private final WebClient webClient;
    private final HttpErrorHandler httpErrorHandler;
    private final List<RestRequestObserver> restRequestObservers;

    public WebClientRestRequester(@NonNull ObjectMapper mapper, @NonNull WebClient webClient) {
        this(mapper, webClient, HttpErrorHandler.createDefaultHttpErrorHandler(), MappingErrorHandler.createDefaultMappingErrorHandler());
    }

    public WebClientRestRequester(
        @NonNull ObjectMapper mapper,
        @NonNull WebClient webClient,
        @NonNull HttpErrorHandler httpErrorHandler,
        @NonNull MappingErrorHandler mappingErrorHandler) {

        this(mapper, webClient, httpErrorHandler, mappingErrorHandler, null);
    }

    /**
     * Create RestRequester instance.
     * <p>
     * Default parameterized WebClient.
     *
     * @param mapper Json to POJO
     * @param webClient configuration for Spring 5 WebClient
     * @param requestContextHolder Holds request-bounded information (e.g. the requestId)
     * @see WebClientConfiguration#createWebClient()
     */
    public WebClientRestRequester(
        @NonNull ObjectMapper mapper,
        @NonNull WebClient webClient,
        @NonNull HttpErrorHandler httpErrorHandler,
        @NonNull MappingErrorHandler mappingErrorHandler,
        RequestContextHolder requestContextHolder) {

        this(mapper, webClient, httpErrorHandler, mappingErrorHandler, requestContextHolder, null);
    }

    public WebClientRestRequester(
        @NonNull ObjectMapper mapper,
        @NonNull WebClient webClient,
        @NonNull HttpErrorHandler httpErrorHandler,
        @NonNull MappingErrorHandler mappingErrorHandler,
        RequestContextHolder requestContextHolder,
        List<RestRequestObserver> restRequestObservers) {

        super(mapper, mappingErrorHandler, requestContextHolder);
        this.webClient = webClient;
        this.httpErrorHandler = httpErrorHandler;
        this.restRequestObservers = (restRequestObservers != null) ? restRequestObservers : List.of(
            new RestRequestObserver.RestRequestResponseBodyLoggingObserver());
        log.debug("WebClientRestRequester was created. Http-Handler={}, Mapping-Handler={}", httpErrorHandler.getClass(), mappingErrorHandler.getClass());
    }

    @Override
    public WebClient getWebClient() {
        return webClient;
    }

    /**
     * WebClient is forced to behave synchronously.
     *
     * @param uri POST Request (final URI)
     * @see WebClientConfiguration#createWebClient() to register ResponseErrorHandler (in ResponseErrorFilter)
     */
    @Override
    public ResponseEntity<String> requestPost(@NonNull URI uri, @NonNull MultiValueMap<String, String> bodyParameters) throws RequesterExchangeException {
        log.debug("HTTP POST(blocked) {}\nBody: {}", uri, bodyParameters);

        HttpHeaders headers = createHeaders();
        headers.put(HttpHeaders.CONTENT_TYPE, List.of(MediaType.APPLICATION_FORM_URLENCODED_VALUE));

        ResponseSpec responseSpec = webClient.post()
            .uri(uri)
            .headers(httpHeaders -> httpHeaders.addAll(headers))
            .body(BodyInserters.fromFormData(bodyParameters))
            .retrieve();
        return requestAndHandle(responseSpec, new RestRequestInfo(HttpMethod.POST, uri, bodyParameters));
    }

    /**
     * Defines error-handling and executes request (block) based on ResponseSpec.
     *
     * @param spec ResponseSpec
     * @return Response as ResponseEntity of type String
     */
    private ResponseEntity<String> requestAndHandle(ResponseSpec spec, RestRequestInfo requestInfo) throws RequesterExchangeException {
        AtomicReference<ResponseEntity<String>> responseEntity = new AtomicReference<>();
        Map<String, String> mdcContextMap = MDC.getCopyOfContextMap();
        // responseClient tends to have more info or more often than responseEntity
        AtomicReference<ClientResponse> responseClient = new AtomicReference<>();
        try {
            responseEntity.set(spec
                .onStatus(HttpStatusCode::is2xxSuccessful, doWithContextInfo(response -> {
                    responseClient.set(response);
                    return Mono.empty(); // suppress the treatment of a status code as an error and process it as a normal response
                }, mdcContextMap))
                .onStatus(Predicate.not(HttpStatusCode::is2xxSuccessful), doWithContextInfo(response -> {
                    responseClient.set(response);
                    return httpErrorHandler.onResponseError(response, requestInfo.getRequestUri());
                }, mdcContextMap))
                .toEntity(String.class)
                .doOnError(RequesterExchangeException.class, runWithContextInfo(requesterExchangeEx -> {
                    responseEntity.set(new ResponseEntity<>(requesterExchangeEx.getBody(), requesterExchangeEx.getStatus()));
                    // actually very same as re-throwing requesterExchangeEx ... 
                    throw handleAndRethrow(requesterExchangeEx, requestInfo.getRequestUri());
                    // The exception handling could very probably be simplified a lot. Eventually rewrite completely.
                }, mdcContextMap))
                .doOnError(WebClientException.class, runWithContextInfo(genericWebClientEx -> {
                    throw httpErrorHandler.onRequestError(genericWebClientEx, requestInfo.getRequestUri());
                }, mdcContextMap))
                .doOnError(InterruptedException.class, runWithContextInfo(genericWebClientEx -> {
                    throw httpErrorHandler.onRequestError(genericWebClientEx, requestInfo.getRequestUri());
                }, mdcContextMap))
                .block());
        } finally {
            observeResponse(responseEntity.get(), responseClient.get(), requestInfo);
        }
        return responseEntity.get();
    }

    private <T> Consumer<T> runWithContextInfo(Consumer<T> function, Map<String, String> mdcContextMap) {
        return (input) -> {
            MDC.setContextMap(mdcContextMap);
            try {
                function.accept(input);
            } finally {
                MDC.clear();
            }
        };
    }

    private <T, R> Function<T, R> doWithContextInfo(Function<T, R> function, Map<String, String> mdcContextMap) {
        return (input) -> {
            MDC.setContextMap(mdcContextMap);
            try {
                return function.apply(input);
            } finally {
                MDC.clear();
            }
        };
    }

    /**
     * Due to the circumstances, that we block requests, all errors happening inside the reactive chain, will be wrapped inside an Exception. ReactiveException from the reactor project on Mono::block
     * or Flux::block. To assure that we can control the exceptions we check them first here.
     *
     * @param ex Exception thrown by Mono#block or Flux#block (e.g.: Exceptions.ReactiveException)
     * @return Throwable complying with Exception-Handling such as {@see {@link RequesterExchangeException}}
     */
    private RequesterExchangeException handleAndRethrow(Exception ex, URI requestUri) {
        // why not subclasses? -> because it's guaranteed that here the exception is a RequesterExchangeException. If not, it's a DeveloperException
        if (ex.getClass() == RequesterExchangeException.class) {
            return (RequesterExchangeException) ex;
        }
        throw HttpErrorHandler.unexpectedError(ex, requestUri);
    }

    protected void observeResponse(ResponseEntity<String> responseEntity, ClientResponse responseClient, RestRequestInfo requestInfo) {
        for (RestRequestObserver restRequestObserver : restRequestObservers) {
            try {
                restRequestObserver.observeResponse(responseEntity, responseClient, requestInfo);
            } catch (RuntimeException e) {
                log.warn("error when observing response, will ignore it and go on", e);
            }
        }
    }
}
