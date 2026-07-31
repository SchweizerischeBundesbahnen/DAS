package ch.sbb.das.backend.restapi.e2etest.api;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.e2etest.configuration.ApiClientTestProfile;
import ch.sbb.das.backend.restapi.e2etest.helper.RestAssuredCommand;
import ch.sbb.das.backend.restclient.v1.model.SubscribeRequest;
import io.restassured.response.Response;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import lombok.extern.slf4j.Slf4j;
import org.apache.http.HttpStatus;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestContextManager;
import tools.jackson.databind.json.JsonMapper;

@ApiClientTestProfile
@Slf4j
class CustomerOrientedDepartureApiTest extends RestAssuredCommand {

    final static String ENDPOINT = "/v1/customer-oriented-departure";

    final static JsonMapper MAPPER = new JsonMapper();

    // mock though keep the same for subscribe/confirm
    String deviceId = "D0005";
    String messageId = "M0002";

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

    @DisplayName("DAS-Backend proxy->GEMS::subscribe|tests: 1538")
    @Test
    void postSubscribe_ok() {
        SubscribeRequest request = new SubscribeRequest();
        request.messageId(messageId);
        request.zugnr("37829");
        request.deviceId(deviceId);
        request.pushToken("t");
        request.expiresAt(OffsetDateTime.now(ZoneId.of("UTC")).truncatedTo(ChronoUnit.MINUTES));
        request.evu("EVU1" /* avoid traffic relevant KoA by this integration-test */);
        request.type("REGISTER");
        request.driver(true);

        final String requestId = getRequestId();
        final Response response = createRequestWithHeader("en", requestId)
            .contentType("application/json")
            .body(MAPPER.writeValueAsString(request))
            .when()
            .post(getUrl(ENDPOINT + "/subscribe"))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).as(toBodyString(response)).isEqualTo(HttpStatus.SC_OK);
    }

    @DisplayName("DAS-Backend proxy->GEMS::confirm|tests: 1538")
    @Test
    void postConfirm_ok() {
        final String requestId = getRequestId();
        final Response response = createRequestWithHeader("en", requestId)
            .pathParam("messageId", messageId)
            .pathParam("deviceId", deviceId)
            .when()
            .post(getUrl(ENDPOINT + "/confirm/{messageId}/{deviceId}"))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).as(toBodyString(response)).isEqualTo(HttpStatus.SC_OK);
    }
}
