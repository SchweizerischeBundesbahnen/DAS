package ch.sbb.das.backend.restapi.e2etest.helper;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.restclient.v1.model.Problem;
import ch.sbb.das.backend.restapi.helper.ObjectMapperFactory;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.response.Response;
import java.io.IOException;
import java.util.Locale;
import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpHeaders;
import org.assertj.core.api.Assertions;
import org.hamcrest.CoreMatchers;
import org.hamcrest.MatcherAssert;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClientResponseException;

/**
 * Integration-Test utility for journey-service-client ApiClient based tests.
 *
 * @see RestAssuredCommand for restassured.io based helpers
 */
@Slf4j
@UtilityClass
public final class AssertionsResponse {

    private static final ObjectMapper MAPPER = ObjectMapperFactory.createMapper(true);

    public static boolean isNotFound(int responseHttpStatusCode, String responseBody, String responseContentType, String acceptLanguage, String responseContentLanguage, String responseRequestId,
        String requestRequestId) {
        if (HttpStatus.NOT_FOUND.value() == responseHttpStatusCode) {
            assertHeaderNotFound(responseHttpStatusCode, responseBody, responseContentType, acceptLanguage, responseContentLanguage, responseRequestId, requestRequestId);
            log.debug("404 NO_CONTENT");
            return true;
        }
        return false;
    }

    /**
     * Check @RestController response in case of an HTTP error.
     * <p>
     * Error responses depend on @RequestMapping ::produces JSON+PROBLEM configuration.
     *
     * @param ex
     */
    public static Problem assertClientException(WebClientResponseException ex, String requestId, String instance) {
        log.error("block failed: status={}, message={}, body={}", ex.getStatusCode(), ex.getMessage(), ex.getResponseBodyAsString());
        assertThat(ex.getStatusCode()).as(ex.getResponseBodyAsString()).isNotEqualTo(HttpStatus.TOO_MANY_REQUESTS);

        assertCaseInsensitiveHeaders(ex.getHeaders());
        assertThat(ex.getStatusCode()).as("response might be too big: " + ex.getCause()).isNotEqualTo(HttpStatus.OK);
        if (StringUtils.isBlank(ex.getResponseBodyAsString())) {
            Assertions.fail("request did not reach @RestController API method body (probably related to some mapping problem like &dateTime= format,..)");
        }
        if (ex.getResponseBodyAsString().contains("\"timestamp\"")) {
            if (HttpStatus.NOT_ACCEPTABLE.isSameCodeAs(ex.getStatusCode())) {
                // https://stackoverflow.com/questions/7462202/spring-json-request-getting-406-not-acceptable
                // if @RequestMapping(..,produces = MediaType.APPLICATION_PROBLEM_JSON_VALUE) only this might result
                Assertions.fail("Spring problem: request did not reach Controller method body (probably some mapping problem like dateTime format,..)", ex);
            }
            Assertions.fail("Spring exception caught instead of proper 'Problem'", ex);
        }

        assertThat(ex.getHeaders().getFirst(HttpHeaders.CONTENT_TYPE)).as("API-block probably not reached based on " + HttpHeaders.CONTENT_TYPE + ": " + ex)
            .isEqualTo(RestAssuredCommand.MEDIA_TYPE_APPLICATION_JSON_PROBLEM);
        return assertProblemResponse(ex, requestId, instance);
    }

    /**
     * Check the most common headers.
     * <p>
     * cloned in {@link RestAssuredCommand#assertCaseInsensitiveHeaders(Response)}
     *
     * @param httpHeaders javadoc says: Note that HttpHeaders generally treats header names in a case-insensitive manner.
     * @see <a href="https://datatracker.ietf.org/doc/html/rfc7230#section-3.2>RFC7230 Each header field consists of a case-insensitive field name...</a>
     */
    public static void assertCaseInsensitiveHeaders(org.springframework.http.HttpHeaders httpHeaders) {
        assertThat(httpHeaders.getFirst(HttpHeaders.CONTENT_TYPE.toLowerCase())).as("Content-Type").isEqualTo(httpHeaders.getFirst(HttpHeaders.CONTENT_TYPE));
        assertThat(httpHeaders.getFirst(HttpHeaders.CONTENT_LANGUAGE.toLowerCase())).as("Content-Language").isEqualTo(httpHeaders.getFirst(HttpHeaders.CONTENT_LANGUAGE));

        assertThat(httpHeaders.getFirst(MonitoringConstants.HEADER_REQUEST_ID.toLowerCase())).as("Request-ID").isEqualTo(httpHeaders.getFirst(MonitoringConstants.HEADER_REQUEST_ID));
    }

