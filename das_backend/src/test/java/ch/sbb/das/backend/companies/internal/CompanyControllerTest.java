package ch.sbb.das.backend.companies.internal;

import static ch.sbb.das.backend.companies.internal.CompanyController.API_COMPANIES;
import static ch.sbb.das.backend.companies.internal.CompanyController.API_COMPANIES_AUTHORIZED;
import static ch.sbb.das.backend.companies.internal.CompanyController.API_TENANTS;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
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
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:createCompaniesAndTenants.sql")
class CompanyControllerTest {

    private static final String VALID_TENANT_ID = "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a";
    private static final int COMPANY_ID_UPD1 = 900;
    private static final int COMPANY_ID_UPD2 = 901;
    private static final int COMPANY_ID_UPD3 = 902;
    private static final int COMPANY_ID_DEL1 = 903;

    @Autowired
    private MockMvc mockMvc;

    @DisplayName("Authorized companies when the caller is an RU admin then allowed companies are returned|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAuthorizedCompanies_ok_adminTenant_returnsAllowedCompanies() throws Exception {
        mockMvc.perform(get(API_COMPANIES_AUTHORIZED))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(7)))
            .andExpect(jsonPath("$.data[*].code", containsInAnyOrder("1111", "2222", "3333", "8881", "8882", "8883", "7777")));
    }

    @DisplayName("All companies when the caller is admin then all companies are returned|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAllCompanies_ok_returnsAllCompanies() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(8)))
            .andExpect(jsonPath("$.data[*].code", containsInAnyOrder("1111", "2222", "3333", "9999", "8881", "8882", "8883", "7777")));
    }

    @DisplayName("All companies when the caller is an RU admin then access is forbidden|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAllCompanies_forbidden_ruAdmin() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isForbidden());
    }

    @DisplayName("All companies when the caller is an observer then access is forbidden|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAllCompanies_forbidden_observer() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isForbidden());
    }

    @DisplayName("All companies when the caller is not authenticated then access is unauthorized|tests:428,2121")
    @Test
    void getAllCompanies_unauthorized() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isUnauthorized());
    }

    @DisplayName("Company when the create request is valid then it is created|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void createCompany_ok() throws Exception {
        mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "4444",
                        "shortName": "NEW1",
                        "tenantId": "%s"
                    }
                    """.formatted(VALID_TENANT_ID)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").isNumber())
            .andExpect(jsonPath("$.data[0].code").value("4444"))
            .andExpect(jsonPath("$.data[0].shortName").value("NEW1"));
    }

    @DisplayName("Company when the tenant does not exist then the API returns bad request|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void createCompany_badRequest_tenantNotFound() throws Exception {
        mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "5555",
                        "shortName": "FAIL",
                        "tenantId": "non-existing-tenant-id"
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail", containsString("Tenant not found")));
    }

    @DisplayName("Company when the code already exists then the API returns conflict|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void createCompany_conflict_duplicateCode() throws Exception {
        mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "1111",
                        "shortName": "UNIQUE",
                        "tenantId": "%s"
                    }
                    """.formatted(VALID_TENANT_ID)))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail", containsString("Company code already exists")));
    }

    @DisplayName("Company when the short name already exists then the API returns conflict|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void createCompany_conflict_duplicateShortName() throws Exception {
        mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "6666",
                        "shortName": "MOCK_A",
                        "tenantId": "%s"
                    }
                    """.formatted(VALID_TENANT_ID)))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail", containsString("Company short name already exists")));
    }

    @DisplayName("Company when valid update data is provided then it is updated|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void updateCompany_ok() throws Exception {
        mockMvc.perform(put(API_COMPANIES + "/" + COMPANY_ID_UPD1)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "8881",
                        "shortName": "UPDATED",
                        "tenantId": "%s"
                    }
                    """.formatted(VALID_TENANT_ID)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].shortName").value("UPDATED"));
    }

    @DisplayName("Company when the id does not exist then the API returns not found|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void updateCompany_notFound() throws Exception {
        mockMvc.perform(put(API_COMPANIES + "/" + Integer.MAX_VALUE)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "1111",
                        "shortName": "NOPE",
                        "tenantId": "%s"
                    }
                    """.formatted(VALID_TENANT_ID)))
            .andExpect(status().isNotFound());
    }

    @DisplayName("Company when the tenant does not exist then the API returns bad request|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void updateCompany_badRequest_tenantNotFound() throws Exception {
        mockMvc.perform(put(API_COMPANIES + "/" + COMPANY_ID_UPD2)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "8882",
                        "shortName": "UPD2",
                        "tenantId": "non-existing-tenant-id"
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail", containsString("Tenant not found")));
    }

    @DisplayName("Company when the code already exists then the API returns conflict|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void updateCompany_conflict_duplicateCode() throws Exception {
        mockMvc.perform(put(API_COMPANIES + "/" + COMPANY_ID_UPD3)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "1111",
                        "shortName": "UPD3",
                        "tenantId": "%s"
                    }
                    """.formatted(VALID_TENANT_ID)))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail", containsString("Company code already exists")));
    }

    @DisplayName("Company when the id exists then the company is returned|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getCompanyById_ok() throws Exception {
        mockMvc.perform(get(API_COMPANIES + "/" + COMPANY_ID_UPD1))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].code").value("8881"))
            .andExpect(jsonPath("$.data[0].shortName").value("UPD1"));
    }

    @DisplayName("Company when the id does not exist then the API returns not found|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getCompanyById_notFound() throws Exception {
        mockMvc.perform(get(API_COMPANIES + "/" + Integer.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @DisplayName("Company when the id exists then it is deleted|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void deleteCompany_ok() throws Exception {
        mockMvc.perform(delete(API_COMPANIES + "/" + COMPANY_ID_DEL1))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_COMPANIES + "/" + COMPANY_ID_DEL1))
            .andExpect(status().isNotFound());
    }

    @DisplayName("Tenants when requested then all tenants are returned|tests:428,2121")
    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAllTenants_ok() throws Exception {
        mockMvc.perform(get(API_TENANTS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[*].name", containsInAnyOrder("sbb", "unknown-tenant")))
            .andExpect(jsonPath("$.data[*].tenantId", containsInAnyOrder(
                VALID_TENANT_ID,
                "3409e798-d567-49b1-9bae-f0be66427c54")));
    }
}
