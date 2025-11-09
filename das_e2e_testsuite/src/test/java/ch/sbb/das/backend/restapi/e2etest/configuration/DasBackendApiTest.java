package ch.sbb.das.backend.restapi.e2etest.configuration;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;

@ApiClientTestProfile
class DasBackendApiTest {

    @Autowired
    DasBackendApi dasBackendApi;

    @Test
    void clientApiV1() {
        assertThat(dasBackendApi.getSettingsApi()).isNotNull();
        assertThat(dasBackendApi.getFormationsApi()).isNotNull();
    }
}