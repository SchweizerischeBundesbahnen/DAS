package ch.sbb.das.backend.admin.application.notices;

import static ch.sbb.das.backend.admin.application.notices.NoticeTemplateController.API_NOTICE_TEMPLATES;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.context.jdbc.SqlMergeMode.MergeMode.MERGE;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyNoticeTemplates.sql")
@SqlMergeMode(MERGE)
class NoticeTemplateControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    @Sql("classpath:createNoticeTemplates.sql")
    void getAll_ok() throws Exception {
        mockMvc.perform(get(API_NOTICE_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].category").value("OPERATIONS"))
            .andExpect(jsonPath("$.data[0].de.title").value("Standardtext 1"))
            .andExpect(jsonPath("$.data[0].de.text").value("Text 1 DE"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Avis 1"))
            .andExpect(jsonPath("$.data[0].fr.text").value("Texte 1 FR"))
            .andExpect(jsonPath("$.data[0].it.title").value("Avviso 1"))
            .andExpect(jsonPath("$.data[0].it.text").value("Testo 1 IT"));
    }

    @Test
    @WithMockUser(authorities = "ROLE_observer")
    void getAll_forbidden_role() throws Exception {
        mockMvc.perform(get(API_NOTICE_TEMPLATES))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void getAll_empty() throws Exception {
        mockMvc.perform(get(API_NOTICE_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    @Sql("classpath:createNoticeTemplates.sql")
    void getById_ok() throws Exception {
        mockMvc.perform(get(API_NOTICE_TEMPLATES + "/2"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(2))
            .andExpect(jsonPath("$.data[0].category").value("SAFETY"))
            .andExpect(jsonPath("$.data[0].de.title").value("Standardtext 2"))
            .andExpect(jsonPath("$.data[0].de.text").value("Text 2 DE"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Avis 2"))
            .andExpect(jsonPath("$.data[0].fr.text").value("Texte 2 FR"))
            .andExpect(jsonPath("$.data[0].it.title").value("Avviso 2"))
            .andExpect(jsonPath("$.data[0].it.text").value("Testo 2 IT"));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void getById_notFound() throws Exception {
        mockMvc.perform(get(API_NOTICE_TEMPLATES + "/99"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void create_ok_allLanguages() throws Exception {
        mockMvc.perform(post(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "SAFETY",
                        "de": { "title": "Hinweis", "text": "Text DE" },
                        "fr": { "title": "Avis", "text": "Texte FR" },
                        "it": { "title": "Avviso", "text": "Testo IT" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].category").value("SAFETY"))
            .andExpect(jsonPath("$.data[0].de.title").value("Hinweis"))
            .andExpect(jsonPath("$.data[0].de.text").value("Text DE"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Avis"))
            .andExpect(jsonPath("$.data[0].fr.text").value("Texte FR"))
            .andExpect(jsonPath("$.data[0].it.title").value("Avviso"))
            .andExpect(jsonPath("$.data[0].it.text").value("Testo IT"));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void create_ok_singleLanguage() throws Exception {
        mockMvc.perform(post(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Nur Deutsch", "text": "Nur Deutsch Text" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].category").value("INFO"))
            .andExpect(jsonPath("$.data[0].de.title").value("Nur Deutsch"));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void create_ok_ignores_empty_language_placeholders() throws Exception {
        mockMvc.perform(post(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "Testkat",
                        "de": { "title": "", "text": "" },
                        "fr": { "title": "hellou fr", "text": "min text" },
                        "it": { "title": "", "text": "" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].category").value("Testkat"))
            .andExpect(jsonPath("$.data[0].de.title").isEmpty())
            .andExpect(jsonPath("$.data[0].de.text").isEmpty())
            .andExpect(jsonPath("$.data[0].fr.title").value("hellou fr"))
            .andExpect(jsonPath("$.data[0].fr.text").value("min text"))
            .andExpect(jsonPath("$.data[0].it.title").isEmpty())
            .andExpect(jsonPath("$.data[0].it.text").isEmpty());
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void create_invalid_noCategory() throws Exception {
        mockMvc.perform(post(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "de": { "title": "Hinweis", "text": "Text DE" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> category=must not be blank"));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void create_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(post(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO"
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> noticeTemplateRequest=At least one language content (de, fr or it) must be provided."));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void create_invalid_blankTitle() throws Exception {
        mockMvc.perform(post(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "", "text": "Text DE" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> de.title=must not be blank"));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    @Sql("classpath:createNoticeTemplates.sql")
    void update_ok() throws Exception {
        mockMvc.perform(put(API_NOTICE_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "UPDATED",
                        "de": { "title": "Geändert", "text": "Neuer Text DE" },
                        "fr": { "title": "Modifié", "text": "Nouveau texte FR" }
                    }
                    """))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].category").value("UPDATED"))
            .andExpect(jsonPath("$.data[0].de.title").value("Geändert"))
            .andExpect(jsonPath("$.data[0].de.text").value("Neuer Text DE"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Modifié"))
            .andExpect(jsonPath("$.data[0].fr.text").value("Nouveau texte FR"))
            .andExpect(jsonPath("$.data[0].it.title").doesNotExist())
            .andExpect(jsonPath("$.data[0].it.text").doesNotExist());
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void update_notFound() throws Exception {
        mockMvc.perform(put(API_NOTICE_TEMPLATES + "/99")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Hinweis", "text": "Text DE" }
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void update_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(put(API_NOTICE_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO"
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> noticeTemplateRequest=At least one language content (de, fr or it) must be provided."));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void update_invalid_blankTitle() throws Exception {
        mockMvc.perform(put(API_NOTICE_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "fr": { "title": " ", "text": "Texte FR" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> fr.title=must not be blank"));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    @Sql("classpath:createNoticeTemplates.sql")
    void deleteById_ok() throws Exception {
        mockMvc.perform(delete(API_NOTICE_TEMPLATES + "/1"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_NOTICE_TEMPLATES + "/1"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    @Sql("classpath:createNoticeTemplates.sql")
    void deleteById_ok_remainingNotAffected() throws Exception {
        mockMvc.perform(delete(API_NOTICE_TEMPLATES + "/1"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_NOTICE_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)));
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    @Sql("classpath:createNoticeTemplates.sql")
    void deleteBatch_ok() throws Exception {
        mockMvc.perform(delete(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "ids": [1, 1, 2]
                    }
                    """))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_NOTICE_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(3))
            .andExpect(jsonPath("$.data[0].category").value("INFO"));

        mockMvc.perform(get(API_NOTICE_TEMPLATES + "/1"))
            .andExpect(status().isNotFound());

        mockMvc.perform(get(API_NOTICE_TEMPLATES + "/2"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(authorities = "ROLE_ru_admin")
    void deleteBatch_invalid_body() throws Exception {
        mockMvc.perform(delete(API_NOTICE_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "ids": []
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> ids=must not be empty"));
    }
}
