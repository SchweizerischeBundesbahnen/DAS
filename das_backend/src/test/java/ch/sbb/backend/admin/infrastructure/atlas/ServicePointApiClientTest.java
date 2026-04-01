package ch.sbb.backend.admin.infrastructure.atlas;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.restclient.test.autoconfigure.RestClientTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import tools.jackson.databind.json.JsonMapper;

@RestClientTest(ServicePointApiClient.class)
class ServicePointApiClientTest {

    @Autowired
    private MockRestServiceServer server;

    @Autowired
    private ServicePointApiClient apiClient;

    @Autowired
    private JsonMapper jsonMapper;

    @Test
    void getAll_handlesPagination() {
        int totalSize = 5500;
        int pageSize = 2000;
        server.expect(requestTo(uri(0, pageSize)))
            .andRespond(withSuccess(servicePointsResponse(pageSize, totalSize), MediaType.APPLICATION_JSON));
        server.expect(requestTo(uri(1, pageSize)))
            .andRespond(withSuccess(servicePointsResponse(pageSize, totalSize), MediaType.APPLICATION_JSON));
        server.expect(requestTo(uri(2, pageSize)))
            .andRespond(withSuccess(servicePointsResponse(1500, totalSize), MediaType.APPLICATION_JSON));

        List<ServicePoint> all = apiClient.getAll();
        assertThat(all).hasSize(totalSize);
    }

    private String servicePointsResponse(int pageSize, int total) {
        List<ServicePoint> servicePoints = new ArrayList<>();
        for (int i = 0; i < pageSize; i++) {
            servicePoints.add(new ServicePoint(
                "ID" + i,
                "Name" + i,
                LocalDate.now(),
                LocalDate.now().plusDays(1),
                new ServicePoint.ServicePointNumber(i, i)
            ));
        }
        ServicePointResponse response = new ServicePointResponse(servicePoints, total);
        return jsonMapper.writeValueAsString(response);
    }

    private String uri(int page, int size) {
        LocalDate today = LocalDate.now();
        return String.format(
            "/service-point-directory/v1/service-points?meansOfTransport=TRAIN&statusRestrictions=VALIDATED&countries=SWITZERLAND&countries=ITALY&countries=FRANCE&countries=GERMANY&validToFromDate=%s&page=%s&size=%s",
            today, page, size);
    }
}

