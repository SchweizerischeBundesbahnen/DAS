package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import static ch.sbb.das.backend.trainjourneyplan.infrastructure.TrainIdentificationController.API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.common.security.UserRole;
import java.time.LocalDate;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql({"classpath:createCompaniesAndTenants.sql", "classpath:createTrainIdentifications.sql"})
class TrainIdentificationControllerTest {

    private static final LocalDate TODAY = DateTimeUtil.today();
    private static final LocalDate TOMORROW = TODAY.plusDays(1);

    @Autowired
    private MockMvc mockMvc;

    @DisplayName("getCompanies_returnsCompaniesForTrainOnDate|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_returnsCompaniesForTrainOnDate() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[*].company.code", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[*].company.shortName", containsInAnyOrder("MOCK_A", "MOCK_B")))
            .andExpect(jsonPath("$.data[*].startDate", containsInAnyOrder(TODAY.toString(), TODAY.toString())));
    }

    @DisplayName("getCompanies_differentDate_returnsDifferentCompanies|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_differentDate_returnsDifferentCompanies() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TOMORROW.toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].company.code").value("3333"))
            .andExpect(jsonPath("$.data[0].company.shortName").value("MOCK_C"))
            .andExpect(jsonPath("$.data[0].startDate").value(TOMORROW.toString()));
    }

    @DisplayName("getCompanies_multipleDates_returnsCompaniesWithMatchingStartDate|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_multipleDates_returnsCompaniesWithMatchingStartDate() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString())
                .param("startDate", TOMORROW.toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[*].company.code", containsInAnyOrder("1111", "2222", "3333")))
            .andExpect(jsonPath("$.data[*].startDate", containsInAnyOrder(TODAY.toString(), TODAY.toString(), TOMORROW.toString())));
    }

    @DisplayName("getCompanies_noMatch_returns404|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_noMatch_returns404() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString())
                .param("operationalTrainNumber", "123"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("getCompanies_noMatchOnDate_returns404|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_noMatchOnDate_returns404() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.minusDays(1).toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("getCompanies_observerRole_isAllowed|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getCompanies_observerRole_isAllowed() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk());
    }

    @DisplayName("getCompanies_unauthenticated_returns401|tests:2136")
    @Test
    void getCompanies_unauthenticated_returns401() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isUnauthorized());
    }

    @DisplayName("getCompanies_missingstartDate_returns400|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_missingstartDate_returns400() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("getCompanies_startDateOutOfRange_returns400|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_startDateOutOfRange_returns400() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.minusDays(2).toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("getCompanies_missingTrainNumber_returns400|tests:2136")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_missingTrainNumber_returns400() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString()))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("getCompanies_singleEntityWithMultipleCompanies_returnsAllCompaniesFromEntity|tests:2136,2271")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_singleEntityWithMultipleCompanies_returnsAllCompaniesFromEntity() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString())
                .param("operationalTrainNumber", "728"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[*].company.code", containsInAnyOrder("1111", "2222")));
    }

    @DisplayName("getCompanies_onlyReturnsCompaniesStoredInCompaniesTable|tests:2136,2271")
    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void getCompanies_onlyReturnsCompaniesStoredInCompaniesTable() throws Exception {
        mockMvc.perform(get(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
                .param("startDate", TODAY.toString())
                .param("operationalTrainNumber", "555"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].company.code").value("1111"))
            .andExpect(jsonPath("$.data[0].company.shortName").value("MOCK_A"));
    }
}
