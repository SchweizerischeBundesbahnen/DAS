package ch.sbb.das.backend.admin.application.links;

import static ch.sbb.das.backend.admin.application.links.ExternalLinkController.API_EXTERNAL_LINKS;
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
import ch.sbb.das.backend.admin.application.settings.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyExternalLinks.sql")
@SqlMergeMode(MERGE)
public class ExternalLinkControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getAllExternalLinks_ok() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS))
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getAllExternalLinks_by_companies_ok() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS).param("companies", "1111"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(2)));

        mockMvc.perform(get(API_EXTERNAL_LINKS).param("companies", "1111", "2222", "3333"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(3)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getAllExternalLinks_by_companies_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS).param("companies", "9999"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAllExternalLinks_forbidden_role() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAllExternalLinks_empty() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getExternalLinkById_ok() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS + "/2"))
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getExternalLinkById_notFound() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS + "/99"))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void getExternalLinkById_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(get(API_EXTERNAL_LINKS + "/4"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_ok() throws Exception {
        mockMvc.perform(post(API_EXTERNAL_LINKS)
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_ok_singleLanguage() throws Exception {
        mockMvc.perform(post(API_EXTERNAL_LINKS)
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_ok_ignores_empty_language_placeholders() throws Exception {
        mockMvc.perform(post(API_EXTERNAL_LINKS)
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
                .andExpect(jsonPath("$.data[0].de.title").isEmpty())
                .andExpect(jsonPath("$.data[0].de.link").isEmpty())
                .andExpect(jsonPath("$.data[0].fr.title").value("FR"))
                .andExpect(jsonPath("$.data[0].fr.link").value("https://sbb.ch"))
                .andExpect(jsonPath("$.data[0].it.title").isEmpty())
                .andExpect(jsonPath("$.data[0].it.link").isEmpty());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_no_companies() throws Exception {
        mockMvc.perform(post(API_EXTERNAL_LINKS)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "de": { "title": "Link", "link": "https://sbb.ch" }
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.detail").value("Invalid request content. -> companies=must not be empty"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(post(API_EXTERNAL_LINKS)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "companies": ["1111", "2222"]
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.detail").value("Invalid request content. -> externalLinkRequest=At least one language content (de, fr or it) must be provided."));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_blankTitle() throws Exception {
        mockMvc.perform(post(API_EXTERNAL_LINKS)
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void createExternalLink_invalid_link() throws Exception {
        mockMvc.perform(post(API_EXTERNAL_LINKS)
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void updateExternalLink_ok() throws Exception {
        mockMvc.perform(put(API_EXTERNAL_LINKS + "/1")
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
                .andExpect(jsonPath("$.data[0].it.title").doesNotExist())
                .andExpect(jsonPath("$.data[0].it.text").doesNotExist());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void updateExternalLink_notFound() throws Exception {
        mockMvc.perform(put(API_EXTERNAL_LINKS + "/99")
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void updateExternalLink_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(put(API_EXTERNAL_LINKS + "/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "companies": ["1111"]
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.detail").value("Invalid request content. -> externalLinkRequest=At least one language content (de, fr or it) must be provided."));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void updateExternalLink_invalid_blankTitle() throws Exception {
        mockMvc.perform(put(API_EXTERNAL_LINKS + "/1")
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void updateExternalLink_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(put(API_EXTERNAL_LINKS + "/4")
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

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void deleteExternalLinkByIds_ok() throws Exception {
        mockMvc.perform(delete(API_EXTERNAL_LINKS)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "ids": [1, 2]
                                }
                                """))
                .andExpect(status().isNoContent());

        mockMvc.perform(get(API_EXTERNAL_LINKS))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data", hasSize(1)));

        mockMvc.perform(get(API_EXTERNAL_LINKS + "/1"))
                .andExpect(status().isNotFound());

        mockMvc.perform(get(API_EXTERNAL_LINKS + "/2"))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void deleteExternalLinkByIds_invalid_body() throws Exception {
        mockMvc.perform(delete(API_EXTERNAL_LINKS)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "ids": []
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.detail").value("Invalid request content. -> ids=must not be empty"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createExternalLinks.sql")
    void deleteExternalLinkByIds_forbidden_existingCompanyNotAuthorized() throws Exception {
        mockMvc.perform(delete(API_EXTERNAL_LINKS)
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
