package ch.sbb.das.backend.admin.application.ruindications;

import static ch.sbb.das.backend.admin.application.ruindications.SpecialHolidayController.API_SPECIAL_HOLIDAYS;
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
import java.time.LocalDate;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptySpecialHolidays.sql")
@SqlMergeMode(MERGE)
class SpecialHolidayControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createSpecialHolidays.sql")
    void getAllUpcomingSpecialHolidays_ok() throws Exception {
        mockMvc.perform(get(API_SPECIAL_HOLIDAYS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[0].id").value(2))
            .andExpect(jsonPath("$.data[0].name").value("Berchtoldstag"))
            .andExpect(jsonPath("$.data[0].date").value("2099-01-02"))
            .andExpect(jsonPath("$.data[0].scheduleType").value("MONDAY_SCHEDULE"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("3333")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAllUpcomingSpecialHolidays_forbidden_role() throws Exception {
        mockMvc.perform(get(API_SPECIAL_HOLIDAYS))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAllUpcomingSpecialHolidays_empty() throws Exception {
        mockMvc.perform(get(API_SPECIAL_HOLIDAYS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAllUpcomingSpecialHolidays_includesTodayBoundary() throws Exception {
        String today = LocalDate.now().toString();

        mockMvc.perform(post(API_SPECIAL_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "name": "Today Holiday",
                        "date": "%s",
                        "scheduleType": "SUNDAY_SCHEDULE",
                        "companies": ["1111"]
                    }
                    """.formatted(today)))
            .andExpect(status().isCreated());

        mockMvc.perform(get(API_SPECIAL_HOLIDAYS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].name").value("Today Holiday"))
            .andExpect(jsonPath("$.data[0].date").value(today))
            .andExpect(jsonPath("$.data[0].scheduleType").value("SUNDAY_SCHEDULE"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createSpecialHolidays.sql")
    void getSpecialHolidayById_ok() throws Exception {
        mockMvc.perform(get(API_SPECIAL_HOLIDAYS + "/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].name").value("National Day"))
            .andExpect(jsonPath("$.data[0].date").value("2099-08-01"))
            .andExpect(jsonPath("$.data[0].scheduleType").value("SUNDAY_SCHEDULE"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getSpecialHolidayById_notFound() throws Exception {
        mockMvc.perform(get(API_SPECIAL_HOLIDAYS + "/99"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createSpecialHolidays.sql")
    void getSpecialHolidayById_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(get(API_SPECIAL_HOLIDAYS + "/3"))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_SpecialHoliday_ok() throws Exception {
        mockMvc.perform(post(API_SPECIAL_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "name": "Sechseläuten",
                        "date": "2026-04-20",
                        "scheduleType": "MONDAY_SCHEDULE",
                        "companies": ["1111", "2222"]
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].name").value("Sechseläuten"))
            .andExpect(jsonPath("$.data[0].date").value("2026-04-20"))
            .andExpect(jsonPath("$.data[0].scheduleType").value("MONDAY_SCHEDULE"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_SpecialHoliday_invalid_unknownCompany() throws Exception {
        mockMvc.perform(post(API_SPECIAL_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "name": "Invalid Holiday",
                        "date": "2026-04-20",
                        "scheduleType": "SUNDAY_SCHEDULE",
                        "companies": ["1234"]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_SpecialHoliday_invalid_emptyCompanies() throws Exception {
        mockMvc.perform(post(API_SPECIAL_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "name": "Invalid Holiday",
                        "date": "2026-04-20",
                        "scheduleType": "SUNDAY_SCHEDULE",
                        "companies": []
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> companies=must not be empty"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createSpecialHolidays.sql")
    void update_SpecialHoliday_ok() throws Exception {
        mockMvc.perform(put(API_SPECIAL_HOLIDAYS + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "name": "Updated Holiday",
                        "date": "2026-12-12",
                        "scheduleType": "MONDAY_SCHEDULE",
                        "companies": [ "3333", "1111" ]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].name").value("Updated Holiday"))
            .andExpect(jsonPath("$.data[0].date").value("2026-12-12"))
            .andExpect(jsonPath("$.data[0].scheduleType").value("MONDAY_SCHEDULE"))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("3333", "1111")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_SpecialHoliday_notFound() throws Exception {
        mockMvc.perform(put(API_SPECIAL_HOLIDAYS + "/99")
                .contentType("application/json")
                .content("""
                    {
                        "name": "Updated Holiday",
                        "date": "2026-12-12",
                        "scheduleType": "MONDAY_SCHEDULE",
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createSpecialHolidays.sql")
    void update_SpecialHoliday_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(put(API_SPECIAL_HOLIDAYS + "/3")
                .contentType("application/json")
                .content("""
                    {
                        "name": "Updated Holiday",
                        "date": "2026-12-12",
                        "scheduleType": "MONDAY_SCHEDULE",
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createSpecialHolidays.sql")
    void deleteSpecialHolidayBatch_ok() throws Exception {
        mockMvc.perform(delete(API_SPECIAL_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "ids": [1, 1, 2]
                    }
                    """))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_SPECIAL_HOLIDAYS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createSpecialHolidays.sql")
    void deleteSpecialHolidayBatch_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(delete(API_SPECIAL_HOLIDAYS)
                .contentType("application/json")
                .content("""
                    {
                        "ids": [1, 3]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }
}

