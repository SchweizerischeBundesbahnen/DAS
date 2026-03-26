package ch.sbb.backend.admin.infrastructure.locations;

import static ch.sbb.backend.admin.infrastructure.locations.LocationsRestClientConfig.OAUTH2_CLIENT_REGISTRATION_ID;
import static org.springframework.security.oauth2.client.web.client.RequestAttributeClientRegistrationIdResolver.clientRegistrationId;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class LocationApiClient {

    // API maximum
    public static final int MAX_PAGE_SIZE = 2000;
    private final RestClient restClient;

    public LocationApiClient(RestClient restClient) {
        this.restClient = restClient;
    }

    public List<AtlasServicePoint> getServicePoints() {
        List<AtlasServicePoint> all = new ArrayList<>();
        int page = 0;
        AtlasServicePointResponse response = getServicePointsPaginated(page);
        if (response != null && response.objects() != null) {
            all.addAll(response.objects());
        }
        int totalCount = response != null ? response.totalCount() : 0;
        int totalPages = (int) Math.ceil((double) totalCount / MAX_PAGE_SIZE);
        for (page = 1; page < totalPages; page++) {
            response = getServicePointsPaginated(page);
            if (response != null && response.objects() != null) {
                all.addAll(response.objects());
            }
        }
        return all;
    }

    private AtlasServicePointResponse getServicePointsPaginated(int page) {
        return restClient.get()
            .uri(uriBuilder -> uriBuilder
                .path("/service-point-directory/v1/service-points")
                .queryParam("meansOfTransport", "TRAIN")
                .queryParam("statusRestrictions", "VALIDATED")
                .queryParam("countries", "SWITZERLAND", "ITALY", "FRANCE", "GERMANY")
                .queryParam("validToFromDate", LocalDate.now().toString())
                .queryParam("page", page)
                .queryParam("size", MAX_PAGE_SIZE)
                .build()
            )
            .attributes(clientRegistrationId(OAUTH2_CLIENT_REGISTRATION_ID))
            .retrieve()
            .body(AtlasServicePointResponse.class);
    }
}
