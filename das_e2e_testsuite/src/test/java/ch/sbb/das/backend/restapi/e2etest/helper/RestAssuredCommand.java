/*
 * Copyright (C) Schweizerische Bundesbahnen SBB, 2018.
 */

package ch.sbb.das.backend.restapi.e2etest.helper;

import static org.assertj.core.api.Assertions.assertThat;

import _todo_.Problem;
import ch.sbb.backend.restclient.v1.ApiClient;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpoint;
import ch.sbb.das.backend.restapi.helper.ObjectMapperFactory;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.RestAssured;
import io.restassured.config.HttpClientConfig;
import io.restassured.config.ObjectMapperConfig;
import io.restassured.parsing.Parser;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpStatus;
import org.apache.http.client.params.ClientPNames;
import org.apache.http.client.params.CookiePolicy;
import org.apache.http.params.CoreConnectionPNames;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientException;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

/**
 * Encapsulate a Test-request as a command to RestAssured.io to invoke against a real backend instance.
 *
 * @see <a href="http://rest-assured.io/">REST assured</a>
 * @see <a href="https://www.javatpoint.com/command-pattern">Command-Pattern</a>
 */
@Slf4j
public abstract class RestAssuredCommand {

    protected static final String MEDIA_TYPE_APPLICATION_JSON_PROBLEM = MediaType.APPLICATION_PROBLEM_JSON_VALUE;
    protected static final String NO_HITS = "NO_HITS";
    /**
     * Serialize Body
     */
    protected static final ObjectMapper MAPPER = ObjectMapperFactory.createMapper(true);
    private static final int WEBCLIENT_TIMEOUT = 30 * 1000;
    private static final String ENVIRONMENT_URL = "envUrl";
    @RegisterExtension
    private final TestContextGetterExtension testContextGetter = new TestContextGetterExtension();
    private DasBackendEndpoint configuration;
    private String url;
    private String token = null;

    protected static String toBodyString(Response response) {
        // DO NOT use .toString() here -> System.out.println() implementation will force System.exit() while Jenkins test job execution!!!
        if ((response == null) || (response.getBody() == null)) {
            log.error("response::body is null: {}", response);
            return null;
        }
        return response.getBody().asString();
    }

    /**
     * @param responseAsync
     * @param <T>
     * @return assumed response with T as body
     * @see #getResponseBodyOrFail(Mono)
     */
    protected static <T> ResponseEntity<T> blockBody(Mono<ResponseEntity<T>> responseAsync, String acceptLanguage, String requestId, String instance) {
        assertThat(responseAsync).as("Mono-object").isNotNull();

        ResponseEntity<T> responseEntity = null;
        try {
            responseEntity = responseAsync.block();
        } catch (WebClientResponseException ex) {
            if (ex.getStatusCode() == HttpStatusCode.valueOf(HttpStatus.SC_TOO_MANY_REQUESTS)) {
                // no backend generated headers!
                // Rate Limit error, meaning the API tells the caller it has sent too many request.
                // This can usually be solved by waiting a bit, and you might even have a "Retry-after" header in the response telling you how long you have to wait.
                if (ex.getHeaders().containsKey("Retry-After")) {
                    log.info("Retry-After={}", ex.getHeaders().getFirst("Retry-After"));
                }
                try {
                    // hope to break the immediate flow of tests for a moment -> follow-up tests might have a better chance
                    // TODO better add retry to ApiClient's WebClient, see https://www.couchbase.com/blog/spring-webclient-429-ratelimit-errors/
                    Thread.sleep(30000L);
                } catch (InterruptedException e) {
                    log.warn("Retry-After sleep workaround failed", ex);
                }
                Assertions.fail(ex.getStatusCode() + " " + ex.getResponseBodyAsString());
            }

            AssertionsResponse.assertClientException(ex, requestId, null);
            if (ex.getStatusCode() == HttpStatusCode.valueOf(HttpStatus.SC_NOT_FOUND)) {
                // must not be a fault always!
                Assertions.fail("NO_HITS", ex);
            }

            Assertions.fail("Request-block", ex);
        } catch (WebClientException ex) {
            Assertions.fail("Request-block", ex);
        }

        assertThat(responseEntity).isNotNull();
        //TODO assertThat(responseEntity.getHeaders()).containsKey(MonitoringConstants.HEADER_REQUEST_ID);
        assertThat(responseEntity.getStatusCode().value()).isEqualTo(HttpStatus.SC_OK);
        // see assertOK();
        AssertionsResponse.assertApplicationJson(responseEntity.getHeaders().getFirst(HttpHeaders.CONTENT_TYPE));
        // see assertCaseInsensitiveHeaders(Response response) {
        assertThat(responseEntity.getHeaders().getFirst(MonitoringConstants.HEADER_REQUEST_ID.toLowerCase()))
            .isEqualTo(responseEntity.getHeaders().getFirst(MonitoringConstants.HEADER_REQUEST_ID));
        assertThat(responseEntity.getBody()).as("Backend must always return a JsonResponse object").isNotNull();

        return responseEntity;
    }

