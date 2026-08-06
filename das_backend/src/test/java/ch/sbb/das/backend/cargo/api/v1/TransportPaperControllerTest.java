package ch.sbb.das.backend.cargo.api.v1;

import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.API_TRANSPORT_PAPERS;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.cargo.infrastructure.SbbchTransportPaperClient;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import java.time.LocalDate;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.client.RestClientResponseException;

@WebMvcTest(TransportPaperController.class)
@AutoConfigureMockMvc(addFilters = false)
class TransportPaperControllerTest {

    @Autowired
    MockMvc mvc;

    @MockitoBean
    SbbchTransportPaperClient sbbChTransportPaperClient;

    @MockitoBean
    CompanyAuthorizer companyAuthorizer;

    @Test
    @DisplayName("resolveTransportPaperUrl_redirectsToDownstreamUrl|TcnjHbl7cP6l3Z78ibn2|tests:1619")
    void resolveTransportPaperUrl_redirectsToDownstreamUrl() throws Exception {
        when(sbbChTransportPaperClient.getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0))
            .thenReturn("https://signed.example.com/file.pdf");

        mvc.perform(get(API_TRANSPORT_PAPERS + "/33014-021/2026-01-30")
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"))
            .andExpect(status().isFound())
            .andExpect(header().string("Location", "https://signed.example.com/file.pdf"));

        verify(sbbChTransportPaperClient).getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0);
    }

    @Test
    @DisplayName("resolveTransportPaperUrl_downstreamError_returnsBadGateway|oVNcNGHdz5TMx41g7VnS|tests:1619")
    void resolveTransportPaperUrl_downstreamError_returnsBadGateway() throws Exception {
        when(sbbChTransportPaperClient.getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0))
            .thenThrow(new RestClientResponseException("Message", 404, "Not found", null, "no paper".getBytes(), null));

        mvc.perform(get(API_TRANSPORT_PAPERS + "/33014-021/2026-01-30")
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"))
            .andExpect(status().isBadGateway())
            .andExpect(jsonPath("$.title").value("Downstream Service Error"))
            .andExpect(jsonPath("$.detail").value("404: no paper"));

        verify(sbbChTransportPaperClient).getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0);
    }
}
