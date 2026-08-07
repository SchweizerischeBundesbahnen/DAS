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

    @DisplayName("getAllExternalLinks_ok|PM3MRlYrTKhsFunDCUfE|tests:246")
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

    @DisplayName("getAllExternalLinksByCompanies_ok|voBIniFPJEyqLIUaGIlO|tests:246")
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

    @DisplayName("getAllExternalLinks_forbidden_role|0vUxtgBX5lnkC0qR5tpN|tests:246")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAllExternalLinks_forbidden_role() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS))
            .andExpect(status().isForbidden());
    }

    @DisplayName("getAllExternalLinksByCompanies_forbidden_role|ErKT6YuwzCDZnCCvteph|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAllExternalLinksByCompanies_forbidden_role() throws Exception {
        mockMvc.perform(get(API_DRIVER_EXTERNAL_LINKS).param("companies", "1111"))
            .andExpect(status().isForbidden());
    }

    @DisplayName("getExternalLinkById_ok|NmmaDBtqjP2r1DY7LQF9|tests:246")
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

    @DisplayName("getExternalLinkById_notFound|q7hzgA7xWAltCmqhItxl|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getExternalLinkById_notFound() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS + "/99"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("getExternalLinkById_forbidden_existingCompanyNotAuthorized|neiF4fIakvVLF515eJlG|tests:246")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getExternalLinkById_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(get(API_ADMIN_EXTERNAL_LINKS + "/4"))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @DisplayName("createExternalLink_ok|Z93QSSXFtXJeFDUpsS4U|tests:246")
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

    @DisplayName("createExternalLink_ok_singleLanguage|jneBwnhXxZFyftXZlgoC|tests:246")
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

    @DisplayName("createExternalLink_ok_ignores_empty_language_placeholders|UsDWQqk45xu3ueJYObfS|tests:246")
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

    @DisplayName("createExternalLink_invalid_no_companies|VQPGY2vEpvwo6KoJDkjc|tests:246")
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

    @DisplayName("createExternalLink_invalid_noLanguageContent|2jDBvio5zm9ynUbbQYSq|tests:246")
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

    @DisplayName("createExternalLink_invalid_blankTitle|GgtcTIG5mddhvJPCqXpg|tests:246")
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

    @DisplayName("createExternalLink_invalid_link|aSM94O6RgRr9RtTGfkoY|tests:246")
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

    @DisplayName("updateExternalLink_ok|XzH0Td4aGTOxnOylJGJm|tests:246")
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

    @DisplayName("updateExternalLink_notFound|jTS8gz60gihEfzW3Ml4W|tests:246")
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

    @DisplayName("updateExternalLink_invalid_noLanguageContent|y4PqMTxooaSY3qz37cD9|tests:246")
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

    @DisplayName("updateExternalLink_invalid_blankTitle|aMTAPsnCojw2zcKEVFyD|tests:246")
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

    @DisplayName("updateExternalLink_forbidden_existingCompanyNotAuthorized|eHGjf7POcW3CbIXZyHbt|tests:246")
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

    @DisplayName("deleteExternalLinkByIds_ok|NnXvwxshpTclWRhXQAR8|tests:246")
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

    @DisplayName("deleteExternalLinkByIds_invalid_body|kQV4PAQQMsHrPSxZkY6M|tests:246")
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

    @DisplayName("deleteExternalLinkByIds_forbidden_existingCompanyNotAuthorized|laCIGDw6JmHNAwOdqr7S|tests:246")
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