    // for Error/Problem where an application offers a translation
    protected static boolean isNotFound(@NonNull Response response, String acceptLanguage, @NonNull String requestId, String instance) {
        assertCaseInsensitiveHeaders(response);
        return AssertionsResponse
            .isNotFound(response.getStatusCode(), toBodyString(response), response.getHeader(HttpHeaders.CONTENT_TYPE), acceptLanguage, response.getHeader(HttpHeaders.CONTENT_LANGUAGE),
                response.getHeader(MonitoringConstants.HEADER_REQUEST_ID), requestId);
    }

    protected static void assertOK(Response response, String acceptLanguage, @NonNull String requestId) {
        assertOK(response, acceptLanguage, requestId, null);
    }

    /**
     * Check if response is OK to deserialize body element.
     *
     * @param response to check
     * @param acceptLanguage part of header
     * @param requestId part of header
     * @param instance service url
     */
    protected static void assertOK(@NonNull Response response, String acceptLanguage, @NonNull String requestId, String instance) {
        assertCaseInsensitiveHeaders(response);
        final String bodyString = toBodyString(response);
        log.debug("Response: {} {}", response.getStatusCode(), bodyString);

        if (isNotFound(response, acceptLanguage, requestId, instance)) {
            Assertions.fail(NO_HITS);
        } else if (HttpStatus.SC_UNPROCESSABLE_ENTITY == response.getStatusCode()) {
            // should not happen with v2 or v3 anymore
            assertThat(response.header(HttpHeaders.CONTENT_TYPE)).isEqualTo(MEDIA_TYPE_APPLICATION_JSON_PROBLEM);
            AssertionsResponse.assertLanguage(ServiceDoc.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT, response.getHeader(HttpHeaders.CONTENT_LANGUAGE));
            Assertions.fail("422 " + (response.getBody() == null ? "<NO Body>" : bodyString));
        } else if (HttpStatus.SC_SERVICE_UNAVAILABLE == response.getStatusCode()) {
            // most probably no Backend generated 'Problem'
            log.warn("{} {} for {}", response.getStatusCode(), response.getStatusLine(), bodyString);
            Assertions.fail(response.getStatusCode() + " " + bodyString);
        } else if (HttpStatus.SC_FORBIDDEN == response.getStatusCode()) {
            // Apim generated
            log.info("{} {} for {}", response.getStatusCode(), response.getStatusLine(), bodyString);
            if (bodyString == null) {
                Assertions.fail("403 FORBIDDEN with <empty body>");
            } else if (bodyString.contains("Client has no permission")) {
                // prevented by APIM limits matrix
                Assertions.fail("APIM blocked call: " + bodyString);
            } else if (bodyString.contains("\"status\":403")) {
                // DEPRECATED: should not happen anymore
                assertThat(bodyString).as("AITG-1599 Spring error instead of <Problem> object").contains("timestamp");
            }
            Assertions.fail("Developer security fault: unexpected response: " + response.getStatusCode() + " " + bodyString);
        } else if (HttpStatus.SC_UNAUTHORIZED == response.getStatusCode()) {
            // Apim generated
            Assertions.fail("401 -> SSO Token -> check environment config: " + bodyString);
        } else if (HttpStatus.SC_OK == response.getStatusCode()) {
            assertApplicationJson(response);
            if (acceptLanguage != null) {
                AssertionsResponse.assertLanguage(acceptLanguage, response.getHeader(HttpHeaders.CONTENT_LANGUAGE));
            }
            // Assertions.assertThat(response.getHeader(HEADER_REQUEST_ID)).endsWith(requestId);
            assertThat(bodyString).as("developer-error: OK-body is empty").isNotEmpty();
            assertThat(bodyString.length()).as("developer-error: OK-body too short").isGreaterThan(2);
        } else if (StringUtils.isBlank(bodyString)) {
            // no Backend generated 'Problem'
            if (HttpStatus.SC_BAD_REQUEST == response.getStatusCode()) {
                Assertions.fail(HttpStatus.SC_BAD_REQUEST + ": failed by Service-Contract params checker (code-block not reached), check required API-params/pathParams!");
            } else {
                Assertions.fail(response.getStatusCode() + ": unhandled error (developer error)");
            }
        } else if (HttpStatus.SC_BAD_REQUEST == response.getStatusCode()) {
            // for e.g. <!doctype html><html lang="en"><head><title>HTTP Status 400 – Bad Request</title><style type="text/css">h1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;} h2 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:16px;} h3 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:14px;} body {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;} b {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;} p {font-family:Tahoma,Arial,sans-serif;background:white;color:black;font-size:12px;} a {color:black;} a.name {color:black;} .line {height:1px;background-color:#525D76;border:none;}</style></head><body><h1>HTTP Status 400 – Bad Request</h1></body></html>
            if (bodyString.contains("<html")) {
                Assertions.fail("WAF may not accept a param value (use EncodingUtils::encode): " + bodyString);
            }
            assertProblemResponse(response, requestId, instance);
            Assertions.fail("400 -> body=" + bodyString);
        } else if (response.getStatusCode() == HttpStatus.SC_TOO_MANY_REQUESTS) {
            // 429 non Backend generated 'Problem' (headers, body-string might be anything)
            Assertions.fail("HttpStatus=" + response.getStatusCode() + " " + bodyString);
        } else {
            assertProblemResponse(response, requestId, instance);
            // interrupt further deserialization
            Assertions.fail(response.getStatusCode() + " body=" + bodyString);
        }
    }

