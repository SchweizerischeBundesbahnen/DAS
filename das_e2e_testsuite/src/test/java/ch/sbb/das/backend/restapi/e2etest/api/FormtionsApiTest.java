package ch.sbb.das.backend.restapi.e2etest.api;//package ch.sbb.backend;

import ch.sbb.backend.restclient.v1.model.FormationResponse;
import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.AssertionsResponse;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.e2etest.helper.ServiceDoc;
import java.time.LocalDate;
import lombok.extern.slf4j.Slf4j;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.reactive.function.client.WebClientException;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;

@ApiClientTestProfile
@Slf4j
class FormtionsApiTest extends RestAssuredCommand {

    @Autowired
    DasBackendApi dasBackendApi;

    @Test
    void getConfigurations_badOperationTrainNumber() {
        try {
            final Mono<ResponseEntity<FormationResponse>> responseAsync = dasBackendApi.getFormationsApi().getFormationWithHttpInfo("007", LocalDate.now(), "1033", null);
            responseAsync.block();

            Assertions.fail("Bad test conditions, should fail");
        } catch (WebClientResponseException ex) {
            AssertionsResponse.assertClientException(ex, getRequestId(), null);
            Assertions.fail("Block: " + ex.getResponseBodyAsString());
        } catch (WebClientException ex) {
            Assertions.fail("Block: " + ex.getMessage(), ex);
        }
    }

    //TODO find regular Cargo Train
    @Disabled
    void getConfigurations_concreteCargoTrain() {
        try {
            final Mono<ResponseEntity<FormationResponse>> responseAsync = dasBackendApi.getFormationsApi().getFormationWithHttpInfo("762", LocalDate.now(), "1033", null);
            FormationResponse formationResponse = getResponseBodyOrFail(responseAsync, "de", ServiceDoc.REQUEST_ID_VALUE_E2E_TEST, null);
            log.debug("{} in {}", formationResponse, responseAsync);

            AssertionsApiClientModel.assertFormationResponse(formationResponse);
        } catch (WebClientResponseException e) {
            log.error("Exception when calling SettingsApi#getConfigurations", e);
        }
    }
}