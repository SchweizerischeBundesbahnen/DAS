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
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestContextManager;

@ApiClientTestProfile
@Slf4j
class CustomerOrientedDepartureApiTest extends RestAssuredCommand {

    final static String ENDPOINT = "/v1/customer-oriented-departure";

    final static ObjectMapper MAPPER = new ObjectMapper();

    static {
        MAPPER.registerModule(new JavaTimeModule());
        MAPPER.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
        MAPPER.configure(SerializationFeature.WRITE_DATES_WITH_ZONE_ID, true);
    }

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

    @Test
    void postSubscribe_ok() throws JsonProcessingException {
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

    @Test
    void postConfirm_ok() {
        final String requestId = getRequestId();
        final Response response = createRequestWithHeader("en", requestId)
            .pathParam("messageId", messageId)
            .pathParam("deviceId", deviceId)
            .when()
            .post(getUrl(ENDPOINT + "/confirm"))
            .then()
            .extract()
            .response();

        assertThat(response.getStatusCode()).as(toBodyString(response)).isEqualTo(HttpStatus.SC_OK);
    }
}
