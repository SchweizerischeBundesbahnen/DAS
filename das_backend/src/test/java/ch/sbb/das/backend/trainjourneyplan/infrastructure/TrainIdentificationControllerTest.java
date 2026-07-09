package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import static ch.sbb.das.backend.trainjourneyplan.infrastructure.TrainIdentificationController.API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql({"classpath:createCompaniesAndTenants.sql", "classpath:createTrainIdentifications.sql"})
class TrainIdentificationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_returnsCompaniesForTrainOnDate() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[*].code", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[*].shortName", containsInAnyOrder("MOCK_A", "MOCK_B")));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_differentDate_returnsDifferentCompanies() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-16")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].code").value("3333"))
            .andExpect(jsonPath("$.data[0].shortName").value("MOCK_C"));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_noMatch_returns404() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("operationalTrainNumber", "000"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_noMatchOnDate_returns404() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-07-01")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getCompanies_observerRole_isAllowed() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk());
    }

    @Test
    void getCompanies_unauthenticated_returns401() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_missingStartDate_returns400() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_missingTrainNumber_returns400() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15"))
            .andExpect(status().isBadRequest());
    }
}
