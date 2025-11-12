package ch.sbb.das.backend.restapi.e2etest.api;

import ch.sbb.backend.restclient.v1.model.FormationResponse;
import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import java.time.LocalDate;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

@ApiClientTestProfile
@Slf4j
class FormtionsApiTest extends RestAssuredCommand {

    @Autowired
    DasBackendApi dasBackendApi;

    @Test
    void getConfigurations() {
        try {
            final Mono<ResponseEntity<FormationResponse>> responseAsync = dasBackendApi.getFormationsApi().getFormationWithHttpInfo("761", LocalDate.now(), "1033", null);
            FormationResponse formationResponse = getResponseBodyOrFail(responseAsync, "de", ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
            log.debug("{} in {}", formationResponse, responseAsync);

            AssertionsApiClientModel.assertFormationResponse(formationResponse);
        } catch (WebClientResponseException e) {
            log.error("Exception when calling SettingsApi#getConfigurations", e);
        }
    }
}
