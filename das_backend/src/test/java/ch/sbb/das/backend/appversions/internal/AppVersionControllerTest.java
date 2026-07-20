package ch.sbb.das.backend.appversions.internal;

import static ch.sbb.das.backend.appversions.internal.AppVersionController.API_APP_VERSIONS;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.context.jdbc.SqlMergeMode.MergeMode.MERGE;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.DisplayName;
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

    @DisplayName("Get all app versions - empty|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAll_AppVersions_empty() throws Exception {
        mockMvc.perform(get(API_APP_VERSIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @DisplayName("Get app version by id - not found|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAppVersionById_not_found() throws Exception {
        int nonExistingId = Integer.MAX_VALUE;
        mockMvc.perform(get(API_APP_VERSIONS + "/" + nonExistingId))
            .andExpect(status().isNotFound());
    }

    @DisplayName("Get by id - app version by id|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void getById_AppVersion_by_id() throws Exception {
        mockMvc.perform(get(API_APP_VERSIONS + "/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].version").value("2.4.1"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(false))
            .andExpect(jsonPath("$.data[0].expiryDate").value("2026-12-31"))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @DisplayName("Create app version - ok|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_ok() throws Exception {
        String jsonResult = mockMvc.perform(post(API_APP_VERSIONS)
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

        mockMvc.perform(get(API_APP_VERSIONS + "/" + id))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").isNumber())
            .andExpect(jsonPath("$.data[0].version").value("1.6.3"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(true))
            .andExpect(jsonPath("$.data[0].expiryDate").isEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @DisplayName("Create app version - invalid body|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_invalid_body() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS)
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

    @DisplayName("Create app version - invalid version pattern|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_invalid_version_pattern() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS)
                .contentType("application/json")
                .content("""
                    {
                        "version": "invalid",
                        "minimalVersion": false,
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> version=must match \"(\\d+)\\.(\\d+)\\.(\\d+)\""));
    }

    @DisplayName("Create app version - conflict version|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void create_AppVersion_conflict_version() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS)
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

    @DisplayName("Update app version - ok|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void update_AppVersion_ok() throws Exception {
        mockMvc.perform(put(API_APP_VERSIONS + "/1")
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

        mockMvc.perform(get(API_APP_VERSIONS + "/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].version").value("2.5.0"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(true))
            .andExpect(jsonPath("$.data[0].expiryDate").value("2026-01-01"))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @DisplayName("Delete app version by id - ok|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void delete_AppVersionById_ok() throws Exception {
        mockMvc.perform(delete(API_APP_VERSIONS + "/1"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_APP_VERSIONS + "/1"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("Create app version - forbidden")
    @Test
    @WithMockRole(roles = UserRole.ADMIN, adminTenant = false)
    void create_AppVersion_forbidden() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS)
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
