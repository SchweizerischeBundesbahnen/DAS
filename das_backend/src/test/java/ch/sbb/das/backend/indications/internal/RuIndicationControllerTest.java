package ch.sbb.das.backend.indications.internal;

import static ch.sbb.das.backend.indications.internal.RuIndicationController.API_DRIVER_RU_INDICATION_MATCHES;
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
import org.junit.jupiter.api.DisplayName;
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

    @DisplayName("RU indications when none exist then the list is empty|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_RuIndications_empty() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @DisplayName("RU indications when data exists then all indications with detauks are returned|tests:144,1657")
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

    @DisplayName("RU indications when the caller lacks the RU admin role then access is forbidden|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAll_RuIndications_forbidden_role() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS))
            .andExpect(status().isForbidden());
    }

    @DisplayName("RU indication when the id exists then the indication with details is returned|tests:144,1657")
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

    @DisplayName("RU indication when the id does not exist then the API returns not found|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getRuIndicationById_notFound() throws Exception {
        mockMvc.perform(get(API_RU_INDICATIONS + "/99"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("RU indication when the request is valid then the indication is created|tests:144,1657")
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
            .andExpect(jsonPath("$.data[0].scope.operationalTrainNumberFilters", hasSize(0)))
            .andExpect(jsonPath("$.data[0].scope.tafTapLocationReferences[0]").value("CH00001"))
            .andExpect(jsonPath("$.data[0].status").value("ACTIVE"));
    }

    @DisplayName("RU indication when the content section is missing then the request is rejected|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndication_ok_withOperationalTrainNumberFilters() throws Exception {
        mockMvc.perform(post(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "category": "OPERATIONS",
                            "de": { "title": "Hinweis", "text": "Text DE" }
                        },
                        "scope": {
                            "companies": ["1111"],
                            "operationalTrainNumberFilters": [
                                { "expression": "300-310", "parity": "EVEN" },
                                { "expression": "500", "parity": "ANY" }
                            ],
                            "tafTapLocationReferences": ["CH00001"]
                        },
                        "periods": [
                            { "validFrom": "2026-01-01", "validTo": "2026-12-31", "weekdays": [] }
                        ]
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].scope.operationalTrainNumberFilters", hasSize(2)))
            .andExpect(jsonPath("$.data[0].scope.operationalTrainNumberFilters[0].expression").value("300-310"))
            .andExpect(jsonPath("$.data[0].scope.operationalTrainNumberFilters[0].parity").value("EVEN"))
            .andExpect(jsonPath("$.data[0].scope.operationalTrainNumberFilters[1].expression").value("500"))
            .andExpect(jsonPath("$.data[0].scope.operationalTrainNumberFilters[1].parity").value("ANY"));
    }

    @DisplayName("RU indication when the operational train number filter expression non numeric then the request is rejected|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndication_invalid_operationalTrainNumberFilter_badExpression() throws Exception {
        mockMvc.perform(post(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "de": { "title": "Hinweis", "text": "Text DE" }
                        },
                        "scope": {
                            "companies": ["1111"],
                            "operationalTrainNumberFilters": [
                                { "expression": "abc", "parity": "ANY" }
                            ],
                            "tafTapLocationReferences": ["CH00001"]
                        },
                        "periods": [
                            { "validFrom": "2026-01-01", "validTo": "2026-12-31", "weekdays": [] }
                        ]
                    }
                    """))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("RU indication when the operational train number filter expression invalid range then the request is rejected|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndication_invalid_operationalTrainNumberFilter_invalidRange() throws Exception {
        mockMvc.perform(post(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "de": { "title": "Hinweis", "text": "Text DE" }
                        },
                        "scope": {
                            "companies": ["1111"],
                            "operationalTrainNumberFilters": [
                                { "expression": "400-300", "parity": "ANY" }
                            ],
                            "tafTapLocationReferences": ["CH00001"]
                        },
                        "periods": [
                            { "validFrom": "2026-01-01", "validTo": "2026-12-31", "weekdays": [] }
                        ]
                    }
                    """))
            .andExpect(status().isBadRequest());
    }

    @DisplayName("RU indication when the operational train number filter missing then the request is rejected|tests:144,1657")
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

    @DisplayName("RU indication when the title is missing then the request is rejected|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndication_invalid_missingTitle() throws Exception {
        mockMvc.perform(post(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "de": { "text": "Text DE" }
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
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> content.de.title=must not be blank"));
    }

    @DisplayName("RU indication when the text is missing then the request is rejected|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndication_invalid_missingText() throws Exception {
        mockMvc.perform(post(API_RU_INDICATIONS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "content": {
                            "de": { "title": "Hinweis" }
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
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> content.de.text=must not be blank"));
    }

    @DisplayName("RU indication when valid update request then the indication is updated with new details|tests:144,1657")
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

    @DisplayName("RU indication when the id does not exist then the API returns not found|tests:144,1657")
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

    @DisplayName("RU indications when deleted by ids then the selected indications are permanently removed|tests:144,1657")
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

    @DisplayName("RU indications when no id is provided then the request is rejected|tests:144,1657")
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

    @DisplayName("RU indications matches when train, location and date are provided then matching indications are returned|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findRuIndicationMatches_ok_withMatchingRuIndications() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATION_MATCHES)
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

    @DisplayName("RU indications matches when a language is requested then the indications are returned in that language|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findRuIndicationMatches_ok_withAcceptLanguageFr() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATION_MATCHES)
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

    @DisplayName("RU indications matches when no indications match the criteria then the list is empty|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findRuIndicationMatches_ok_trainNumberOutsideOperationalTrainNumberFilterRange() throws Exception {
        // Indication 1 restricts to trainNumbers 100-200 at CH00001; Indication 2 has no filter but doesn't cover CH00001.
        mockMvc.perform(post(API_DRIVER_RU_INDICATION_MATCHES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "company": "1111",
                        "operationalTrainNumber": 250,
                        "startDate": "2026-01-01",
                        "tafTapLocationReferences": ["CH00001"]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @DisplayName("RU indication matches when the operational train number filter boundary then it is returned|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findRuIndicationMatches_ok_trainNumberOnOperationalTrainNumberFilterBoundary() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATION_MATCHES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "company": "1111",
                        "operationalTrainNumber": 200,
                        "startDate": "2026-01-01",
                        "tafTapLocationReferences": ["CH00001"]
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].tafTapLocationReference").value("CH00001"));
    }

    @DisplayName("RU indication matches when no match returns empty|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createRuIndications.sql")
    void findMatches_ok_noRuIndicationMatches() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATION_MATCHES)
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

    @DisplayName("RU indication matches when mandatory fields are missing then the request is rejected|tests:144,1657")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void findRuIndicationMatches_invalid_missingFields() throws Exception {
        mockMvc.perform(post(API_DRIVER_RU_INDICATION_MATCHES)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "company": "1111"
                    }
                    """))
            .andExpect(status().isBadRequest());
    }
}
