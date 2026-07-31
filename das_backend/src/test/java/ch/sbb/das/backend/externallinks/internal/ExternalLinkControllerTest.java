package ch.sbb.das.backend.externallinks.internal;

import static ch.sbb.das.backend.externallinks.internal.ExternalLinkController.API_ADMIN_EXTERNAL_LINKS;
import static ch.sbb.das.backend.externallinks.internal.ExternalLinkController.API_DRIVER_EXTERNAL_LINKS;
import static org.hamcrest.Matchers.containsInAnyOrder;
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
@Sql("classpath:emptyExternalLinks.sql")
@SqlMergeMode(MERGE)
class ExternalLinkControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @DisplayName("External links when requested by RU admin then are returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getAllExternalLinks_ok() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[0].de.title").value("Standardtext 1"))
            .andExpect(jsonPath("$.data[0].de.link").value("https://sbb.ch"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Avis 1"))
            .andExpect(jsonPath("$.data[0].fr.link").value("https://sbb.ch"))
            .andExpect(jsonPath("$.data[0].it.title").value("Avviso 1"))
            .andExpect(jsonPath("$.data[0].it.link").value("https://sbb.ch"));
    }

    @DisplayName("External links when requested by observer then matching links are returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @Sql("classpath:createExternalLinks.sql")
    void getAllExternalLinksByCompanies_ok() throws Exception {
        mockMvc.perform(get(API_DRIVER_EXTERNAL_LINKS).param("companies", "1111"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)));

        mockMvc.perform(get(API_DRIVER_EXTERNAL_LINKS).param("companies", "1111", "2222", "3333"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)));

        mockMvc.perform(get(API_DRIVER_EXTERNAL_LINKS).param("companies", "9999"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)));
    }

    @DisplayName("External links when admin endpoint is called by observer then access is forbidden|tests:246")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAllExternalLinks_forbidden_role() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS))
            .andExpect(status().isForbidden());
    }

    @DisplayName("External links when driver endpoint is called by RU admin then access is forbidden|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAllExternalLinksByCompanies_forbidden_role() throws Exception {
        mockMvc.perform(get(API_DRIVER_EXTERNAL_LINKS).param("companies", "1111"))
            .andExpect(status().isForbidden());
    }

    @DisplayName("External link when id exists then details are returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getExternalLinkById_ok() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS + "/2"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(2))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("3333")))
            .andExpect(jsonPath("$.data[0].de.title").value("Standardtext 2"))
            .andExpect(jsonPath("$.data[0].de.link").value("https://sbb.ch"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Avis 2"))
            .andExpect(jsonPath("$.data[0].fr.link").value("https://sbb.ch"))
            .andExpect(jsonPath("$.data[0].it.title").value("Avviso 2"))
            .andExpect(jsonPath("$.data[0].it.link").value("https://sbb.ch"));
    }

    @DisplayName("External link when id does not exist then not found is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getExternalLinkById_notFound() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS + "/99"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("External link when existing company is not authorized then access is forbidden|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getExternalLinkById_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS + "/4"))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @DisplayName("External link when create request is valid then link is created|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_ok() throws Exception {
        mockMvc.perform(post(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111", "2222"],
                        "de": { "title": "Link", "link": "https://sbb.ch" },
                        "fr": { "title": "Lien", "link": "das://whatever" },
                        "it": { "title": "Collegamento", "link": "mailto:test.user@sbb.ch" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[0].de.title").value("Link"))
            .andExpect(jsonPath("$.data[0].de.link").value("https://sbb.ch"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Lien"))
            .andExpect(jsonPath("$.data[0].fr.link").value("das://whatever"))
            .andExpect(jsonPath("$.data[0].it.title").value("Collegamento"))
            .andExpect(jsonPath("$.data[0].it.link").value("mailto:test.user@sbb.ch"));
    }

    @DisplayName("External link when create request contains one language then link is created|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_ok_singleLanguage() throws Exception {
        mockMvc.perform(post(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111", "2222"],
                        "de": { "title": "Link", "link": "https://sbb.ch" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[0].de.title").value("Link"))
            .andExpect(jsonPath("$.data[0].de.link").value("https://sbb.ch"));
    }

    @DisplayName("External link when empty language placeholders are provided then they are ignored|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_ok_ignores_empty_language_placeholders() throws Exception {
        mockMvc.perform(post(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111", "2222"],
                        "de": { "title": "", "link": "" },
                        "fr": { "title": "FR", "link": "https://sbb.ch" },
                        "it": { "title": "", "link": "" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[0].de").isEmpty())
            .andExpect(jsonPath("$.data[0].fr.title").value("FR"))
            .andExpect(jsonPath("$.data[0].fr.link").value("https://sbb.ch"))
            .andExpect(jsonPath("$.data[0].it").isEmpty());
    }

    @DisplayName("External link when companies are missing then validation error is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_no_companies() throws Exception {
        mockMvc.perform(post(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "de": { "title": "Link", "link": "https://sbb.ch" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> companies=must not be empty"));
    }

    @DisplayName("External link when no language content is provided then validation error is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(post(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111", "2222"]
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> externalLinkRequest=At least one language content (de, fr or it) must be provided."));
    }

    @DisplayName("External link when title is blank then validation error is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_blankTitle() throws Exception {
        mockMvc.perform(post(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111", "2222"],
                        "de": { "title": "", "link": "https://sbb.ch" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> de.title=must not be blank"));
    }

    @DisplayName("External link when link format is invalid then validation error is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_link() throws Exception {
        mockMvc.perform(post(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111", "2222"],
                        "de": { "title": "Link", "link": "sbb.ch" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> de.link=must be a valid URL"));
    }

    @DisplayName("External link when update request is valid then link is updated|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void updateExternalLink_ok() throws Exception {
        mockMvc.perform(put(API_ADMIN_EXTERNAL_LINKS + "/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111"],
                        "de": { "title": "Geändert", "link": "https://bls.ch" },
                        "fr": { "title": "Modifié", "link": "https://bls.ch" }
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].companies", containsInAnyOrder("1111")))
            .andExpect(jsonPath("$.data[0].de.title").value("Geändert"))
            .andExpect(jsonPath("$.data[0].de.link").value("https://bls.ch"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Modifié"))
            .andExpect(jsonPath("$.data[0].fr.link").value("https://bls.ch"))
            .andExpect(jsonPath("$.data[0].it").isEmpty());
    }

    @DisplayName("External link when update id does not exist then not found is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void updateExternalLink_notFound() throws Exception {
        mockMvc.perform(put(API_ADMIN_EXTERNAL_LINKS + "/99")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111"],
                        "de": { "title": "Geändert", "link": "https://bls.ch" },
                        "fr": { "title": "Modifié", "link": "https://bls.ch" }
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @DisplayName("External link when update has no language content then validation error is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void updateExternalLink_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(put(API_ADMIN_EXTERNAL_LINKS + "/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> externalLinkRequest=At least one language content (de, fr or it) must be provided."));
    }

    @DisplayName("External link when update title is blank then validation error is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void updateExternalLink_invalid_blankTitle() throws Exception {
        mockMvc.perform(put(API_ADMIN_EXTERNAL_LINKS + "/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111"],
                        "fr": { "title": " ", "link": "https://bls.ch" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> fr.title=must not be blank"));
    }

    @DisplayName("External link when updating unauthorized company then access is forbidden|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void updateExternalLink_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(put(API_ADMIN_EXTERNAL_LINKS + "/4")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "companies": ["1111"],
                        "de": { "title": "Geändert", "link": "https://bls.ch" },
                        "fr": { "title": "Modifié", "link": "https://bls.ch" }
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @DisplayName("External links when deleted by ids then they are no longer retrievable|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void deleteExternalLinkByIds_ok() throws Exception {
        mockMvc.perform(delete(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "ids": [1, 2]
                    }
                    """))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)));

        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS + "/1"))
            .andExpect(status().isNotFound());

        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS + "/2"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("External links when delete body has empty ids then validation error is returned|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void deleteExternalLinkByIds_invalid_body() throws Exception {
        mockMvc.perform(delete(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "ids": []
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> ids=must not be empty"));
    }

    @DisplayName("External links when deleting unauthorized company then access is forbidden|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void deleteExternalLinkByIds_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(delete(API_ADMIN_EXTERNAL_LINKS)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                    {
                        "ids": [4]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }
}
