package ch.sbb.das.backend.features.internal;

import static ch.sbb.das.backend.features.internal.RuFeatureController.API_RU_FEATURES;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.containsString;
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
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

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
    @DisplayName("RU features when the user is not authenticated then access is unauthorized|HB25fSZOjgrazn6fBMrl|tests:712,713,723")
    void getAllRuFeatures_unauthorized() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @DisplayName("RU features when the caller has the observer role then access is forbidden|OCTjxjnYabkYTYaZJjs7|tests:712,713,723")
    void getAllRuFeatures_forbidden_observer() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    @DisplayName("RU features when the caller is an admin tenant then only own tenant features are returned|gJ9owrhFiafyE147uwfb|tests:712,713,723")
    void getAllRuFeatures_ok_filteredByOwnTenant() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[*].companyCode", containsInAnyOrder("1111", "1111")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    @DisplayName("RU feature when the id exists then the details are returned|1ODwgNsW4oQEGuf6sKkk|tests:712,713,723")
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
    @DisplayName("RU feature when the id does not exist then the API returns not found|iwy8Ly6HG5m7j88PZiOr|tests:712,713,723")
    void getRuFeatureById_notFound() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES + "/999"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuFeatures.sql")
    @DisplayName("RU feature when it belongs to another tenant then access is forbidden|18MbK6RxFUng6UlpHYu5|tests:712,713,723")
    void getRuFeatureById_forbidden_otherTenant() throws Exception {
        mockMvc.perform(get(API_RU_FEATURES + "/" + FEATURE_ID_OTHER_TENANT))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @DisplayName("RU feature when the create request is valid then a new feature flag is created|SsKtI6BaHXuWgCLpx8S8|tests:712,713,723")
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
    @DisplayName("RU feature when the company does not exist then the API returns bad request|w2Xfcdia5x4Te0JOrZ1d|tests:712,713,723")
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
    @DisplayName("RU feature when the company belongs to another tenant then access is forbidden|xHDTnL3iMZT0RoisACmL|tests:712,713,723")
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
    @DisplayName("RU feature when the feature key is invalid then the API returns bad request|5gjOCV0cAwKFCbRsoKYv|tests:712,713,723")
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
    @DisplayName("RU feature when the same feature key already exists for the company then the API returns conflict|oNjWKjkfdAaanYQECSHK|tests:712,713,723")
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
    @DisplayName("RU feature when valid update data is provided then the enabled status can be changed by the tenant admin|9migw8fE8F5YxcLvo6fr|tests:712,713,723")
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
    @DisplayName("RU feature when the id does not exist then the API returns not found|6y4TBVW4ErcCsBJOgLqN|tests:712,713,723")
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
    @DisplayName("RU feature when it is owned by another tenant then access is forbidden|LpwRMDeT206YC0jYOd4W|tests:712,713,723")
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
    @DisplayName("RU feature when the target company belongs to another tenant then access is forbidden|gk5EdJPiW85Gwe61aIfy|tests:712,713,723")
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
    @DisplayName("RU feature when the target key already exists for the same company then the API returns conflict|pbD2bYoc8eclX7dywY6E|tests:712,713,723")
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
    @DisplayName("RU features multiple own-tenant features can be removed at once|svH9fG7ILAP9ui6zNxkW|tests:712,713,723")
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
    @DisplayName("RU features when the selection of delete includes another tenant's features then access is forbidden|pwp3QP9NNryewsqwCMpA|tests:712,713,723")
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
    @DisplayName("RU features when no id is provided then the API returns bad request|iCNgR6eCddsXXGGlUQPY|tests:712,713,723")
    void deleteRuFeaturesByIds_badRequest_emptyBody() throws Exception {
        mockMvc.perform(delete(API_RU_FEATURES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "ids": [] }
                    """))
            .andExpect(status().isBadRequest());
    }
}
