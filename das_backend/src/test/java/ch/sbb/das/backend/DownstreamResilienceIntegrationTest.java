package ch.sbb.das.backend;

import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.API_TRANSPORT_PAPERS;
import static ch.sbb.das.backend.departures.internal.DepartureController.API_DEPARTURES;
import static ch.sbb.das.backend.locations.internal.TafTapLocationController.API_LOCATIONS;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.common.security.UserRole;
import ch.sbb.das.backend.locations.internal.TafTapLocationsImportService;
import java.util.concurrent.TimeUnit;
import java.util.function.Supplier;
import mockwebserver3.Dispatcher;
import mockwebserver3.MockResponse;
import mockwebserver3.MockWebServer;
import mockwebserver3.QueueDispatcher;
import mockwebserver3.RecordedRequest;
import mockwebserver3.SocketEffect;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

/**
 * Timeouts, retries and error mapping of the downstream calls, against stub servers on real sockets. Timeouts and backoffs are shortened (see
 * {@link #downstreams}); production values are in {@code application.yaml}.
 */
@IntegrationTest
class DownstreamResilienceIntegrationTest {

    private static final String READ_TIMEOUT = "PT0.5S";
    private static final long SLOWER_THAN_READ_TIMEOUT_MS = 1500;

    private static final MockWebServer GEMS = start();
    private static final MockWebServer ORCA = start();
    private static final MockWebServer ATLAS = start();
    private static final MockWebServer TOKEN = start();

    @Autowired
    MockMvc mvc;

    private Supplier<MockResponse> tokenResponse;
    private int gemsRequestsBefore;
    private int orcaRequestsBefore;
    private int atlasRequestsBefore;
    private int tokenRequestsBefore;

    @DynamicPropertySource
    static void downstreams(DynamicPropertyRegistry registry) {
        registry.add("proxy.base-url", () -> baseUrl(GEMS));
        registry.add("formation.transport-paper.orca.base-url", () -> baseUrl(ORCA));
        registry.add("atlas.base-url", () -> baseUrl(ATLAS));
        for (String registration : new String[] {"orca", "atlas", "azure"}) {
            registry.add("spring.security.oauth2.client.provider." + registration + ".token-uri", () -> baseUrl(TOKEN) + "/token");
        }
        registry.add("downstream.oauth2-token.read-timeout", () -> READ_TIMEOUT);
        for (String client : new String[] {"gems", "orca", "atlas"}) {
            registry.add("downstream.clients." + client + ".read-timeout", () -> READ_TIMEOUT);
            registry.add("downstream.clients." + client + ".retry.delay", () -> "PT0.05S");
        }
    }

    @AfterAll
    static void stop() {
        GEMS.close();
        ORCA.close();
        ATLAS.close();
        TOKEN.close();
    }

    @BeforeEach
    void resetServers() {
        GEMS.setDispatcher(failFastQueue());
        ORCA.setDispatcher(failFastQueue());
        ATLAS.setDispatcher(failFastQueue());
        // expired at once (Spring Security subtracts a clock skew of 60 s), so every call fetches a token
        tokenResponse = () -> json(200, """
            {"access_token": "token", "token_type": "Bearer", "expires_in": 1}
            """);
        TOKEN.setDispatcher(new Dispatcher() {
            @Override
            public MockResponse dispatch(RecordedRequest request) {
                return tokenResponse.get();
            }
        });
        gemsRequestsBefore = GEMS.getRequestCount();
        orcaRequestsBefore = ORCA.getRequestCount();
        atlasRequestsBefore = ATLAS.getRequestCount();
        tokenRequestsBefore = TOKEN.getRequestCount();
    }

    @Nested
    @WithMockRole(roles = UserRole.DRIVER)
    class Gems {

        @Test
        @DisplayName("subscribe_readTimeout_gatewayTimeoutWithoutRetry|tpKlb62Ejq2MGjcWCO7W|tests:2652")
        void subscribe_readTimeout_gatewayTimeoutWithoutRetry() throws Exception {
            GEMS.enqueue(slow());

            subscribe()
                .andExpect(status().isGatewayTimeout())
                .andExpect(jsonPath("$.title").value("Downstream Service Error"))
                .andExpect(jsonPath("$.detail").value("Downstream service did not respond in time."));

            assertThat(gemsRequests()).isEqualTo(1);
        }

        @Test
        @DisplayName("subscribe_connectionDropped_badGatewayAfterTwoRetries|HPCRAK8bc8Uf96B6IVp4|tests:2652")
        void subscribe_connectionDropped_badGatewayAfterTwoRetries() throws Exception {
            GEMS.enqueue(dropConnection());
            GEMS.enqueue(dropConnection());
            GEMS.enqueue(dropConnection());

            subscribe()
                .andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.title").value("Downstream Service Error"))
                .andExpect(jsonPath("$.detail").value("Downstream service could not be reached."));

            assertThat(gemsRequests()).isEqualTo(3);
        }

