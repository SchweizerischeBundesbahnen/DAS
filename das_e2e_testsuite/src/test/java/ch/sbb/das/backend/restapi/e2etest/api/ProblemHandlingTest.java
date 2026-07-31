package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import ch.sbb.das.backend.restclient.v1.model.Problem;
import io.restassured.response.Response;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestContextManager;

/**
 * Testing {@link Problem} returned by DAS-Backend RestControllers or TopLevelHandler.
 */
@ApiClientTestProfile
@Slf4j
public class ProblemHandlingTest extends RestAssuredCommand {

    @Autowired
    DasBackendEndpointConfiguration endpointConfiguration;

    @BeforeEach
    void setUpContext() throws Exception {
        configure(endpointConfiguration);

        TestContextManager testContextManager = new TestContextManager(getClass());
        testContextManager.prepareTestInstance(this);
    }

    @DisplayName("APIM access by BAD JWT|tests: 361")
    @Test
    void checkAuthorization_badNonJWT() {
        final Response response = createRequestWithHeader("de", getRequestId(), SSO_BEARER_TOKEN_PREFIX + (MonitoringConstants.TESTMARKER_BAD + "JWT").toLowerCase())
            .get(getUrl(SettingsApiTest.ENDPOINT))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).as("does not reach DAS-Backend::TenantJWSKeySelector").isEqualTo(HttpStatus.SC_UNAUTHORIZED);
        if (isAccessibleWithoutApim()) {
            assertThat(toBodyString(response)).as("SettingsController not reached -> no 'Problem' object").isEmpty();
        } else {
            assertThat(toBodyString(response)).isEqualTo("Access not allowed: Token is expired or invalid");
        }
    }

    @DisplayName("APIM endpoint FORBIDDEN|tests: 361")
    @Test
    void endpoint_nonExisting() {
        final String endpointBad = "/v1/" + (MonitoringConstants.TESTMARKER_BAD + "API").toLowerCase();

        final Response response = createRequestWithHeader("fr", getRequestId())
            .param("dummy", "VALUE")
            .when()
            .get(getUrl(endpointBad))
            .then()
            .extract()
            .response();

        final String body = toBodyString(response);
        if (isAccessibleWithoutApim()) {
            // see TopLevelHandler::handleExceptionInternal
            assertThat(response.getStatusCode()).as("must match Problem::status").isEqualTo(HttpStatus.SC_NOT_FOUND);
            assertThat(body).as("spring.mvc.problemdetails not properly configured").doesNotContain("\"timestamp\":");
            assertThat(body).as("Problem::status").contains("\"status\":404");
            assertThat(body).as("Problem::title").contains("\"title\":\"Not Found\"");
            assertThat(body).as("Problem::detail").contains("\"detail\":\"No static resource v1/bad_api. -> params: dummy=[VALUE];");
            assertThat(body).as("Problem::instance").contains("\"instance\":\"/v1/bad_api\"");
            assertThat(body).as("Problem::type").doesNotContain("\type\"");
        } else {
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.SC_FORBIDDEN);
            assertThat(body).isEqualTo("Access not allowed: forbidden");
        }
    }
}
