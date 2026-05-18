package ch.sbb.das.backend.restapi.configuration;

import ch.sbb.das.backend.restclient.v1.ApiClient;
import ch.sbb.das.backend.restclient.v1.api.AppVersionsApi;
import ch.sbb.das.backend.restclient.v1.api.CustomerOrientedDepartureApi;
import ch.sbb.das.backend.restclient.v1.api.FormationsApi;
import ch.sbb.das.backend.restclient.v1.api.SettingsApi;
import lombok.Getter;
import org.springframework.context.annotation.Configuration;

@Getter
@Configuration
public class DasBackendApi {

    private final SettingsApi settingsApi;
    private final FormationsApi formationsApi;
    private final CustomerOrientedDepartureApi customerOrientedDepartureApi;
    private final AppVersionsApi appVersionsApi;
    // TODO private final Location(s)Api;
    // TODO private final NoticeTemplatesApi;

    public DasBackendApi(ApiClient apiClient) {
        settingsApi = new SettingsApi(apiClient);
        formationsApi = new FormationsApi(apiClient);
        customerOrientedDepartureApi = new CustomerOrientedDepartureApi(apiClient);
        appVersionsApi = new AppVersionsApi(apiClient);
    }
}
