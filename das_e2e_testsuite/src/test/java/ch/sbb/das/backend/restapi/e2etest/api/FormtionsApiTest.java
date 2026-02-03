package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.restclient.v1.model.FormationResponse;
import ch.sbb.backend.restclient.v1.model.Problem;
import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.AssertionsResponse;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import io.restassured.response.Response;
import java.time.LocalDate;
import lombok.extern.slf4j.Slf4j;
import org.assertj.core.api.Assertions;
import org.assertj.core.api.Assumptions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.TestContextManager;
import org.springframework.web.reactive.function.client.WebClientException;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

@ApiClientTestProfile
@Slf4j
class FormtionsApiTest extends RestAssuredCommand {

    final static String ENDPOINT = "/v1/formations";

    @Autowired
    DasBackendApi dasBackendApi;

    @Autowired
    DasBackendEndpointConfiguration endpointConfiguration;

    @BeforeEach
    void setUpContext() throws Exception {
        configure(endpointConfiguration);

        TestContextManager testContextManager = new TestContextManager(getClass());
        testContextManager.prepareTestInstance(this);
    }

    @Test
    void getFormations_operationalDayNonExisting() {
        final Response response = createRequestWithHeader("en", MonitoringConstants.HEADER_REQUEST_ID)
            .param("operationalTrainNumber", "89455")
            .param("operationalDay", "2026-02-30" /*BAD non-existing date*/)
            .param("company", "1033")
            .when()
            .get(getUrl(ENDPOINT))
            .then()
            .extract()
            .response();

        // see TopLevelHandler::handleExceptionInternal
        assertThat(response.getStatusCode()).as("must match Problem::status").isEqualTo(org.apache.http.HttpStatus.SC_BAD_REQUEST);
        final String body = toBodyString(response);
        assertThat(body).as("Problem::status").contains("\"status\":400");
        assertThat(body).as("Problem::title").contains("\"title\":\"Bad Request\"");
        assertThat(body).as("Problem::detail")
            .contains("\"detail\":\"Failed to convert 'operationalDay' with value: '2026-02-30' -> params: operationalTrainNumber=[89455];operationalDay=[2026-02-30];company=[1033];\"");
        assertThat(body).as("Problem::instance").contains("\"instance\":\"" + ENDPOINT + "\"");
        assertThat(body).as("Problem::type").doesNotContain("\type\"");
    }

    @Test
    void getFormations_operationalDayNotNow() {
        final String operationalDay = LocalDate.now().plusDays(10).toString();
        final Response response = createRequestWithHeader("en", MonitoringConstants.HEADER_REQUEST_ID)
            .param("operationalTrainNumber", "70982")
            .param("operationalDay", operationalDay)
            .param("company", "1033")
            .when()
            .get(getUrl(ENDPOINT))
            .then()
            .extract()
            .response();

        // FormationController self generated response
        assertThat(response.getStatusCode()).as("must match Problem::status").isEqualTo(org.apache.http.HttpStatus.SC_NOT_FOUND);
        final String body = toBodyString(response);
        assertThat(body).as("Problem::status").contains("\"status\":404");
        assertThat(body).as("Problem::title").contains("\"title\":\"No results found\"");
        assertThat(body).as("Problem::detail").contains("operationalDay='" + operationalDay + "' -> data may not be available at all if not TODAY.");
        assertThat(body).as("Problem::instance").contains("\"instance\":\"" + ENDPOINT + "/70982/" + operationalDay + "/1033\"");
        assertThat(body).as("Problem::type").doesNotContain("\type\"");
    }