    // check header and body in a Problem case
    public static Problem assertProblemResponse(WebClientResponseException ex, String requestIdExpected, String instance) {
        assertCaseInsensitiveHeaders(ex.getHeaders());
        return assertProblemResponse(ex.getResponseBodyAsString(), ex.getHeaders().getFirst(HttpHeaders.CONTENT_TYPE), ex.getHeaders().getFirst(HttpHeaders.CONTENT_LANGUAGE), requestIdExpected,
            ex.getHeaders().getFirst(MonitoringConstants.HEADER_REQUEST_ID), instance);
    }

    // check header and body in a Problem case
    static Problem assertProblemResponse(String responseBody, String contentType, String contentLanguage, String requestIdExpected, String responseRequestId, String instance) {
        // handled by API code-block
        assertThat(contentType).isEqualTo(MediaType.APPLICATION_PROBLEM_JSON_VALUE);

        assertLanguage(ServiceDoc.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT /*99%*/, contentLanguage);
        assertRequestId(requestIdExpected, responseRequestId);
        assertThat(responseBody).contains("\"title\":");
        assertThat(responseBody).contains("\"detail\":");
        if (instance != null) {
            assertThat(responseBody).contains("\"instance\":");
        }
        assertThat(responseBody).contains("\"type\":");
        assertThat(responseBody).contains("\"status\":");

        try {
            final Problem problem = MAPPER.readValue(responseBody, Problem.class);
            if (StringUtils.isBlank(instance)) {
                // generally failing instance is expected in error body
                assertThat(responseBody.contains("\"instance\":\"/v1/")
                    || responseBody.contains("\"instance\":\"toplevel-error" /*see TopLevelHandler*/)).isTrue();
            } else {
                // when url match not exact-path -> always different
                if (instance.contains("/")) {
                    // case Service-API -> pathParams have ../{<concrete value} instead of param-name
                    assertThat(problem.getInstance()).as("Problem::instance expected").isNotNull();
                    MatcherAssert.assertThat("instance given in Error/Problem", problem.getInstance().toString(), CoreMatchers.containsString(instance.substring(0, instance.lastIndexOf("/"))));
                } else {
                    assertThat(problem.getInstance()).isEqualTo(instance);
                }
            }
            return problem;
        } catch (IOException e) {
            Assertions.fail("body deserialization failed: " + e.getMessage());
            return null;
        }
    }

    static void assertHeaderNotFound(int responseHttpStatusCode, String responseBody, String responseContentType, String acceptLanguage, String responseContentLanguage,
        String responseRequestId,
        String requestRequestId) {
        assertThat(responseHttpStatusCode).isEqualTo(HttpStatus.NOT_FOUND.value());
        assertThat(responseContentType).isEqualTo(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        assertLanguage(/*TODO StringUtils.isBlank(acceptLanguage) ? ServiceDoc.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT :*/ acceptLanguage, responseContentLanguage);
        assertRequestId(requestRequestId, responseRequestId);

        assertThat(responseBody).as("response body").isNotBlank();
    }

    public static void assertApplicationJson(String headerContentType) {
        assertThat(headerContentType).isEqualTo(MediaType.APPLICATION_JSON_VALUE);
    }

    /**
     * Return [0..1] {@link org.springframework.http.HttpHeaders#CONTENT_LANGUAGE} though multiple would be possible.
     *
     * @param languageExpected expected
     * @param headerContentLanguage returned in response
     */
    public static void assertLanguage(String languageExpected, String headerContentLanguage) {
        if (StringUtils.isBlank(headerContentLanguage)) {
            log.warn("developer fault: CONTENT_LANGUAGE not set");
        } else {
            // expect at least "en" as fallback
            assertThat(ServiceDoc.HEADER_ACCEPT_LANGUAGE_VALUES).as("non-supported language:" + headerContentLanguage).contains(new Locale(headerContentLanguage));
            if (StringUtils.isNotBlank(languageExpected)) {
                assertThat(headerContentLanguage).as(languageExpected + " expected").isEqualTo(languageExpected);
            }
        }
    }

    /**
     * Expect the requestIdExpected returned in response.
     *
     * @param requestIdExpected all or part of consumer set {@link MonitoringConstants#HEADER_REQUEST_ID} in request
     * @param responseRequestId extracted {@link MonitoringConstants#HEADER_REQUEST_ID} from response
     */
    public static void assertRequestId(String requestIdExpected, String responseRequestId) {
        if (StringUtils.isBlank(responseRequestId)) {
            // always test with Request-ID header set
            Assertions.fail(MonitoringConstants.HEADER_REQUEST_ID + " not given");
        }

        assertThat(responseRequestId).as("Developer bug: perhaps ApiClient test performed without a 'Request-ID'").isNotBlank();
        if (StringUtils.isNotBlank(requestIdExpected)) {
            assertThat(requestIdExpected).as(MonitoringConstants.HEADER_REQUEST_ID).startsWith(responseRequestId);
        }
    }
}
