package ch.sbb.das.backend.admin.application.settings;

import static ch.sbb.das.backend.admin.application.settings.AppVersionController.API_SETTINGS_APP_VERSION;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.context.jdbc.SqlMergeMode.MergeMode.MERGE;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.common.security.UserRole;
import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyAppVersions.sql")
@SqlMergeMode(MERGE)
class AppVersionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAll_AppVersions_empty() throws Exception {
        mockMvc.perform(get(API_SETTINGS_APP_VERSION))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAppVersionById_not_found() throws Exception {
        int nonExistingId = Integer.MAX_VALUE;
        mockMvc.perform(get(API_SETTINGS_APP_VERSION + "/" + nonExistingId))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void getById_AppVersion_by_id() throws Exception {
        mockMvc.perform(get(API_SETTINGS_APP_VERSION + "/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].version").value("2.4.1"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(false))
            .andExpect(jsonPath("$.data[0].expiryDate").value("2026-12-31"))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_ok() throws Exception {
        String jsonResult = mockMvc.perform(post(API_SETTINGS_APP_VERSION)
                .contentType("application/json")
                .content("""
                    {
                        "version": "1.6.3",
                        "minimalVersion": true,
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").isNumber())
            .andExpect(jsonPath("$.data[0].version").value("1.6.3"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(true))
            .andExpect(jsonPath("$.data[0].expiryDate").isEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"))
            .andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(jsonResult, "$.data[0].id");

        mockMvc.perform(get(API_SETTINGS_APP_VERSION + "/" + id))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").isNumber())
            .andExpect(jsonPath("$.data[0].version").value("1.6.3"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(true))
            .andExpect(jsonPath("$.data[0].expiryDate").isEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_invalid_body() throws Exception {
        mockMvc.perform(post(API_SETTINGS_APP_VERSION)
                .contentType("application/json")
                .content("""
                    {
                        "version": "1.6.3",
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> minimalVersion=must not be null"));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void create_AppVersion_conflict_version() throws Exception {
        mockMvc.perform(post(API_SETTINGS_APP_VERSION)
                .contentType("application/json")
                .content("""
                    {
                        "version": "2.1.0",
                        "minimalVersion": true,
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail").value("Version already exists"));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void update_AppVersion_ok() throws Exception {
        mockMvc.perform(put(API_SETTINGS_APP_VERSION + "/1")
                .contentType("application/json")
                .content("""
                        {
                            "version": "2.5.0",
                            "minimalVersion": true,
                            "expiryDate": "2026-01-01"
                        }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].version").value("2.5.0"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(true))
            .andExpect(jsonPath("$.data[0].expiryDate").value("2026-01-01"))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));

        mockMvc.perform(get(API_SETTINGS_APP_VERSION + "/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].version").value("2.5.0"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(true))
            .andExpect(jsonPath("$.data[0].expiryDate").value("2026-01-01"))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void delete_AppVersionById_ok() throws Exception {
        mockMvc.perform(delete(API_SETTINGS_APP_VERSION + "/1"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_SETTINGS_APP_VERSION + "/1"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN, adminTenant = false)
    void create_AppVersion_forbidden() throws Exception {
        mockMvc.perform(post(API_SETTINGS_APP_VERSION)
                .contentType("application/json")
                .content("""
                    {
                        "version": "1.6.3",
                        "minimalVersion": true,
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isForbidden());
    }
}
