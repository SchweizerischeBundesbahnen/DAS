package ch.sbb.das.backend.restapi.e2etest.api;//package ch.sbb.backend;

import ch.sbb.backend.restclient.v1.model.SettingsResponse;
import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

@ApiClientTestProfile
@Slf4j
class SettingsApiTest extends RestAssuredCommand {

    final static String ENDPOINT = "/v1/settings";

    @Autowired
    DasBackendApi backendApi;

    @Autowired
    DasBackendEndpointConfiguration endpointConfiguration;

    @Test
    void getSettings() {
        try {
            final Mono<ResponseEntity<SettingsResponse>> responseAsync = backendApi.getSettingsApi().getSettingsWithHttpInfo(ServiceDoc.REQUEST_ID_VALUE_E2E_TEST);
            SettingsResponse settingsResponse = getResponseBodyOrFail(responseAsync, null /*irrelevant for API*/, ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
            log.debug("{} in {}", settingsResponse, responseAsync);

            AssertionsApiClientModel.assertSettingsResponse(settingsResponse, endpointConfiguration.endpoint());
        } catch (WebClientResponseException ex) {
            log.error("Exception when calling SettingsApi#getSettings", ex);
        }
    }
}