        @Test
        @DisplayName("subscribe_unavailableTwice_succeedsOnThirdAttempt|fMyMRGnY5dtG4Lb1pHVf|tests:2652")
        void subscribe_unavailableTwice_succeedsOnThirdAttempt() throws Exception {
            GEMS.enqueue(json(503, "{}"));
            GEMS.enqueue(json(503, "{}"));
            GEMS.enqueue(json(200, "{}"));

            subscribe().andExpect(status().isOk());

            assertThat(gemsRequests()).isEqualTo(3);
        }

        @Test
        @DisplayName("confirm_clientError_badGatewayWithoutRetry|MknCcnAddg9GOTHk6xaP|tests:2652")
        void confirm_clientError_badGatewayWithoutRetry() throws Exception {
            GEMS.enqueue(json(404, "{}"));

            mvc.perform(post(API_DEPARTURES + "/confirm/message-1/device-1"))
                .andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.detail").value("Downstream service responded with status 404."));

            assertThat(gemsRequests()).isEqualTo(1);
        }

        @Test
        @DisplayName("confirm_unavailableTwice_succeedsOnThirdAttempt|Mvm0kmdQUFSSEszACdRc|tests:2652")
        void confirm_unavailableTwice_succeedsOnThirdAttempt() throws Exception {
            GEMS.enqueue(json(503, "{}"));
            GEMS.enqueue(json(502, "{}"));
            GEMS.enqueue(json(200, "{}"));

            mvc.perform(post(API_DEPARTURES + "/confirm/message-1/device-1")).andExpect(status().isOk());

            assertThat(gemsRequests()).isEqualTo(3);
        }