    // check header and body
    private static Problem assertProblemResponse(Response response, String requestId, String instance) {
        assertCaseInsensitiveHeaders(response);
        final String bodyString = toBodyString(response);
        if (bodyString == null) {
            Assertions.fail("body is empty -> no Problem object contained");
        }

        return AssertionsResponse.assertProblemResponse(bodyString, response.getHeader(HttpHeaders.CONTENT_TYPE), response.getHeader(HttpHeaders.CONTENT_LANGUAGE), requestId,
            response.getHeader(MonitoringConstants.HEADER_REQUEST_ID), instance);
    }

    /**
     * Cloned!
     *
     * @see AssertionsResponse#assertCaseInsensitiveHeaders(org.springframework.http.HttpHeaders)
     */
    public static void assertCaseInsensitiveHeaders(Response response) {
        assertThat(response.getHeaders().get(HttpHeaders.CONTENT_TYPE.toLowerCase())).isEqualTo(response.getHeaders().get(HttpHeaders.CONTENT_TYPE));
        assertThat(response.getHeaders().get(HttpHeaders.CONTENT_LANGUAGE.toLowerCase())).isEqualTo(response.getHeaders().get(HttpHeaders.CONTENT_LANGUAGE));

        assertThat(response.getHeaders().get(MonitoringConstants.HEADER_REQUEST_ID.toLowerCase())).isEqualTo(response.getHeaders().get(MonitoringConstants.HEADER_REQUEST_ID));
    }

    protected static void assertApplicationJson(Response response) {
        AssertionsResponse.assertApplicationJson(response.getHeader(HttpHeaders.CONTENT_TYPE));
    }

