package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import io.restassured.response.Response;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.assertj.core.api.Assumptions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestContextManager;

/**
 * Testing {@link ch.sbb.backend.restclient.v1.model.Problem} returned by DAS-Backend RestControllers or TopLevelHandler.
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

    /**
     * Test is a base condition for the other ones, proofing token and access route are ok.
     *
     * @see SettingsApiTest
     */
    @Test
    void ok_assumption() {
        final String requestId = getRequestId();
        final Response response = createRequestWithHeader("en", requestId)
            .param("dummy", "VALUE")
            .when()
            .get(getUrl(SettingsApiTest.ENDPOINT))
            .then()
            .extract()
            .response();

        Assumptions.assumeThat(response.getStatusCode()).as("proofs token and endpoint as guaranteed for other testcases here").isEqualTo(HttpStatus.SC_OK);
        final String body = toBodyString(response);
        assertThat(body).as("requesting unknown params is non-intriguing").contains("\"logging\":{\"url\":");
        assertOK(response, null /*not implemented yet*/, requestId, SettingsApiTest.ENDPOINT);
    }

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
            // TODO adapt when > v0.7.1 is deployed on DEV acc. to APIM response
            assertThat(toBodyString(response)).isEqualTo("Access not allowed: Token is expired or invalid");
        }
    }

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

        if (isAccessibleWithoutApim()) {
            // reaches DAS-Backend::TenantJWSKeySelector
            assertThat(response.getStatusCode()).as("depends on environment at caller and server").isEqualTo(HttpStatus.SC_NOT_FOUND);
            final String body = toBodyString(response);
            assertThat(body).as("No RestController there -> TopLevelHandler").isNotBlank();
            assertThat(body).as("Problem::status").contains("\"status\":404");
            assertThat(body).as("Problem::title").contains("\"title\":\"Not Found\"");
            assertThat(body).as("Problem::detail").contains("\"detail\":\"No static resource v1/bad_api.\"");
            assertThat(body).as("Problem::instance").contains("\"instance\":\"/v1/toplevel-error\"");
            assertThat(body).as("Problem::type").contains("\"type\":\"https://github.com/SchweizerischeBundesbahnen/DAS/tree/main/docs/content/architecture/06_runtime_view/03_problem-manual.md\"");
        } else {
            assertThat(response.getStatusCode()).as("depends on environment at caller and server").isEqualTo(HttpStatus.SC_FORBIDDEN);

            final String jsonErrorBody = toBodyString(response);
            assertThat(jsonErrorBody).isNotBlank();
            if (jsonErrorBody.contains("\"timestamp\":")) {
                log.warn("Spring problem sent for non-existing endpoint instead of proper Problem: {}", jsonErrorBody);
            } else {
                log.info("proper Problem: {}", jsonErrorBody);
                // TODO adapt when > v0.7.1 is deployed on DEV acc. to APIM response
                assertThat(jsonErrorBody).as("non-existing endpoint").contains("Access not allowed: forbidden");
            }
        }
    }

    private boolean isAccessibleWithoutApim() {
        return endpointConfiguration.endpoint().isLocalHost();
    }
}
