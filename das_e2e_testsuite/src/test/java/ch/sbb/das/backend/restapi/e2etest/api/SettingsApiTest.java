package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import ch.sbb.das.backend.restclient.v1.model.SettingsResponse;
import io.restassured.response.Response;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.TestContextManager;
import reactor.core.publisher.Mono;

@ApiClientTestProfile
@Slf4j
class SettingsApiTest extends RestAssuredCommand {

    final static String ENDPOINT = "/v1/settings";

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

    @Test
    void getSettings_okByOpenApiClient() {
        final Mono<ResponseEntity<SettingsResponse>> responseAsync = backendApi.getSettingsApi().getSettingsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, /*TODO config */ "9999.0.0");
            final SettingsResponse settingsResponse = getResponseBodyOrFail(responseAsync, null /*irrelevant for API*/, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
            log.debug("{} in {}", settingsResponse, responseAsync);

            AssertionsApiClientModel.assertSettingsResponse(settingsResponse, endpointConfiguration.endpoint());
    }

    @Test
    void settings_okByRestAssured() {
        final String requestId = getRequestId();
        final Response response = createRequestWithHeader("en", requestId)
            .param("dummy", "VALUE")
            .when()
            .get(getUrl(SettingsApiTest.ENDPOINT))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).as("proofs token and endpoint configuration for other RestAssured based testcases").isEqualTo(HttpStatus.SC_OK);
        final String body = toBodyString(response);
        assertThat(body).as("requesting unknown params is non-intriguing").contains("\"logging\":{\"url\":\"");
        assertOK(response, null /*not implemented yet*/, requestId, SettingsApiTest.ENDPOINT);
    }
}