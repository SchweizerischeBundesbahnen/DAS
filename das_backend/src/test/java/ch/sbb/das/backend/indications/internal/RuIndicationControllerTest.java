package ch.sbb.das.backend.indications.internal;

import static ch.sbb.das.backend.indications.internal.RuIndicationController.API_DRIVER_RU_INDICATIONS;
import static ch.sbb.das.backend.indications.internal.RuIndicationController.API_RU_INDICATIONS;
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
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyRuIndications.sql")
@SqlMergeMode(MERGE)
class RuIndicationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_RuIndications_empty() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndications.sql")
    void getAll_RuIndications_ok() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].content.category").value("OPERATIONS"))
            .andExpect(jsonPath("$.data[0].content.de.title").value("Hinweis 1"))
            .andExpect(jsonPath("$.data[0].content.de.text").value("Text 1 DE"))
            .andExpect(jsonPath("$.data[0].content.fr.title").value("Avis 1"))
            .andExpect(jsonPath("$.data[0].content.fr.text").value("Texte 1 FR"))
            .andExpect(jsonPath("$.data[0].content.it").doesNotExist())
            .andExpect(jsonPath("$.data[0].scope.companies[0]").value("1111"))
            .andExpect(jsonPath("$.data[0].status").exists())
            .andExpect(jsonPath("$.data[1].id").value(2))
            .andExpect(jsonPath("$.data[1].content.category").doesNotExist())
            .andExpect(jsonPath("$.data[1].content.de.title").value("Hinweis 2"))
            .andExpect(jsonPath("$.data[1].status").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAll_RuIndications_forbidden_role() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndications.sql")
    void getRuIndicationById_ok() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS + "/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].content.de.title").value("Hinweis 1"))
            .andExpect(jsonPath("$.data[0].scope.companies[0]").value("1111"))
            .andExpect(jsonPath("$.data[0].status").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getRuIndicationById_notFound() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS + "/99"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndication_ok() throws Exception {
        mockMvc.perform(post(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "category": "OPERATIONS",
                            "de": { "title": "Hinweis", "text": "Text DE" },
                            "fr": { "title": "Avis", "text": "Texte FR" }
                        },
                        "scope": {
                            "companies": ["1111"],
                            "operationalTrainNumberFilters": [],
                            "tafTapLocationReferences": ["CH00001"]
                        },
                        "periods": [
                            { "validFrom": "2026-01-01", "validTo": "2026-12-31", "weekdays": [] }
                        ]
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].content.category").value("OPERATIONS"))
            .andExpect(jsonPath("$.data[0].content.de.title").value("Hinweis"))
            .andExpect(jsonPath("$.data[0].content.fr.title").value("Avis"))
            .andExpect(jsonPath("$.data[0].scope.companies[0]").value("1111"))
            .andExpect(jsonPath("$.data[0].scope.tafTapLocationReferences[0]").value("CH00001"))
            .andExpect(jsonPath("$.data[0].status").value("ACTIVE"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndication_invalid_missingContent() throws Exception {
        mockMvc.perform(post(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "scope": {
                            "companies": ["1111"],
                            "tafTapLocationReferences": ["CH00001"]
                        },
                        "periods": [
                            { "validFrom": "2026-01-01", "validTo": "2026-12-31", "weekdays": [] }
                        ]
                    }
                    """))
            .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndications.sql")
    void update_RuIndication_ok() throws Exception {
        mockMvc.perform(put(API_RU_INDICATIONS + "/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "category": "UPDATED",
                            "de": { "title": "Geändert", "text": "Neuer Text DE" }
                        },
                        "scope": {
                            "companies": ["1111"],
                            "tafTapLocationReferences": ["CH00099"]
                        },
                        "periods": [
                            { "validFrom": "2026-06-01", "validTo": "2026-06-30", "weekdays": ["TUESDAY"] }
                        ]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].content.category").value("UPDATED"))
            .andExpect(jsonPath("$.data[0].content.de.title").value("Geändert"))
            .andExpect(jsonPath("$.data[0].content.fr").doesNotExist())
            .andExpect(jsonPath("$.data[0].scope.tafTapLocationReferences[0]").value("CH00099"))
            .andExpect(jsonPath("$.data[0].periods[0].validFrom").value("2026-06-01"))
            .andExpect(jsonPath("$.data[0].periods[0].weekdays[0]").value("TUESDAY"))
            .andExpect(jsonPath("$.data[0].status").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_RuIndication_notFound() throws Exception {
        mockMvc.perform(put(API_RU_INDICATIONS + "/99")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "de": { "title": "Hinweis", "text": "Text DE" }
                        },
                        "scope": {
                            "companies": ["1111"],
                            "tafTapLocationReferences": ["CH00001"]
                        },
                        "periods": [
                            { "validFrom": "2026-01-01", "validTo": "2026-12-31", "weekdays": [] }
                        ]
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndications.sql")
    void deleteByIds_ok() throws Exception {
        mockMvc.perform(delete(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "ids": [1, 2] }
                    """))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_RU_INDICATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void deleteByIds_invalid_emptyList() throws Exception {
        mockMvc.perform(delete(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    { "ids": [] }
                    """))
            .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findRuIndicationMatches_ok_withMatchingRuIndications() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "company": "1111",
                        "operationalTrainNumber": 150,
                        "startDate": "2026-01-01",
                        "tafTapLocationReferences": ["CH00001", "CH00002"]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[0].tafTapLocationReference").value("CH00001"))
            .andExpect(jsonPath("$.data[0].ruIndicationContents[0].title").value("Hinweis 1"))
            .andExpect(jsonPath("$.data[1].tafTapLocationReference").value("CH00002"))
            .andExpect(jsonPath("$.data[1].ruIndicationContents[0].title").value("Hinweis 1"));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findRuIndicationMatches_ok_withAcceptLanguageFr() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .header(HttpHeaders.ACCEPT_LANGUAGE, "fr")
                .content("""
                    {
                        "company": "1111",
                        "operationalTrainNumber": 150,
                        "startDate": "2026-01-01",
                        "tafTapLocationReferences": ["CH00001"]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].ruIndicationContents[0].title").value("Avis 1"));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findMatches_ok_noRuIndicationMatches() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "company": "9999",
                        "operationalTrainNumber": 1,
                        "startDate": "2026-01-01",
                        "tafTapLocationReferences": ["CH00001"]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void findRuIndicationMatches_invalid_missingFields() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "company": "1111"
                    }
                    """))
            .andExpect(status().isBadRequest());
    }
}

