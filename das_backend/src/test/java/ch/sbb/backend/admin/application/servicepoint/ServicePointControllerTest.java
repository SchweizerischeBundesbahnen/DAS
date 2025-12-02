package ch.sbb.backend.admin.application.servicepoint;

import static ch.sbb.backend.admin.application.servicepoint.ServicePointController.API_SERVICE_POINTS;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.backend.TestContainerConfiguration;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
@Import(TestContainerConfiguration.class)
class ServicePointControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockUser(authorities = "ROLE_admin")
    void should_respond_with_not_found() throws Exception {
        mockMvc.perform(get(API_SERVICE_POINTS + "/11111"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(authorities = "ROLE_admin")
    void should_respond_with_empty() throws Exception {
        mockMvc.perform(get(API_SERVICE_POINTS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.length()").value(0));
    }

}
