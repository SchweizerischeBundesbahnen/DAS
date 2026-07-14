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
            .andExpect(jsonPath("$.data[*].company.code", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[*].company.shortName", containsInAnyOrder("MOCK_A", "MOCK_B")))
            .andExpect(jsonPath("$.data[*].startDate", containsInAnyOrder("2025-06-15", "2025-06-15")));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_differentDate_returnsDifferentCompanies() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-16")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].company.code").value("3333"))
            .andExpect(jsonPath("$.data[0].company.shortName").value("MOCK_C"))
            .andExpect(jsonPath("$.data[0].startDate").value("2025-06-16"));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_multipleDates_returnsCompaniesWithMatchingStartDate() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("startDate", "2025-06-16")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[*].company.code", containsInAnyOrder("1111", "2222", "3333")))
            .andExpect(jsonPath("$.data[*].startDate", containsInAnyOrder("2025-06-15", "2025-06-15", "2025-06-16")));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_noMatch_returns404() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("operationalTrainNumber", "123"))
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
    void getCompanies_missingstartDate_returns400() throws Exception {
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

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_singleEntityWithMultipleCompanies_returnsAllCompaniesFromEntity() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[*].company.code", containsInAnyOrder("1111", "2222")));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_onlyReturnsCompaniesStoredInCompaniesTable() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", "2025-06-15")
                .param("operationalTrainNumber", "555"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].company.code").value("1111"))
            .andExpect(jsonPath("$.data[0].company.shortName").value("MOCK_A"));
    }
}
