package ch.sbb.das.backend.restapi.e2etest.api;//package ch.sbb.backend;

import ch.sbb.backend.restclient.v1.model.SettingsResponse;
import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
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

    @Autowired
    DasBackendApi dasBackendApi;

    @Test
    void getConfigurations() {
        try {
            final Mono<ResponseEntity<SettingsResponse>> responseAsync = dasBackendApi.getSettingsApi().getConfigurationsWithHttpInfo();
            SettingsResponse settingsResponse = getResponseBodyOrFail(responseAsync, "de", ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
            log.debug("{} in {}", settingsResponse, responseAsync);

            AssertionsApiClientModel.assertSettingsResponse(settingsResponse);
        } catch (WebClientResponseException e) {
            log.error("Exception when calling SettingsApi#getConfigurations", e);
        }
    }
}