        private ResultActions subscribe() throws Exception {
            return mvc.perform(post(API_DEPARTURES + "/subscribe")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {"messageId": "message-1", "zugnr": "1234", "deviceId": "device-1", "pushToken": "push", "evu": "1185", "type": "DEPARTURE", "driver": true}
                    """));
        }
    }

    @Nested
    @WithMockRole(roles = UserRole.SBB_CARGO)
    class Orca {

        @Test
        @DisplayName("transportPaper_readTimeout_gatewayTimeoutWithoutRetry|YXtFAYLTNR4OdJrxWYwF|tests:2652")
        void transportPaper_readTimeout_gatewayTimeoutWithoutRetry() throws Exception {
            ORCA.enqueue(slow());

            transportPaper()
                .andExpect(status().isGatewayTimeout())
                .andExpect(jsonPath("$.title").value("Downstream Service Error"));

            assertThat(orcaRequests()).isEqualTo(1);
        }

        @Test
        @DisplayName("transportPaper_connectionDropped_badGatewayAfterTwoRetries|LHhwtc19aF5iijGQ0lqS|tests:2652")
        void transportPaper_connectionDropped_badGatewayAfterTwoRetries() throws Exception {
            ORCA.enqueue(dropConnection());
            ORCA.enqueue(dropConnection());
            ORCA.enqueue(dropConnection());

            transportPaper()
                .andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.detail").value("Downstream service could not be reached."));

            assertThat(orcaRequests()).isEqualTo(3);
        }

        @Test
        @DisplayName("transportPaper_unavailableTwice_redirectsOnThirdAttempt|xd1OY3jW8ELiQJm4eFaL|tests:2652")
        void transportPaper_unavailableTwice_redirectsOnThirdAttempt() throws Exception {
            ORCA.enqueue(json(503, "{}"));
            ORCA.enqueue(json(503, "{}"));
            ORCA.enqueue(json(200, """
                {"downloadUrl": "https://signed.example.com/file.pdf"}
                """));

            transportPaper()
                .andExpect(status().isFound())
                .andExpect(header().string("Location", "https://signed.example.com/file.pdf"));

            assertThat(orcaRequests()).isEqualTo(3);
        }

        @Test
        @DisplayName("transportPaper_clientError_badGatewayWithoutRetry|Dzte2lMgKJlGaV2tQaHD|tests:2652")
        void transportPaper_clientError_badGatewayWithoutRetry() throws Exception {
            ORCA.enqueue(json(404, "{}"));

            transportPaper()
                .andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.detail").value("Downstream service responded with status 404."));

            assertThat(orcaRequests()).isEqualTo(1);
        }

        @Test
        @DisplayName("transportPaper_slowTokenEndpoint_gatewayTimeout|oqpIdfCvSekcDRcpx5CD|tests:2652")
        void transportPaper_slowTokenEndpoint_gatewayTimeout() throws Exception {
            tokenResponse = DownstreamResilienceIntegrationTest::slow;

            transportPaper()
                .andExpect(status().isGatewayTimeout())
                .andExpect(jsonPath("$.title").value("Downstream Service Error"));

            assertThat(tokenRequests()).isEqualTo(1);
            assertThat(orcaRequests()).isZero();
        }

        @Test
        @DisplayName("transportPaper_tokenRejected_badGateway|qfCvxIJfciq2EHF7OtO7|tests:2652")
        void transportPaper_tokenRejected_badGateway() throws Exception {
            tokenResponse = () -> json(400, """
                {"error": "invalid_client"}
                """);

            transportPaper()
                .andExpect(status().isBadGateway())
                .andExpect(jsonPath("$.detail").value("Downstream service could not be authorized."));

            assertThat(tokenRequests()).isEqualTo(1);
            assertThat(orcaRequests()).isZero();
        }

        private ResultActions transportPaper() throws Exception {
            return mvc.perform(get(API_TRANSPORT_PAPERS + "/33014-021/2026-01-30")
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"));
        }
    }

    @Nested
    @Sql("classpath:emptyTafTapLocations.sql")
    @WithMockUser(authorities = "ROLE_admin")
    class Atlas {

        @Autowired
        TafTapLocationsImportService importService;

        @Test
        @DisplayName("importLocations_pageReadTimeout_retriesAndImports|Cw4DW7LjLfEbfAkwvj6D|tests:2652")
        void importLocations_pageReadTimeout_retriesAndImports() throws Exception {
            ATLAS.enqueue(page("BN", 85, 7000));
            ATLAS.enqueue(slow());
            ATLAS.enqueue(page("OL", 85, 18));

            importService.importLocations();

            assertThat(atlasRequests()).isEqualTo(3);
            mvc.perform(get(API_LOCATIONS)).andExpect(jsonPath("$.data", hasSize(2)));
        }

        @Test
        @DisplayName("importLocations_pageUnavailableTwice_imports|41n47D7MfY1NH4Krol33|tests:2652")
        void importLocations_pageUnavailableTwice_imports() throws Exception {
            ATLAS.enqueue(page("BN", 85, 7000));
            ATLAS.enqueue(json(503, "{}"));
            ATLAS.enqueue(json(503, "{}"));
            ATLAS.enqueue(page("OL", 85, 18));

            importService.importLocations();

            assertThat(atlasRequests()).isEqualTo(4);
            mvc.perform(get(API_LOCATIONS)).andExpect(jsonPath("$.data", hasSize(2)));
        }

        @Test
        @DisplayName("importLocations_pageFailsFourTimes_importFails|ogLTWVNt1dV035fHMalR|tests:2652")
        void importLocations_pageFailsFourTimes_importFails() throws Exception {
            ATLAS.enqueue(page("BN", 85, 7000));
            ATLAS.enqueue(json(503, "{}"));
            ATLAS.enqueue(slow());
            ATLAS.enqueue(dropConnection());
            ATLAS.enqueue(json(503, "{}"));

            assertThatThrownBy(() -> importService.importLocations()).isInstanceOf(RuntimeException.class);

            assertThat(atlasRequests()).isEqualTo(5);
            mvc.perform(get(API_LOCATIONS)).andExpect(jsonPath("$.data", hasSize(0)));
        }

        /**
         * One service point per page, the total count spans two pages of the import.
         */
        private static MockResponse page(String abbreviation, int uicCountryCode, int numberShort) {
            return json(200, """
                {"totalCount": 2001, "objects": [{"designationOfficial": "%s", "abbreviation": "%s", "validFrom": "2020-01-01", "validTo": "9999-12-31",
                  "number": {"uicCountryCode": %d, "numberShort": %d, "checkDigit": 0}}]}
                """.formatted(abbreviation, abbreviation, uicCountryCode, numberShort));
        }
    }

    private int gemsRequests() {
        return GEMS.getRequestCount() - gemsRequestsBefore;
    }

    private int orcaRequests() {
        return ORCA.getRequestCount() - orcaRequestsBefore;
    }

    private int atlasRequests() {
        return ATLAS.getRequestCount() - atlasRequestsBefore;
    }

    private int tokenRequests() {
        return TOKEN.getRequestCount() - tokenRequestsBefore;
    }

    private static MockResponse json(int status, String body) {
        return new MockResponse.Builder().code(status).addHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE).body(body).build();
    }

    private static MockResponse slow() {
        return new MockResponse.Builder().code(200).headersDelay(SLOWER_THAN_READ_TIMEOUT_MS, TimeUnit.MILLISECONDS).build();
    }

    /**
     * Reads the request, then closes the connection without a response.
     */
    private static MockResponse dropConnection() {
        return new MockResponse.Builder().onResponseStart(SocketEffect.ShutdownConnection.INSTANCE).build();
    }

    /**
     * Answers an unexpected request with 404 instead of blocking.
     */
    private static QueueDispatcher failFastQueue() {
        final QueueDispatcher dispatcher = new QueueDispatcher();
        dispatcher.setFailFast(true);
        return dispatcher;
    }

    private static String baseUrl(MockWebServer server) {
        return "http://" + server.getHostName() + ":" + server.getPort();
    }

    private static MockWebServer start() {
        final MockWebServer server = new MockWebServer();
        try {
            server.start();
        } catch (java.io.IOException e) {
            throw new IllegalStateException(e);
        }
        return server;
    }
}
