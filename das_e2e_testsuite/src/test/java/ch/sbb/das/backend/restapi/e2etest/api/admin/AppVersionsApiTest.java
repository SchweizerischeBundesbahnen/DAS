package ch.sbb.das.backend.restapi.e2etest.api.admin;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import ch.sbb.das.backend.restclient.v1.model.AppVersionResponse;
import io.restassured.response.Response;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.TestContextManager;
import reactor.core.publisher.Mono;

// Make sure tests leave no test-data traces in database!
@ApiClientTestProfile
@Slf4j
class AppVersionsApiTest extends RestAssuredCommand {

    final static String ENDPOINT = ServiceDoc.ADMIN_API_PATH + "/app-versions";

    @Autowired
    DasBackendApi backendApi;

    @Autowired
    DasBackendEndpointConfiguration endpointConfiguration;

    @BeforeEach
    void setUpContext() throws Exception {
        configure(endpointConfiguration);

        TestContextManager testContextManager = new TestContextManager(getClass());
        testContextManager.prepareTestInstance(this);
    }

    @Disabled("TODO call by AdminTenant")
    void create_ok() {

    }

    @Disabled("TODO call by AdminTenant")
    void update_ok() {

    }

    @Disabled("TODO call by AdminTenant")
    void delete_ok() {

    }

    @Disabled("TODO call by AdminTenant")
    void getAll_ok() {
        final String requestId = getRequestId();
        final Mono<ResponseEntity<AppVersionResponse>> responseAsync = backendApi.getAppVersionsApi().getAllAppVersionsWithHttpInfo(requestId);
        final AppVersionResponse appVersionResponse = getResponseBodyOrFail(responseAsync, null /*irrelevant for API*/, requestId, null);
        log.debug("{} in {}", appVersionResponse, responseAsync);

        assertAppVersionResponse(appVersionResponse);
    }

    @Disabled("TODO call by AdminTenant")
    void getById_ok() {
        final String requestId = getRequestId();
        final Mono<ResponseEntity<AppVersionResponse>> responseAsync = backendApi.getAppVersionsApi().getAppVersionByIdWithHttpInfo(requestId, 1);
        final AppVersionResponse appVersionResponse = getResponseBodyOrFail(responseAsync, null /*irrelevant for API*/, requestId, null);
        log.debug("{} in {}", appVersionResponse, responseAsync);

        assertAppVersionResponse(appVersionResponse);
    }

    @DisplayName("/app-versions missing AzureRole 'admin'|tests: 1406")
    @Test
    void getById_ForbiddenNonAdminTenant() {
        final Response response = createRequestWithHeader(null, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST)
            .param("id", "-1")
            .when()
            .get(getUrl(ENDPOINT))
            .then()
            .extract()
            .response();

        // TODO check 429 after global error-handler refactoring
        assertThat(response.getStatusCode()).as("User credentials must have Admin rights").isEqualTo(HttpStatus.SC_FORBIDDEN);
        final String body = toBodyString(response);
        assertThat(body).as("no 'helpful' hints desired for hackers").contains("Access not allowed: forbidden");
        assertThat(response.getHeader(MonitoringConstants.HEADER_REQUEST_ID)).as("body block not reached").isNull();
    }

    private static void assertAppVersionResponse(AppVersionResponse appVersionResponse) {
        // TODO validate generically
    }
}
