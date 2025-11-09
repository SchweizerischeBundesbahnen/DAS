package ch.sbb.das.backend.restapi.configuration;

import ch.sbb.backend.restclient.v1.ApiClient;
import ch.sbb.backend.restclient.v1.api.FormationsApi;
import ch.sbb.backend.restclient.v1.api.SettingsApi;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

@Getter
@Configuration
public class DasBackendApi {

    private final SettingsApi settingsApi;
    private final FormationsApi formationsApi;

    @Autowired
    public DasBackendApi(ApiClient apiClient) {
        settingsApi = new SettingsApi(apiClient);
        formationsApi = new FormationsApi(apiClient);
    }
}