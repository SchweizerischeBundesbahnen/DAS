package ch.sbb.backend.formation.api.v1;

import static ch.sbb.backend.formation.api.v1.FormationController.API_FORMATIONS;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.backend.TestContainerConfiguration;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpHeaders;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.json.JsonCompareMode;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
@Import(TestContainerConfiguration.class)
@Sql("classpath:createFormations.sql")
class FormationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_formation() throws Exception {
        String expectedJson = Files.readString(Paths.get("src/test/resources/formations/54233.json"));

        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185"))
            .andExpect(status().isOk())
            .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
    }

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_not_modified_when_nothing_changed_since_etag() throws Exception {
        String etagHeader = mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185")).andReturn()
            .getResponse().getHeader(HttpHeaders.ETAG);

        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185").header(HttpHeaders.IF_NONE_MATCH, etagHeader))
            .andExpect(status().isNotModified());
    }

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_formation_when_changed_since_etag() throws Exception {
        String etagHeader = mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185")).andReturn()
            .getResponse().getHeader(HttpHeaders.ETAG);

        String sql = Files.readString(Paths.get("src/test/resources/updateFormation54233.sql"));
        jdbcTemplate.execute(sql);

        String expectedJson = Files.readString(Paths.get("src/test/resources/formations/54233_2.json"));

        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185").header(HttpHeaders.IF_NONE_MATCH, etagHeader))
            .andExpect(status().isOk())
            .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
    }

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_latest_formation() throws Exception {
        String expectedJson = Files.readString(Paths.get("src/test/resources/formations/739.json"));
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "739").param("operationalDay", "2025-07-20").param("company", "3211"))
            .andExpect(status().isOk())
            .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
    }

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_not_found() throws Exception {
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "30303").param("operationalDay", "2025-07-01").param("company", "1111"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_bad_request() throws Exception {
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "30303").param("operationalDay", "2025-07-01").param("company", "wrongCompany"))
            .andExpect(status().isBadRequest());
    }
}