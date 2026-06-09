package ch.sbb.das.backend.companies.internal;

import static ch.sbb.das.backend.companies.internal.CompanyController.API_COMPANIES;
import static ch.sbb.das.backend.companies.internal.CompanyController.API_COMPANIES_AUTHORIZED;
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
import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:createCompaniesAndTenants.sql")
class CompanyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_ok_adminTenant_returnsAllowedCompanies() throws Exception {
        mockMvc.perform(get(API_COMPANIES_AUTHORIZED))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[*].code", containsInAnyOrder("1111", "2222", "3333")))
            .andExpect(jsonPath("$.data[*].shortName", containsInAnyOrder("MOCK_A", "MOCK_B", "MOCK_C")));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getAll_ok_returnsAllCompanies() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(4)))
            .andExpect(jsonPath("$.data[*].code", containsInAnyOrder("1111", "2222", "3333", "9999")))
            .andExpect(jsonPath("$.data[*].shortName",
                containsInAnyOrder("MOCK_A", "MOCK_B", "MOCK_C", "MOCK_OTHER")));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_forbidden_ruAdmin() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAll_forbidden_observer() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isForbidden());
    }

    @Test
    void getAll_unauthorized() throws Exception {
        mockMvc.perform(get(API_COMPANIES))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_ok() throws Exception {
        String jsonResult = mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "4444",
                        "shortName": "NEW1",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").isNumber())
            .andExpect(jsonPath("$.data[0].code").value("4444"))
            .andExpect(jsonPath("$.data[0].shortName").value("NEW1"))
            .andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(jsonResult, "$.data[0].id");

        mockMvc.perform(get(API_COMPANIES + "/" + id))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].code").value("4444"))
            .andExpect(jsonPath("$.data[0].shortName").value("NEW1"));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_badRequest_tenantNotFound() throws Exception {
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

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_conflict_duplicateCode() throws Exception {
        mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "1111",
                        "shortName": "UNIQUE",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail", containsString("Company code already exists")));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void create_conflict_duplicateShortName() throws Exception {
        mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "6666",
                        "shortName": "MOCK_A",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail", containsString("Company short name already exists")));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void update_ok() throws Exception {
        String created = mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "8881",
                        "shortName": "UPD1",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isCreated())
            .andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(created, "$.data[0].id");

        mockMvc.perform(put(API_COMPANIES + "/" + id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "8881",
                        "shortName": "UPDATED",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].shortName").value("UPDATED"));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void update_notFound() throws Exception {
        mockMvc.perform(put(API_COMPANIES + "/" + Integer.MAX_VALUE)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "1111",
                        "shortName": "NOPE",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void update_badRequest_tenantNotFound() throws Exception {
        String created = mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "8882",
                        "shortName": "UPD2",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isCreated())
            .andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(created, "$.data[0].id");

        mockMvc.perform(put(API_COMPANIES + "/" + id)
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

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void update_conflict_duplicateCode() throws Exception {
        String created = mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "8883",
                        "shortName": "UPD3",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isCreated())
            .andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(created, "$.data[0].id");

        mockMvc.perform(put(API_COMPANIES + "/" + id)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "1111",
                        "shortName": "UPD3",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isConflict())
            .andExpect(jsonPath("$.detail", containsString("Company code already exists")));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void getById_notFound() throws Exception {
        mockMvc.perform(get(API_COMPANIES + "/" + Integer.MAX_VALUE))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void delete_ok() throws Exception {
        String jsonResult = mockMvc.perform(post(API_COMPANIES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "code": "7777",
                        "shortName": "DEL1",
                        "tenantId": "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"
                    }
                    """))
            .andExpect(status().isCreated())
            .andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(jsonResult, "$.data[0].id");

        mockMvc.perform(delete(API_COMPANIES + "/" + id))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_COMPANIES + "/" + id))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN)
    void delete_notFound() throws Exception {
        mockMvc.perform(delete(API_COMPANIES + "/" + Integer.MAX_VALUE))
            .andExpect(status().isNotFound());
    }
}
