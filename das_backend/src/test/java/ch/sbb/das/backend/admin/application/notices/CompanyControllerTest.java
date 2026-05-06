package ch.sbb.das.backend.admin.application.notices;

import static ch.sbb.das.backend.tenancy.application.CompanyController.API_COMPANIES;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.admin.application.settings.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
class CompanyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_ok_adminTenant_returnsAllowedCompanies() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[*].code", containsInAnyOrder("1111", "2222", "3333")))
            .andExpect(jsonPath("$.data[*].name", containsInAnyOrder("MOCK_A", "MOCK_B", "MOCK_C")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN, adminTenant = false)
    void getAll_ok_otherTenant_returnsOwnCompanies() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].code").value("9999"))
            .andExpect(jsonPath("$.data[0].name").value("MOCK_OTHER"));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAll_forbidden_role() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isForbidden());
    }
}
