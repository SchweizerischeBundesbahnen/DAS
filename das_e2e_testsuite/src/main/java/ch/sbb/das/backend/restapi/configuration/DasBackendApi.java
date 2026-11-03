package ch.sbb.das.backend.restapi.configuration;

import ch.sbb.das.backend.restclient.v1.ApiClient;
import ch.sbb.das.backend.restclient.v1.api.AppVersionsApi;
import ch.sbb.das.backend.restclient.v1.api.DepartureApi;
import ch.sbb.das.backend.restclient.v1.api.FormationsApi;
import ch.sbb.das.backend.restclient.v1.api.SettingsApi;
import lombok.Getter;
import org.springframework.context.annotation.Configuration;

@Getter
@Configuration
public class DasBackendApi {

    // Driver-API
    private final SettingsApi settingsApi;
    private final FormationsApi formationsApi;
    private final DepartureApi departuresApi;
    // TODO UserPropertiesApi, TrainIdentificationsApi, PersonalNotesApi, TransportPaperApi

    // Admin-API
    private final AppVersionsApi appVersionsApi;
    // TODO SpecialHolidaysApi, RUIndicationTemplatesAPI, CompaniesApi, LocationsApi, ExternalLinksApi, RUFeaturesApi, RUIndicationsApi;

    public DasBackendApi(ApiClient apiClient) {
        settingsApi = new SettingsApi(apiClient);
        formationsApi = new FormationsApi(apiClient);
        departuresApi = new DepartureApi(apiClient);
        appVersionsApi = new AppVersionsApi(apiClient);
    }
}