    @Test
    void getFormations_companyBadFormat() {
        final LocalDate today = LocalDate.now();
        final String company = "RICS";
        try {
            final Mono<ResponseEntity<FormationResponse>> responseAsync = dasBackendApi.getFormationsApi()
                .getFormationsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, "007", today, company, null);
            responseAsync.block();

            Assertions.fail("Bad test conditions, should fail");
        } catch (WebClientResponseException ex) {
            // see TopLevelHandler::handleExceptionInternal
            assertThat(ex.getStatusCode()).as("must match Problem::status").isEqualTo(HttpStatus.BAD_REQUEST);
            final Problem problem = AssertionsResponse.assertClientException(ex, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
            assertThat(problem.getStatus()).isEqualTo(HttpStatus.BAD_REQUEST.value());
            assertThat(problem.getTitle()).as("Spring ProblemDetail::title").contains("Bad Request");
            assertThat(problem.getDetail()).as("FormationsController::formations @Pattern of REGEX").contains("company=[" + company + "]");
            assertThat(problem.getInstance().toString()).as("TopLevelHandler::handleExceptionInternal").isEqualTo(ENDPOINT);
            assertThat(problem.getType()).isNull();
        } catch (WebClientException ex) {
            Assertions.fail("Block: " + ex.getMessage(), ex);
        }
    }

    @Test
    void getFormations_operationTrainNumberBad() {
        final LocalDate today = LocalDate.now();
        try {
            final Mono<ResponseEntity<FormationResponse>> responseAsync = dasBackendApi.getFormationsApi()
                .getFormationsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, "007", today, "1033", null);
            responseAsync.block();

            Assertions.fail("Bad test conditions though valid values, should fail");
        } catch (WebClientResponseException ex) {
            assertThat(ex.getStatusCode()).as("must match Problem::status").isEqualTo(HttpStatus.NOT_FOUND);
            final Problem problem = AssertionsResponse.assertClientException(ex, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
            assertThat(problem.getStatus()).isEqualTo(HttpStatus.NOT_FOUND.value());
            assertThat(problem.getInstance().toString()).isEqualTo("/v1/formations/007/" + today + "/1033");
            assertThat(problem.getType()).isNull();
        } catch (WebClientException ex) {
            Assertions.fail("Block: " + ex.getMessage(), ex);
        }
    }

    // TODO find regular Cargo Train
    @Disabled
    void getFormations_concreteCargoTrain() {
        final Mono<ResponseEntity<FormationResponse>> responseAsync = dasBackendApi.getFormationsApi()
            .getFormationsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, "762", LocalDate.now(), "1033", null);
        final FormationResponse formationResponse = getResponseBodyOrFail(responseAsync, "de", ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
        log.debug("{} in {}", formationResponse, responseAsync);

        AssertionsApiClientModel.assertFormationResponse(formationResponse);
    }

    @Disabled
    void getFormations_cacheControl() {
        final String operationalTrainNumber = "762";
        final LocalDate date = LocalDate.now();
        final String company = "1033";

        // 1) request concrete cargo train without caching headers
        Mono<ResponseEntity<FormationResponse>> responseAsync = dasBackendApi.getFormationsApi()
            .getFormationsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, operationalTrainNumber, date, company, null);
        ResponseEntity<FormationResponse> responseEntity = blockBody(responseAsync, "de",ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
        assertThat(responseEntity.getStatusCode()).isEqualTo(HttpStatus.OK);
        AssertionsApiClientModel.assertFormationResponse(responseEntity.getBody());
        final String eTag = responseEntity.getHeaders().getETag();
        assertThat(eTag).as("Header ETag").isNotBlank();
        final String cacheControl = responseEntity.getHeaders().getCacheControl();
        assertThat(cacheControl).as("Header Cache-Control CONST declared by Service-Contract").startsWith("private, max-age=");
        log.debug("Header ETag({})={}, {}={}", HttpHeaders.IF_NONE_MATCH, eTag, HttpHeaders.CACHE_CONTROL, cacheControl);

        // 2) request with known ETag from previous response
        responseAsync = dasBackendApi.getFormationsApi()
            .getFormationsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, "762", LocalDate.now(), "1033", eTag);
        responseEntity = blockBody(responseAsync, "de",ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
        assertThat(responseEntity.getStatusCode()).as("caching should signal 304").isEqualTo(HttpStatus.NOT_MODIFIED);
        assertThat(responseEntity.getBody()).as("not a 'Problem', client may use its cached object instead").isNull();
    }
}