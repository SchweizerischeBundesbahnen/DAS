package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import ch.sbb.das.backend.restclient.v1.model.AppVersionResponse;
import ch.sbb.das.backend.restclient.v1.model.AppVersionsResponse;
import io.restassured.response.Response;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.TestContextManager;
import reactor.core.publisher.Mono;

@ApiClientTestProfile
@Slf4j
class AppVersionsApiTest extends RestAssuredCommand {

    final static String ENDPOINT = "/v1/settings/app-version";

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
        final Mono<ResponseEntity<AppVersionsResponse>> responseAsync = backendApi.getAppVersionsApi().getAllWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST);
        final AppVersionsResponse appVersionResponse = getResponseBodyOrFail(responseAsync, null /*irrelevant for API*/, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
        log.debug("{} in {}", appVersionResponse, responseAsync);

        // TODO AssertionsApiClientModel.assertAppVersionResponse(appVersionResponse, endpointConfiguration.endpoint());
    }

    @Disabled("TODO call by AdminTenant")
    void getById_ok() {
        final Mono<ResponseEntity<AppVersionResponse>> responseAsync = backendApi.getAppVersionsApi().getByIdWithHttpInfo(1, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST);
        final AppVersionResponse appVersionResponse = getResponseBodyOrFail(responseAsync, null /*irrelevant for API*/, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
        log.debug("{} in {}", appVersionResponse, responseAsync);

        // TODO AssertionsApiClientModel.assertAppVersionResponse(appVersionResponse, endpointConfiguration.endpoint());
    }

    @Test
    void getById_ForbiddenNonAdminTenant() {
        final String requestId = getRequestId();
        final Response response = createRequestWithHeader(null, requestId)
            .param("id", "-1")
            .when()
            .get(getUrl(AppVersionsApiTest.ENDPOINT))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).as("User credentials must not be Admin").isEqualTo(HttpStatus.SC_FORBIDDEN);
        final String body = toBodyString(response);
        assertThat(body).as("no hints desired for hackers").isEmpty();
        assertThat(response.getHeader(MonitoringConstants.HEADER_REQUEST_ID)).as("body block not reached").isNull();
    }
}