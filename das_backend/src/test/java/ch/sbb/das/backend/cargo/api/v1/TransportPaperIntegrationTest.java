package ch.sbb.das.backend.cargo.api.v1;

import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.API_TRANSPORT_PAPERS;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
class TransportPaperIntegrationTest {

    private static final String SAMPLE_PATH = API_TRANSPORT_PAPERS + "/33014-021/2026-01-30"
        + "?countryCodeIso=CH&locationPrimaryCode=22137&passIndex=0";

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO)
    @DisplayName("resolveTransportPaperUrl_withSbbCargoRoleAndSbbTenant_isAllowed|Zz0zQhRZrPyjAoV6sq5P|tests:1619")
    void resolveTransportPaperUrl_withSbbCargoRoleAndSbbTenant_isAllowed() throws Exception {
        // downstream call will fail (no mock), but security should pass → not 403/401
        mockMvc.perform(get(SAMPLE_PATH))
            .andExpect(result -> {
                int status = result.getResponse().getStatus();
                if (status == 401 || status == 403) {
                    throw new AssertionError("Expected access to be granted but got HTTP " + status);
                }
            });
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @DisplayName("resolveTransportPaperUrl_withObserverRole_isForbidden|nta3SCE8TffWi16cqNQ4|tests:1619")
    void resolveTransportPaperUrl_withObserverRole_isForbidden() throws Exception {
        mockMvc.perform(get(SAMPLE_PATH))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO, adminTenant = false)
    @DisplayName("resolveTransportPaperUrl_withNonSbbTenant_isForbidden|1xtsjafxtW2wjvd2Ynuh|tests:")
    void resolveTransportPaperUrl_withNonSbbTenant_isForbidden() throws Exception {
        mockMvc.perform(get(SAMPLE_PATH))
            .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("resolveTransportPaperUrl_unauthenticated_isUnauthorized|lGxweY8MFboUcE5lQxjQ|tests:")
    void resolveTransportPaperUrl_unauthenticated_isUnauthorized() throws Exception {
        mockMvc.perform(get(SAMPLE_PATH))
            .andExpect(status().isUnauthorized());
    }
}
