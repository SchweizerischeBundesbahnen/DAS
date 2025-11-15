package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.restclient.v1.model.FormationResponse;
import ch.sbb.backend.restclient.v1.model.Logging;
import ch.sbb.backend.restclient.v1.model.Preload;
import ch.sbb.backend.restclient.v1.model.RuFeature;
import ch.sbb.backend.restclient.v1.model.Settings;
import ch.sbb.backend.restclient.v1.model.SettingsResponse;
import java.util.List;
import lombok.experimental.UtilityClass;

@UtilityClass
public class AssertionsApiClientModel {

    public static Settings assertSettingsResponse(SettingsResponse settingsResponse) {
        assertThat(settingsResponse).isNotNull();
        assertThat(settingsResponse.getData()).as("Settings").hasSize(1);
        final Settings settings = settingsResponse.getData().get(0);
        final List<RuFeature> ruFeatures = settings.getRuFeatures();
        assertThat(ruFeatures).hasSizeGreaterThanOrEqualTo(11);
        final Logging logging = settings.getLogging();
        assertThat(logging.getUrl()).isNotBlank();
        assertThat(logging.getToken()).isNotBlank();
        final Preload preload = settings.getPreload();
        assertThat(preload.getBucketUrl()).isNotBlank();
        assertThat(preload.getAccessKey()).isNotBlank();
        assertThat(preload.getAccessKey()).isNotBlank();

        return settings;
    }

    public static void assertFormationResponse(FormationResponse formationResponse) {
        assertThat(formationResponse).isNotNull();
        assertThat(formationResponse.getData()).as("Formation").isNotEmpty();
        // TODO validate other values
    }
}
