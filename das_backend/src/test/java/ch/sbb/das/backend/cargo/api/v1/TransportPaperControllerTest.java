package ch.sbb.das.backend.cargo.api.v1;

import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.API_TRANSPORT_PAPERS;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.cargo.infrastructure.TransportPaperClient;
import ch.sbb.das.backend.common.security.UserRole;
import java.time.LocalDate;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.client.RestClientResponseException;

@IntegrationTest
class TransportPaperControllerTest {

    private static final String SAMPLE_PATH = API_TRANSPORT_PAPERS + "/33014-021/2026-01-30";

    @Autowired
    MockMvc mvc;

    @MockitoBean
    TransportPaperClient transportPaperClient;

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO)
    @DisplayName("resolveTransportPaperUrl_redirectsToDownstreamUrl|TcnjHbl7cP6l3Z78ibn2|tests:1619")
    void resolveTransportPaperUrl_redirectsToDownstreamUrl() throws Exception {
        when(transportPaperClient.getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0))
            .thenReturn("https://signed.example.com/file.pdf");

        mvc.perform(get(SAMPLE_PATH)
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"))
            .andExpect(status().isFound())
            .andExpect(header().string("Location", "https://signed.example.com/file.pdf"));

        verify(transportPaperClient).getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0);
    }

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO)
    @DisplayName("resolveTransportPaperUrl_downstreamError_returnsBadGateway|oVNcNGHdz5TMx41g7VnS|tests:1619")
    void resolveTransportPaperUrl_downstreamError_returnsBadGateway() throws Exception {
        when(transportPaperClient.getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0))
            .thenThrow(new RestClientResponseException("Message", 404, "Not found", null, "no paper".getBytes(), null));

        mvc.perform(get(SAMPLE_PATH)
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"))
            .andExpect(status().isBadGateway())
            .andExpect(jsonPath("$.title").value("Downstream Service Error"))
            .andExpect(jsonPath("$.detail").value("404: no paper"));

        verify(transportPaperClient).getDownloadUrl("33014-021", LocalDate.of(2026, 1, 30), "CH", 22137, 0);
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @DisplayName("resolveTransportPaperUrl_withObserverRole_isForbidden|nta3SCE8TffWi16cqNQ4|tests:1619")
    void resolveTransportPaperUrl_withObserverRole_isForbidden() throws Exception {
        mvc.perform(get(SAMPLE_PATH)
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO, adminTenant = false)
    @DisplayName("resolveTransportPaperUrl_withNonSbbTenant_isForbidden|1xtsjafxtW2wjvd2Ynuh|tests:1619")
    void resolveTransportPaperUrl_withNonSbbTenant_isForbidden() throws Exception {
        mvc.perform(get(SAMPLE_PATH)
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"))
            .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("resolveTransportPaperUrl_unauthenticated_isUnauthorized|lGxweY8MFboUcE5lQxjQ|tests:1619")
    void resolveTransportPaperUrl_unauthenticated_isUnauthorized() throws Exception {
        mvc.perform(get(SAMPLE_PATH)
                .param("countryCodeIso", "CH")
                .param("locationPrimaryCode", "22137")
                .param("passIndex", "0"))
            .andExpect(status().isUnauthorized());
    }
}
