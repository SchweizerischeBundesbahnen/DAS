package ch.sbb.das.backend.appversions.internal;

import static ch.sbb.das.backend.appversions.internal.AppVersionController.API_APP_VERSIONS;
import static ch.sbb.das.backend.appversions.internal.SemanticVersion.SEM_VERSION_PATTERN;
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
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
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

    @DisplayName("getAll_AppVersions_empty|xG2bVNt0GZxQYXIHrnyz|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAll_AppVersions_empty() throws Exception {
        mockMvc.perform(get(API_APP_VERSIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @DisplayName("getAppVersionById_not_found|VCGPshM6DaS949DRTOd1|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAppVersionById_not_found() throws Exception {
        int nonExistingId = Integer.MAX_VALUE;
        mockMvc.perform(get(API_APP_VERSIONS + "/" + nonExistingId))
            .andExpect(status().isNotFound());
    }

    @DisplayName("getById_AppVersion_by_id|4uKIx7BmDPkJnaGrkLUV|tests:1406")
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

    @DisplayName("create_AppVersion_ok|dnAz9lqr69vHloJHrBUW|tests:1406")
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

    @DisplayName("create_AppVersion_invalid_body|S2nQl87ymrIdMrk98IHl|tests:1406")
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

    @DisplayName("create_AppVersion_invalid_version_pattern|Ke5RmTbFnC9WZgcEcQIe|tests:1406")
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
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> version=must match \"" + SEM_VERSION_PATTERN + "\""));
    }

    @DisplayName("create_AppVersion_max_version_ok|rjTx8xl7NEDek0DvDGHh|tests:3024")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_max_version_ok() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS)
                .contentType("application/json")
                .content("""
                    {
                        "version": "99999.99999.99999",
                        "minimalVersion": false,
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].version").value("99999.99999.99999"));
    }

    @DisplayName("create_AppVersion_out_of_range|0LqEZXawDa9RFlZ1K0aN|tests:3024")
    @ParameterizedTest
    @ValueSource(strings = {"100000.0.0", "0.100000.0", "0.0.100000", "9999999999.0.0"})
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_out_of_range(String version) throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS)
                .contentType("application/json")
                .content("""
                    {
                        "version": "%s",
                        "minimalVersion": false,
                        "expiryDate": null
                    }
                    """.formatted(version)))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("create_AppVersion_leading_zeros|v8PbjFkOVxDMd9gK3S12|tests:3024")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_AppVersion_leading_zeros() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS)
                .contentType("application/json")
                .content("""
                    {
                        "version": "01.0.0",
                        "minimalVersion": false,
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("create_AppVersion_conflict_version|pnQ7A4qKs1NYjPWJV7sI|tests:1406")
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

    @DisplayName("update_AppVersion_out_of_range|aoMCJ6BLm8UfHGJvatvM|tests:3024")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void update_AppVersion_out_of_range() throws Exception {
        mockMvc.perform(put(API_APP_VERSIONS + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "version": "100000.0.0",
                        "minimalVersion": false,
                        "expiryDate": null
                    }
                    """))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("update_AppVersion_ok|UCmvF6J9SNOYYQe2Ve6T|tests:1406")
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

    @DisplayName("delete_AppVersionById_ok|FzYcq8V3AfBBq1fwbNUk|tests:1406")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    @Sql("classpath:createAppVersions.sql")
    void delete_AppVersionById_ok() throws Exception {
        mockMvc.perform(delete(API_APP_VERSIONS + "/1"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_APP_VERSIONS + "/1"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("create_AppVersion_forbidden|iITpOpb9gRiCRefD2bmT|tests:1406")
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
