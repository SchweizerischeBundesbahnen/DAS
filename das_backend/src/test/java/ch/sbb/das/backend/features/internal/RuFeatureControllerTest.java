package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

import static ch.sbb.das.backend.features.internal.RuFeatureController.API_RU_FEATURES;
import static org.hamcrest.Matchers.*;
import static org.springframework.test.context.jdbc.SqlMergeMode.MergeMode.MERGE;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@IntegrationTest
@Sql("classpath:createCompaniesAndTenants.sql")
@Sql("classpath:emptyRuFeatures.sql")
@SqlMergeMode(MERGE)
class RuFeatureControllerTest {

    private static final int FEATURE_ID_OWN_1 = 1;
    private static final int FEATURE_ID_OWN_2 = 2;
    private static final int FEATURE_ID_OTHER_TENANT = 3;

    @Autowired
    private MockMvc mockMvc;

    @Test
    void getAllRuFeatures_unauthorized() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAllRuFeatures_forbidden_observer() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void getAllRuFeatures_ok_filteredByOwnTenant() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[*].companyCode", containsInAnyOrder("1111", "1111")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void getRuFeatureById_ok() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES + "/" + FEATURE_ID_OWN_1))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(FEATURE_ID_OWN_1))
            .andExpect(jsonPath("$.data[0].companyCode").value("1111"))
            .andExpect(jsonPath("$.data[0].key").value("WARNAPP"))
            .andExpect(jsonPath("$.data[0].enabled").value(true))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").exists())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getRuFeatureById_notFound() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES + "/999"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void getRuFeatureById_forbidden_otherTenant() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES + "/" + FEATURE_ID_OTHER_TENANT))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createRuFeature_ok() throws Exception {
        mockMvc.perform(post(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "2222", "key": "WARNAPP", "enabled": true }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").exists())
            .andExpect(jsonPath("$.data[0].companyCode").value("2222"))
            .andExpect(jsonPath("$.data[0].key").value("WARNAPP"))
            .andExpect(jsonPath("$.data[0].enabled").value(true))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").exists())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createRuFeature_badRequest_companyNotFound() throws Exception {
        mockMvc.perform(post(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "5555", "key": "WARNAPP", "enabled": true }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail", containsString("Company not found")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createRuFeature_forbidden_otherTenantCompany() throws Exception {
        mockMvc.perform(post(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "9999", "key": "WARNAPP", "enabled": true }
                    """))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createRuFeature_badRequest_invalidKey() throws Exception {
        mockMvc.perform(post(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "1111", "key": "NOT_A_REAL_KEY", "enabled": true }
                    """))
            .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void createRuFeature_conflict_duplicate() throws Exception {
        mockMvc.perform(post(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "1111", "key": "WARNAPP", "enabled": false }
                    """))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail", containsString("already exists")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void updateRuFeature_ok() throws Exception {
        mockMvc.perform(put(API_RU_FEATURES + "/" + FEATURE_ID_OWN_1)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "1111", "key": "WARNAPP", "enabled": false }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(FEATURE_ID_OWN_1))
            .andExpect(jsonPath("$.data[0].enabled").value(false))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").exists())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void updateRuFeature_notFound() throws Exception {
        mockMvc.perform(put(API_RU_FEATURES + "/999")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "1111", "key": "WARNAPP", "enabled": true }
                    """))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void updateRuFeature_forbidden_existingOtherTenant() throws Exception {
        mockMvc.perform(put(API_RU_FEATURES + "/" + FEATURE_ID_OTHER_TENANT)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "9999", "key": "WARNAPP", "enabled": false }
                    """))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void updateRuFeature_forbidden_movingToOtherTenantCompany() throws Exception {
        mockMvc.perform(put(API_RU_FEATURES + "/" + FEATURE_ID_OWN_1)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "9999", "key": "WARNAPP", "enabled": true }
                    """))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void updateRuFeature_conflict_duplicate() throws Exception {
        mockMvc.perform(put(API_RU_FEATURES + "/" + FEATURE_ID_OWN_2)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "companyCode": "1111", "key": "WARNAPP", "enabled": true }
                    """))
            .andExpect(status().isConflict());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void deleteRuFeaturesByIds_ok() throws Exception {
        mockMvc.perform(delete(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "ids": [1, 2] }
                    """))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_RU_FEATURES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    void deleteRuFeaturesByIds_forbidden_mixedTenants() throws Exception {
        mockMvc.perform(delete(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "ids": [1, 3] }
                    """))
            .andExpect(status().isForbidden());

        mockMvc.perform(get(API_RU_FEATURES + "/" + FEATURE_ID_OWN_1))
            .andExpect(status().isOk());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void deleteRuFeaturesByIds_invalid_emptyList() throws Exception {
        mockMvc.perform(delete(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "ids": [] }
                    """))
            .andExpect(status().isBadRequest());
    }
}
