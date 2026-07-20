package ch.sbb.das.backend.locations.internal;

import static ch.sbb.das.backend.locations.internal.TafTapLocationController.API_LOCATIONS;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:createTafTapLocations.sql")
class TafTapLocationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAllLocations_ok_admin_returnsAllLocationsAndHeaders() throws Exception {

        mockMvc.perform(get(API_LOCATIONS))
            .andExpect(status().isOk())
            .andExpect(header().string(HttpHeaders.CACHE_CONTROL, "public, max-age=86400"))
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[*].locationReference", containsInAnyOrder("CH07000", "CH08000", "IT09000")))
            .andExpect(jsonPath("$.data[*].primaryLocationName", containsInAnyOrder("Bern", "Zurich", "Milano")))
            .andExpect(jsonPath("$.data[*].locationAbbreviation", containsInAnyOrder("BN", "ZH", null)))
            .andExpect(jsonPath("$.data[*].validFrom", containsInAnyOrder(null, "2099-01-01", null)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAllLocations_ok_ruAdmin_returnsAllLocations() throws Exception {
        mockMvc.perform(get(API_LOCATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAllLocations_forbidden_observer() throws Exception {
        mockMvc.perform(get(API_LOCATIONS))
            .andExpect(status().isForbidden());
    }

    @Test
    void getAllLocations_unauthorized() throws Exception {
        mockMvc.perform(get(API_LOCATIONS))
            .andExpect(status().isUnauthorized());
    }
}