    /**
     * @param configuration
     */
    private void configureEndpoint(@NonNull DasBackendEndpoint configuration) {
        this.configuration = configuration;
        if (StringUtils.isNotBlank(System.getProperty(ENVIRONMENT_URL))) {
            // called by Jenkinsfile
            url = System.getProperty(ENVIRONMENT_URL);
            log.info("using environment variable {} = {}", ENVIRONMENT_URL, url);
        } else {
            url = configuration.getEndpointAndPort();
        }
    }

    /**
     * @param service for e.g. "/api/sbb/v1/locations"
     * @return service-URL
     */
    protected final String getUrl(String service) {
        return url + service;
    }

    /**
     * Gives a request id for test, based on the test (method) name.
     */
    protected final String getRequestId() {
        ExtensionContext testContext = testContextGetter.getContext();
        String displayName = testContext.getDisplayName();
        Optional<Method> testMethod = testContext.getTestMethod();
        if (displayName.startsWith("[" /* @ParameterizedTest */) && testMethod.isPresent()) {
            displayName = testMethod.get().getName() + displayName;
        } else {
            displayName = StringUtils.removeEnd(displayName, "()");
        }
        return ServiceDoc.REQUEST_ID_VALUE_E2E_TEST + "_" + displayName;
    }

    /**
     * @param requestId tracing info
     * @return new basic RestAssured.io Request
     */
    protected final RequestSpecification createRequest(String requestId) {
        fiddleThatNastyRestAssuredStuff();

        final String requestIdValue = StringUtils.startsWith(requestId, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST) ? requestId : ServiceDoc.REQUEST_ID_VALUE_E2E_TEST + "_" + requestId;
        return RestAssured.given()
            .config(RestAssured.config().objectMapperConfig(new ObjectMapperConfig().jackson2ObjectMapperFactory(
                (type, s) -> MAPPER /* will set OffsetDateTime deserialization! */))
            )
            // fix javax.net.ssl.SSLHandshakeException: Remote host closed connection during handshake
            // .config(RestAssured.config.encoderConfig(EncoderConfig.encoderConfig().appendDefaultContentCharsetToContentTypeIfUndefined(true)))
            .urlEncodingEnabled(true) // necessary for params with Umlaut
            .header(MonitoringConstants.HEADER_REQUEST_ID, requestIdValue);
    }

    /**
     * Try to use ApiClient instead!
     *
     * @param acceptLanguage
     * @param requestId for explicite override of generic test-method
     * @return
     */
    protected RequestSpecification createRequestWithHeader(@NonNull String acceptLanguage, String requestId) {
        return createRequestWithHeader(acceptLanguage, requestId, token);
    }

    /**
     * Try to use ApiClient instead!
     * <p>
     * Create a Request to be executed directly to Openshift instance skiping APIM validation.
     * <p>
     *
     * @param acceptLanguage de, fr, it, en
     * @param requestId logging-context (SPLUNK, Instana header {@link MonitoringConstants#HEADER_REQUEST_ID})
     * @param
     * @return GET request header for APIM
     */
    protected RequestSpecification createRequestWithHeader(@NonNull String acceptLanguage, String requestId, @NonNull String bearerToken) {
        return createRequest(requestId)
            .header(HttpHeaders.AUTHORIZATION, bearerToken)
            .header(HttpHeaders.ACCEPT_LANGUAGE, acceptLanguage);
    }

    // non-translatable APIs
    protected Response requestPOST(@NonNull String url, @NonNull String postBody, @NonNull String requestId) {
        return createRequest(requestId)
            // specify to avoid HttpStatus 415
            .contentType(MediaType.APPLICATION_JSON_VALUE)
            .header(HttpHeaders.AUTHORIZATION, token)
            .body(postBody)
            .when()
            .post(getUrl(url));
    }

    /**
     * Create a B2C header and request with a concrete POST body.
     *
     * @param url POST URL
     * @param postBody JSON object serialized
     * @param acceptLanguage de,fr,it,en enforcing response texts translated
     * @param requestId log-tag
     * @return HTTP response
     */
    protected final Response requestPOST(@NonNull String url, @NonNull String postBody, @NonNull String acceptLanguage, @NonNull String requestId) {
        return createRequestWithHeader(acceptLanguage, requestId)
            // specify to avoid HttpStatus 415
            .contentType(MediaType.APPLICATION_JSON_VALUE)
            .body(postBody)
            .when()
            .post(getUrl(url));
    }

