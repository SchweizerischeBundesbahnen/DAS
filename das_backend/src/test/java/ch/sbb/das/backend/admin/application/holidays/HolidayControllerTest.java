package ch.sbb.das.backend.admin.application.holidays;

import static ch.sbb.das.backend.admin.application.holidays.HolidayController.API_HOLIDAYS;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.context.jdbc.SqlMergeMode.MergeMode.MERGE;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.admin.application.settings.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyHolidays.sql")
@SqlMergeMode(MERGE)
class HolidayControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createHolidays.sql")
    void getAll_ok() throws Exception {
        mockMvc.perform(get(API_HOLIDAYS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].name").value("National Day"))
            .andExpect(jsonPath("$.data[0].validAt").value("2026-08-01"))
            .andExpect(jsonPath("$.data[0].type").value("SUNDAY"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAll_forbidden_role() throws Exception {
        mockMvc.perform(get(API_HOLIDAYS))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_empty() throws Exception {
        mockMvc.perform(get(API_HOLIDAYS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createHolidays.sql")
    void getById_ok() throws Exception {
        mockMvc.perform(get(API_HOLIDAYS + "/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].name").value("National Day"))
            .andExpect(jsonPath("$.data[0].validAt").value("2026-08-01"))
            .andExpect(jsonPath("$.data[0].type").value("SUNDAY"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getById_notFound() throws Exception {
        mockMvc.perform(get(API_HOLIDAYS + "/99"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_ok() throws Exception {
        mockMvc.perform(post(API_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "name": "Sechseläuten",
                        "validAt": "2026-04-20",
                        "type": "MONDAY",
                        "companies": ["1111", "2222"]
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].name").value("Sechseläuten"))
            .andExpect(jsonPath("$.data[0].validAt").value("2026-04-20"))
            .andExpect(jsonPath("$.data[0].type").value("MONDAY"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_invalid_unknownCompany() throws Exception {
        mockMvc.perform(post(API_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "name": "Invalid Holiday",
                        "validAt": "2026-04-20",
                        "type": "SUNDAY",
                        "companies": ["1234"]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_invalid_emptyCompanies() throws Exception {
        mockMvc.perform(post(API_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "name": "Invalid Holiday",
                        "validAt": "2026-04-20",
                        "type": "SUNDAY",
                        "companies": []
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> companies=must not be empty"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createHolidays.sql")
    void update_ok() throws Exception {
        mockMvc.perform(put(API_HOLIDAYS + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "name": "Updated Holiday",
                        "validAt": "2026-12-12",
                        "type": "MONDAY",
                        "companies": [ "3333", "1111" ]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].name").value("Updated Holiday"))
            .andExpect(jsonPath("$.data[0].validAt").value("2026-12-12"))
            .andExpect(jsonPath("$.data[0].type").value("MONDAY"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("3333", "1111")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_notFound() throws Exception {
        mockMvc.perform(put(API_HOLIDAYS + "/99")
                .contentType("application/json")
                .content("""
                    {
                        "name": "Updated Holiday",
                        "validAt": "2026-12-12",
                        "type": "MONDAY",
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createHolidays.sql")
    void deleteById_ok() throws Exception {
        mockMvc.perform(delete(API_HOLIDAYS + "/1"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_HOLIDAYS + "/1"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createHolidays.sql")
    void deleteBatch_ok() throws Exception {
        mockMvc.perform(delete(API_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "ids": [1, 1, 2]
                    }
                    """))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_HOLIDAYS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(3));
    }
}

