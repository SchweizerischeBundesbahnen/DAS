package ch.sbb.das.backend.restapi.e2etest.api.driver;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpoint;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import ch.sbb.das.backend.restclient.v1.model.Company;
import ch.sbb.das.backend.restclient.v1.model.CurrentAppVersion;
import ch.sbb.das.backend.restclient.v1.model.Logging;
import ch.sbb.das.backend.restclient.v1.model.Preload;
import ch.sbb.das.backend.restclient.v1.model.RuFeature;
import ch.sbb.das.backend.restclient.v1.model.Settings;
import ch.sbb.das.backend.restclient.v1.model.SettingsResponse;
import ch.sbb.das.backend.restclient.v1.model.TourSystem;
import io.restassured.response.Response;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.TestContextManager;
import reactor.core.publisher.Mono;

@ApiClientTestProfile
@Slf4j
class SettingsApiTest extends RestAssuredCommand {

    final static String ENDPOINT = ServiceDoc.DRIVER_API_PATH + "/settings";

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

    @DisplayName("/settings&xAppVersion=INFINITE OK|tests: 1006,1602,713,1406")
    @Test
    void getSettings_okByOpenApiClient() {
        final Mono<ResponseEntity<SettingsResponse>> responseAsync = backendApi.getSettingsApi().getSettingsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, /*TODO config */ "9999.0.0");
        final SettingsResponse settingsResponse = getResponseBodyOrFail(responseAsync, null /*irrelevant for API*/, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
        log.debug("{} in {}", settingsResponse, responseAsync);

        assertSettingsResponse(settingsResponse, endpointConfiguration.endpoint());
    }

    @DisplayName("/settings&xAppVersion=0.1.0 OK|tests: 1006,1602,713,1406")
    @Test
    void settings_okByRestAssured() {
        final String requestId = getRequestId();
        final Response response = createRequestWithHeader("en", requestId)
            .param("dummy", "VALUE")
            .header("X-App-Version", "0.1.0")
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

    private static Settings assertSettingsResponse(SettingsResponse settingsResponse, DasBackendEndpoint backendEndpoint) {
        assertThat(settingsResponse).isNotNull();
        assertThat(settingsResponse.getData()).as(Settings.class.getSimpleName()).hasSize(1);
        final Settings settings = settingsResponse.getData().get(0);

        final List<Company> companies = settings.getCompanies();
        assertThat(companies).hasSizeGreaterThan(0);

        final List<TourSystem> tourSystems = settings.getTourSystems();
        assertThat(tourSystems).hasSizeGreaterThan(0);

        final List<RuFeature> ruFeatures = settings.getRuFeatures();
        if (!backendEndpoint.isLocalHost()) {
            assertThat(ruFeatures).as("check implemented and administrated RUFeatures for env").hasSizeGreaterThanOrEqualTo(11);
        }

        final Logging logging = settings.getLogging();
        assertThat(logging.getUrl()).isNotBlank();
        if (!backendEndpoint.isLocalHost()) {
            assertThat(logging.getToken()).isNotBlank();
        }

        final Preload preload = settings.getPreload();
        assertThat(preload.getBucketUrl()).isNotBlank();
        if (!backendEndpoint.isLocalHost()) {
            assertThat(preload.getAccessKey()).isNotBlank();
            assertThat(preload.getAccessKey()).isNotBlank();
        }

        final CurrentAppVersion currentAppVersion = settings.getCurrentAppVersion();
        assertThat(currentAppVersion).isNotNull();
        if (currentAppVersion.isExpired()) {
            assertThat(currentAppVersion.getExpiryDate()).isNotNull();
        }

        return settings;
    }
}
