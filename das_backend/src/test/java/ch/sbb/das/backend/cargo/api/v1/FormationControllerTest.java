package ch.sbb.das.backend.cargo.api.v1;

import static ch.sbb.das.backend.cargo.api.v1.FormationController.API_FORMATIONS;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.json.JsonCompareMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:createFormations.sql")
class FormationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @DisplayName("should_respond_formation|JM7TiuHzEID9CClr2xup|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_formation() throws Exception {
        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/54233/expected.json"));

        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185"))
            .andExpect(status().isOk())
            .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
    }

    @DisplayName("should_respond_not_modified_when_nothing_changed_since_etag|TRMVB5can12yMwzZ6U0Z|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_not_modified_when_nothing_changed_since_etag() throws Exception {
        String etagHeader = mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185")).andReturn()
            .getResponse().getHeader(HttpHeaders.ETAG);

        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185").header(HttpHeaders.IF_NONE_MATCH, etagHeader))
            .andExpect(status().isNotModified());
    }

    @DisplayName("should_respond_formation_when_changed_since_etag|xy5U8nxyp6vdM39Vcpyl|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_formation_when_changed_since_etag() throws Exception {
        String etagHeader = mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185")).andReturn()
            .getResponse().getHeader(HttpHeaders.ETAG);

        String sql = Files.readString(Paths.get("src/test/resources/updateFormation54233.sql"));
        jdbcTemplate.execute(sql);

        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/54233/expected_update.json"));

        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "54233").param("operationalDay", "2025-07-25").param("company", "2185").header(HttpHeaders.IF_NONE_MATCH, etagHeader))
            .andExpect(status().isOk())
            .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
    }

    @DisplayName("should_respond_latest_formation|Zjg5LRCGlvyAUfacMciu|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_latest_formation() throws Exception {
        String expectedJson = Files.readString(Paths.get("src/test/resources/cargo/739/expected.json"));
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "739").param("operationalDay", "2025-07-20").param("company", "3211"))
            .andExpect(status().isOk())
            .andExpect(content().json(expectedJson, JsonCompareMode.STRICT));
    }

    @DisplayName("should_respond_not_found|IAZd8tVR87Grm9QyOQRC|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_not_found() throws Exception {
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "30303").param("operationalDay", "2025-07-01").param("company", "1111"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("should_respond_bad_request|KrjflkScNI01jtG1nryh|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_bad_request() throws Exception {
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "30303").param("operationalDay", "2025-07-01").param("company", "wrongCompany"))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("should_respond_formation_with_sbbi_transport_paper_link|Hj6RnHN2tGxxdtnsKM62|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_formation_with_sbbi_transport_paper_link() throws Exception {
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "61078").param("operationalDay", "2025-08-01").param("company", "5184"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].formationRuns[0].transportPaperLink.type").value("URL"))
            .andExpect(jsonPath("$.data[0].formationRuns[0].transportPaperLink.url").value(
                "https://sbbi.example.com/#/zugliste/61078-001/2025-08-01/85/14035/0/RID_BEFOERDERUNGSDOKUMENT"));
    }

    @DisplayName("should_respond_formation_with_blsc_transport_paper_link|Xd09iobeIP8rDqqP4Ty1|tests:541")
    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void should_respond_formation_with_blsc_transport_paper_link() throws Exception {
        mockMvc.perform(get(API_FORMATIONS).param("operationalTrainNumber", "88001").param("operationalDay", "2025-08-01").param("company", "3356"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].formationRuns[0].transportPaperLink.type").value("URL"))
            .andExpect(jsonPath("$.data[0].formationRuns[0].transportPaperLink.url").value(
                "https://blsc.example.com"));
    }
}
