package ch.sbb.backend.admin.application.settings;

import static ch.sbb.backend.admin.application.settings.SettingsController.API_SETTINGS;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.admin.domain.settings.model.RuFeatureName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@Import(TestContainerConfiguration.class)
class SettingsControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    @Sql("classpath:createRuFeature.sql")
    void should_respond_with_settings() throws Exception {
        mockMvc.perform(get(API_SETTINGS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("ruFeatures", hasSize(1)))
            .andExpect(jsonPath("ruFeatures.[0].name").value(RuFeatureName.GESTES.name()))
            .andExpect(jsonPath("ruFeatures.[0].companyCodeRics").value("1111"))
            .andExpect(jsonPath("ruFeatures.[0].enabled").value(true));
    }
}