    /*
     * Cache-Control headers in ServiceCalendarController request are not declared explicitly yet -> call it generically by ApiClient
     *  responseAsync = journeyServiceApi.getSchedulesV3Api().getServiceCalendarWithHttpInfo(reqId, headerParams);
     *  response = blockBody(responseAsync);
     *
     * Unfortunately: header cannot be specified by: journeyServiceApi.getSchedulesV3Api().getServiceCalendarWithResponseSpec(requestID)
     */
    protected RequestSpecBuilder createRequestSpec(String apiPath) {
        return new RequestSpecBuilder(configuration, apiPath);
    }

    private void fiddleThatNastyRestAssuredStuff() {
        HttpClientConfig httpClientConfig = RestAssured.config.getHttpClientConfig()
            .setParam(ClientPNames.COOKIE_POLICY, CookiePolicy.BROWSER_COMPATIBILITY)
            .setParam(CoreConnectionPNames.CONNECTION_TIMEOUT, WEBCLIENT_TIMEOUT)
            .setParam(CoreConnectionPNames.SO_TIMEOUT, WEBCLIENT_TIMEOUT)
            // mvn prevention of: Invalid use of BasicClientConnManager
            .reuseHttpClientInstance();

        RestAssured.defaultParser = Parser.JSON;
        RestAssured.config = RestAssured.config
            .httpClient(httpClientConfig)
            .xmlConfig(RestAssured.config.getXmlConfig().with().validating(false).namespaceAware(false));
        RestAssured.useRelaxedHTTPSValidation();
    }

    protected <T> ResponseEntity<T> blockBody(Mono<ResponseEntity<T>> responseAsync) {
        return blockBody(responseAsync, null, getRequestId(), null);
    }

    protected <T> T getResponseBodyOrFail(Mono<ResponseEntity<T>> responseAsync) {
        return getResponseBodyOrFail(responseAsync, null, null, null);
    }

    protected <T> T getResponseBodyOrFail(Mono<ResponseEntity<T>> responseAsync, String acceptLanguage, String requestId, String instance) {
        final ResponseEntity<T> responseEntity = blockBody(responseAsync, acceptLanguage, requestId, instance);

        // see assertCaseInsensitiveHeaders();
        assertThat(responseEntity.getHeaders().get(HttpHeaders.CONTENT_TYPE)).as("CONTENT_TYPE highly expected").isNotEmpty();
        final String contentType = responseEntity.getHeaders().get(HttpHeaders.CONTENT_TYPE).get(0);
        assertThat(responseEntity.getHeaders().get(HttpHeaders.CONTENT_TYPE.toLowerCase()).get(0)).isEqualTo(responseEntity.getHeaders().get(HttpHeaders.CONTENT_TYPE).get(0));
        String contentLanguage = null;
        if (responseEntity.getHeaders().get(HttpHeaders.CONTENT_LANGUAGE) != null) {
            contentLanguage = responseEntity.getHeaders().get(HttpHeaders.CONTENT_LANGUAGE).get(0);
            assertThat(responseEntity.getHeaders().get(HttpHeaders.CONTENT_LANGUAGE.toLowerCase()).get(0)).isEqualTo(contentLanguage);

        }

        String responseRequestId = null;
        /* TODO
        if (!responseEntity.getHeaders().get(MonitoringConstants.HEADER_REQUEST_ID).isEmpty()) {
            responseRequestId = responseEntity.getHeaders().get(MonitoringConstants.HEADER_REQUEST_ID).get(0);
            assertThat(responseEntity.getHeaders().get(MonitoringConstants.HEADER_REQUEST_ID.toLowerCase()).get(0))
                .isEqualTo(responseRequestId);
        }

        if (StringUtils.isNotBlank(requestId)) {
            assertThat(responseEntity.getHeaders().get(MonitoringConstants.HEADER_REQUEST_ID).get(0)).contains(requestId);
        }
         */

        if (responseEntity.getStatusCode().value() == HttpStatus.SC_OK) {
            if (StringUtils.isNotBlank(acceptLanguage)) {
                // could be en in error-case
                //TODO                assertThat(responseEntity.getHeaders().get(HttpHeaders.CONTENT_LANGUAGE).get(0)).isEqualTo(acceptLanguage);
            }
            assertThat(responseEntity.getBody()).as("Backend must always return a JsonResponse object").isNotNull();
            return responseEntity.getBody();
        } else {
            AssertionsResponse.assertProblemResponse(responseEntity.getBody().toString(), contentType, contentLanguage, requestId, responseRequestId, instance);

            if (responseEntity.getStatusCode().value() == HttpStatus.SC_NOT_FOUND) {
                // must not be a fault always!
                Assertions.fail(NO_HITS);
            } else {
                Assertions.fail(responseEntity.getStatusCode() + " " + responseEntity.getBody());
            }
        }
        // won't reach
        return null;
    }

