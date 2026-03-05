package ch.sbb.backend.proxy.api.v1;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.backend.proxy.CustomerOrientedDepartureController;
import ch.sbb.backend.proxy.ProxyClient;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(CustomerOrientedDepartureController.class)
@AutoConfigureMockMvc(addFilters = false)
class CustomerOrientedDepartureControllerTest {

    @Autowired
    MockMvc mvc;

    @MockitoBean
    ProxyClient proxyClient;

    @Test
    void subscribe_delegatesToClient() throws Exception {
        when(proxyClient.subscribe(any())).thenReturn(ResponseEntity.noContent().build());

        mvc.perform(post("/v1/customer-oriented-departure/subscribe")
                .contentType("application/json")
                .content("""
                    {
                      "messageId":"m1",
                      "zugnr":"123",
                      "deviceId":"d1",
                      "pushToken":"t1",
                      "expired":"2026-03-03T12:34:56Z",
                      "evu":"DAS",
                      "type":"REGISTER"
                    }
                    """))
            .andExpect(status().isNoContent());

        verify(proxyClient).subscribe(any());
    }

    @Test
    void confirm_delegatesToClient() throws Exception {
        when(proxyClient.confirm("m1", "d1")).thenReturn(ResponseEntity.noContent().build());

        mvc.perform(post("/v1/customer-oriented-departure/confirm/m1/d1"))
            .andExpect(status().isNoContent());

        verify(proxyClient).confirm("m1", "d1");
    }
}
