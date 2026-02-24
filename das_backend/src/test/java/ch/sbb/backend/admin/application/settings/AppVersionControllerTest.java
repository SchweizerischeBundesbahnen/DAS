package ch.sbb.backend.admin.application.settings;

import static ch.sbb.backend.admin.application.settings.AppVersionController.API_SETTINGS_APPVERSION;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.backend.IntegrationTest;
import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
class AppVersionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockUser(authorities = "ROLE_admin")
    void getAll_empty() throws Exception {
        mockMvc.perform(get(API_SETTINGS_APPVERSION))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    void getOne_not_found() {
        // should return 404
    }

    @Test
    @Sql("classpath:createAppVersions.sql")
    void getOne_by_id() {
        // get by Id and validate response
    }

    @Test
    @WithMockUser(authorities = "ROLE_admin")
    void create() throws Exception {
        String jsonResult = mockMvc.perform(post(API_SETTINGS_APPVERSION)
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
            .andExpect(jsonPath("$.data[0].expiryDate").isEmpty()).andReturn().getResponse().getContentAsString();

        int id = JsonPath.read(jsonResult, "$.data[0].id");

        mockMvc.perform(get(API_SETTINGS_APPVERSION + "/" + id))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").isNumber())
            .andExpect(jsonPath("$.data[0].version").value("1.6.3"))
            .andExpect(jsonPath("$.data[0].minimalVersion").value(true))
            .andExpect(jsonPath("$.data[0].expiryDate").isEmpty());
    }

    @Test
    @Sql("classpath:createAppVersions.sql")
    void update() {
        // put request
    }

    @Test
    void delete() {

    }

}