    public static final class RequestSpecBuilder {

        private final ApiClient apiClient;

        private final String apiPath;
        // create path and map variables
        private final Map<String, Object> pathParams = new HashMap<>();
        private final MultiValueMap<String, String> queryParams = new LinkedMultiValueMap<>();
        private final MultiValueMap<String, String> cookieParams = new LinkedMultiValueMap<>();
        private final MultiValueMap<String, Object> formParams = new LinkedMultiValueMap<>();
        private HttpMethod method = HttpMethod.GET;
        private Object postBody = null;
        private org.springframework.http.HttpHeaders headerParams = new org.springframework.http.HttpHeaders();
        private String requestId = null;

        private ParameterizedTypeReference<?> localVarReturnType = null;

        private String[] localVarAuthNames = new String[]{}; // or something else... for now always overridden

        private RequestSpecBuilder(DasBackendEndpoint configuration, String apiPath) {
            apiClient = new ApiClient();
            apiClient.setBasePath(configuration.getEndpointAndPort());
            this.apiPath = apiPath;
        }

        public RequestSpecBuilder withMethod(HttpMethod method) {
            this.method = method;
            return this;
        }

        public RequestSpecBuilder withPostBody(Object postBody) {
            this.postBody = postBody;
            return this;
        }

        public RequestSpecBuilder withRequestId(String requestId) {
            this.requestId = requestId;
            return this;
        }

        public RequestSpecBuilder withPathParam(String key, Object value) {
            this.pathParams.put(key, value);
            return this;
        }

        public RequestSpecBuilder withQueryParam(String key, String value) {
            this.queryParams.add(key, value);
            return this;
        }

        public RequestSpecBuilder withHttpHeaders(org.springframework.http.HttpHeaders headerParams) {
            this.headerParams = headerParams;
            return this;
        }

        public RequestSpecBuilder withLocalVarReturnType(ParameterizedTypeReference<?> localVarReturnType) {
            this.localVarReturnType = localVarReturnType;
            return this;
        }

        public WebClient.ResponseSpec invoke() {
            if (requestId != null) {
                headerParams.add(MonitoringConstants.HEADER_REQUEST_ID, apiClient.parameterToString(requestId));
            }
            final String[] localVarAccepts = {
                MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_PROBLEM_JSON_VALUE
            };
            final List<MediaType> localVarAccept = apiClient.selectHeaderAccept(localVarAccepts);
            final String[] localVarContentTypes = {};
            final MediaType localVarContentType = apiClient.selectHeaderContentType(localVarContentTypes);
            return apiClient
                .invokeAPI(apiPath, method, pathParams, queryParams, postBody, headerParams, cookieParams, formParams,
                    localVarAccept, localVarContentType, localVarAuthNames,
                    /* seems unused !*/ localVarReturnType);
        }

        public ResponseEntity<?> invokeToEntity() {
            return invoke().toEntity(localVarReturnType).block();
        }

        public <T> ResponseEntity<T> invokeToEntity(ParameterizedTypeReference<T> localVarReturnType) {
            withLocalVarReturnType(localVarReturnType);
            return invoke().toEntity(localVarReturnType).block();
        }
    }
}
