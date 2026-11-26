package ch.sbb.das.backend.locations.internal;

import static org.springframework.security.oauth2.client.web.client.RequestAttributeClientRegistrationIdResolver.clientRegistrationId;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.downstream.Downstream;
import ch.sbb.das.backend.common.downstream.DownstreamCallHandler;
import ch.sbb.das.backend.common.downstream.DownstreamRestClients;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.client.OAuth2ClientHttpRequestInterceptor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Datasource: atlas
 *
 * @see <a href="https://developer.sbb.ch/apis/atlas/information">atlas API</a>
 */
@Component
public class ServicePointApiClient {

    // API maximum
    public static final int MAX_PAGE_SIZE = 2000;
    private static final String OAUTH2_CLIENT_REGISTRATION_ID = "atlas";
    private final RestClient restClient;
    private final DownstreamCallHandler downstreamCallHandler;

    public ServicePointApiClient(
        DownstreamRestClients downstreamRestClients,
        DownstreamCallHandler downstreamCallHandler,
        OAuth2AuthorizedClientManager authorizedClientManager,
        @Value("${atlas.base-url}") String baseUrl
    ) {
        this.restClient = downstreamRestClients.builder(Downstream.ATLAS)
            .baseUrl(baseUrl)
            .requestInterceptor(new OAuth2ClientHttpRequestInterceptor(authorizedClientManager))
            .build();
        this.downstreamCallHandler = downstreamCallHandler;
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
        return downstreamCallHandler.call(Downstream.ATLAS, "getServicePoints", () -> restClient.get()
            .uri(uriBuilder -> uriBuilder
                .path("/service-point-directory/v1/service-points")
                .queryParam("statusRestrictions", "VALIDATED")
                .queryParam("countries", "SWITZERLAND", "ITALY", "FRANCE", "GERMANY", "AUSTRIA")
                .queryParam("validToFromDate", DateTimeUtil.today().toString())
                .queryParam("page", page)
                .queryParam("size", MAX_PAGE_SIZE)
                .build()
            )
            .attributes(clientRegistrationId(OAUTH2_CLIENT_REGISTRATION_ID))
            .retrieve()
            .body(ServicePointResponse.class));
    }
}
