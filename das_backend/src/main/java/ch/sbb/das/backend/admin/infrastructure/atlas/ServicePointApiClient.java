package ch.sbb.das.backend.admin.infrastructure.atlas;

import static ch.sbb.das.backend.admin.infrastructure.atlas.RestClientConfig.OAUTH2_CLIENT_REGISTRATION_ID;
import static org.springframework.security.oauth2.client.web.client.RequestAttributeClientRegistrationIdResolver.clientRegistrationId;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class ServicePointApiClient {

    // API maximum
    public static final int MAX_PAGE_SIZE = 2000;
    private final RestClient restClient;

    public ServicePointApiClient(RestClient.Builder builder) {
        this.restClient = builder.build();
    }

    public List<ServicePoint> getAll() {
        List<ServicePoint> all = new ArrayList<>();
        int page = 0;
        ServicePointResponse response = getServicePointsPaginated(page);
        if (response != null && response.objects() != null) {
            all.addAll(response.objects());
        }
        int totalCount = response == null ? 0 : response.totalCount();
        int totalPages = (int) Math.ceil((double) totalCount / MAX_PAGE_SIZE);
        for (page = 1; page < totalPages; page++) {
            response = getServicePointsPaginated(page);
            if (response != null && response.objects() != null) {
                all.addAll(response.objects());
            }
        }
        return all;
    }

    private ServicePointResponse getServicePointsPaginated(int page) {
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
            .body(ServicePointResponse.class);
    }
}
