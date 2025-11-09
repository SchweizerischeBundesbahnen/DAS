package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.restclient.v1.model.FormationResponse;
import ch.sbb.backend.restclient.v1.model.SettingsResponse;
import lombok.experimental.UtilityClass;

@UtilityClass
public class AssertionsApiClientModel {

    public static void assertSettingsResponse(SettingsResponse settingsResponse) {
        assertThat(settingsResponse).isNotNull();
        assertThat(settingsResponse.getData()).as("Settings").isNotEmpty();
        // TODO validate other values
    }

    public static void assertFormationResponse(FormationResponse formationResponse) {
        assertThat(formationResponse).isNotNull();
        assertThat(formationResponse.getData()).as("Formation").isNotEmpty();
        // TODO validate other values
    }
}
