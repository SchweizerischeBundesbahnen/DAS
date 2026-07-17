package ch.sbb.das.backend.departure.api.v1;

import static ch.sbb.das.backend.departures.internal.DepartureController.API_DEPARTURES;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.departures.internal.DepartureController;
import ch.sbb.das.backend.departures.internal.GemsRestClient;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.client.RestClientResponseException;

@WebMvcTest(DepartureController.class)
@AutoConfigureMockMvc(addFilters = false)
class DepartureControllerTest {

    @Autowired
    MockMvc mvc;

    @MockitoBean
    GemsRestClient gemsRestClient;

    @DisplayName("subscribe - delegates to client|tests:1538")
    @Test
    void subscribe_delegatesToClient() throws Exception {
        when(gemsRestClient.subscribe(any())).thenReturn(ResponseEntity.noContent().build());

        mvc.perform(post(API_DEPARTURES + "/subscribe")
                .contentType("application/json")
                .content("""
                    {
                      "messageId":"m1",
                      "zugnr":"123",
                      "deviceId":"d1",
                      "pushToken":"t1",
                      "expiresAt":"2026-03-03T12:34:56Z",
                      "evu":"DAS",
                      "type":"REGISTER",
                      "driver": false
                    }
                    """))
            .andExpect(status().isNoContent());

        verify(gemsRestClient).subscribe(any());
    }

    @DisplayName("confirm - delegates to client|tests:1538")
    @Test
    void confirm_delegatesToClient() throws Exception {
        when(gemsRestClient.confirm("m1", "d1")).thenReturn(ResponseEntity.noContent().build());

        mvc.perform(post(API_DEPARTURES + "/confirm/m1/d1"))
            .andExpect(status().isNoContent());

        verify(gemsRestClient).confirm("m1", "d1");
    }

    @DisplayName("confirm - error 502|tests:1538")
    @Test
    void confirm_error502() throws Exception {
        when(gemsRestClient.confirm("m1", "d1")).thenThrow(new RestClientResponseException("Message", 400, "Bad request", null, "Validation error".getBytes(), null));

        mvc.perform(post(API_DEPARTURES + "/confirm/m1/d1"))
            .andExpect(status().isBadGateway())
            .andExpect(jsonPath("$.title").value("Downstream Service Error"))
            .andExpect(jsonPath("$.detail").value("400: Validation error"));

        verify(gemsRestClient).confirm("m1", "d1");
    }
}
