package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import io.restassured.response.Response;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestContextManager;

@ApiClientTestProfile
@Slf4j
class CustomerOrientedDepartureApiTest extends RestAssuredCommand {

    final static String ENDPOINT = "/v1/customer-oriented-departure";

    @Autowired
    DasBackendApi dasBackendApi;

    @Autowired
    DasBackendEndpointConfiguration endpointConfiguration;

    @BeforeEach
    void setUpContext() throws Exception {
        configure(endpointConfiguration);

        TestContextManager testContextManager = new TestContextManager(getClass());
        testContextManager.prepareTestInstance(this);
    }

    @Test
    void postSubscribe_ok() {
        final Response response = createRequestWithHeader("en", MonitoringConstants.HEADER_REQUEST_ID)
            .body("""
                {
                  "messageId": "M0002",
                  "zugnr": "37829",
                  "deviceId": "D0005",
                  "pushToken": "t",
                  "expired": "2026-04-15T08:00:00Z",
                  "evu": "EVU1",
                  "type": "REGISTER"
                }
                """)
            .when()
            .post(getUrl(ENDPOINT + "/subscribe"))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.SC_OK);
    }

    @Test
    void postConfirm_ok() {
        final Response response = createRequestWithHeader("en", MonitoringConstants.HEADER_REQUEST_ID)
            .pathParam("messageId", "M0002")
            .pathParam("deviceId", "D0005")
            .when()
            .post(getUrl(ENDPOINT + "/confirm"))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.SC_OK);
    }
}
