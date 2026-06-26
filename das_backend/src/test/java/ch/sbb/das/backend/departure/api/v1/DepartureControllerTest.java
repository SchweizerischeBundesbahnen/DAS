package ch.sbb.das.backend.departure.api.v1;

import static ch.sbb.das.backend.departure.internal.DepartureController.API_CUSTOMER_ORIENTED_DEPARTURE;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.departure.internal.DepartureController;
import ch.sbb.das.backend.departure.internal.DepartureRestClient;
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
    DepartureRestClient departureRestClient;

    @Test
    void subscribe_delegatesToClient() throws Exception {
        when(departureRestClient.subscribe(any())).thenReturn(ResponseEntity.noContent().build());

        mvc.perform(post(API_CUSTOMER_ORIENTED_DEPARTURE + "/subscribe")
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

        verify(departureRestClient).subscribe(any());
    }

    @Test
    void confirm_delegatesToClient() throws Exception {
        when(departureRestClient.confirm("m1", "d1")).thenReturn(ResponseEntity.noContent().build());

        mvc.perform(post(API_CUSTOMER_ORIENTED_DEPARTURE + "/confirm/m1/d1"))
            .andExpect(status().isNoContent());

        verify(departureRestClient).confirm("m1", "d1");
    }

    @Test
    void confirm_error502() throws Exception {
        when(departureRestClient.confirm("m1", "d1")).thenThrow(new RestClientResponseException("Message", 400, "Bad request", null, "Validation error".getBytes(), null));

        mvc.perform(post(API_CUSTOMER_ORIENTED_DEPARTURE + "/confirm/m1/d1"))
            .andExpect(status().isBadGateway())
            .andExpect(jsonPath("$.title").value("Downstream Service Error"))
            .andExpect(jsonPath("$.detail").value("400: Validation error"));

        verify(departureRestClient).confirm("m1", "d1");
    }
}
