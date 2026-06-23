package ch.sbb.das.backend.admin.application.ruindications;

import static ch.sbb.das.backend.admin.application.ruindications.RuIndicationTemplateController.API_RU_INDICATION_TEMPLATES;
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
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyRuIndicationTemplates.sql")
@SqlMergeMode(MERGE)
class RuIndicationTemplateControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void getAll_RuIndicationTemplates_ok() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].category").value("OPERATIONS"))
            .andExpect(jsonPath("$.data[0].de.title").value("Standardtext 1"))
            .andExpect(jsonPath("$.data[0].de.text").value("Text 1 DE"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Avis 1"))
            .andExpect(jsonPath("$.data[0].fr.text").value("Texte 1 FR"))
            .andExpect(jsonPath("$.data[0].it.title").value("Avviso 1"))
            .andExpect(jsonPath("$.data[0].it.text").value("Testo 1 IT"))
            .andExpect(jsonPath("$.data[0].companies").value(containsInAnyOrder("1111")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAll_RuIndicationTemplates_forbidden_role() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isForbidden());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_RuIndicationTemplates_empty() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void getRuIndicationTemplateById_ok() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES + "/2"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].id").value(2))
            .andExpect(jsonPath("$.data[0].category").value("SAFETY"))
            .andExpect(jsonPath("$.data[0].de.title").value("Standardtext 2"))
            .andExpect(jsonPath("$.data[0].de.text").value("Text 2 DE"))
            .andExpect(jsonPath("$.data[0].fr.title").value("Avis 2"))
            .andExpect(jsonPath("$.data[0].fr.text").value("Texte 2 FR"))
            .andExpect(jsonPath("$.data[0].it.title").value("Avviso 2"))
            .andExpect(jsonPath("$.data[0].it.text").value("Testo 2 IT"))
            .andExpect(jsonPath("$.data[0].companies").value(containsInAnyOrder("1111")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void getRuIndicationTemplateById_notFound() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES + "/99"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void getRuIndicationTemplateById_forbidden_company() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES + "/4"))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_ok_allLanguages() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "SAFETY",
                        "de": { "title": "Hinweis", "text": "Text DE" },
                        "fr": { "title": "Avis", "text": "Texte FR" },
                        "it": { "title": "Avviso", "text": "Testo IT" },
                        "companies": ["1111"]
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
            .andExpect(jsonPath("$.data[0].it.text").value("Testo IT"))
            .andExpect(jsonPath("$.data[0].companies").value(containsInAnyOrder("1111")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));

    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_ok_singleLanguage() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Nur Deutsch", "text": "Nur Deutsch Text" },
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].category").value("INFO"))
            .andExpect(jsonPath("$.data[0].de.title").value("Nur Deutsch"))
            .andExpect(jsonPath("$.data[0].companies").value(containsInAnyOrder("1111")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_ok_ignores_empty_language_placeholders() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "Testkat",
                        "de": { "title": "", "text": "" },
                        "fr": { "title": "hellou fr", "text": "min text" },
                        "it": { "title": "", "text": "" },
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].category").value("Testkat"))
            .andExpect(jsonPath("$.data[0].de.title").isEmpty())
            .andExpect(jsonPath("$.data[0].de.text").isEmpty())
            .andExpect(jsonPath("$.data[0].fr.title").value("hellou fr"))
            .andExpect(jsonPath("$.data[0].fr.text").value("min text"))
            .andExpect(jsonPath("$.data[0].it.title").isEmpty())
            .andExpect(jsonPath("$.data[0].it.text").isEmpty())
            .andExpect(jsonPath("$.data[0].companies").value(containsInAnyOrder("1111")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));

    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_noCategory() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "de": { "title": "Hinweis", "text": "Text DE" },
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> category=must not be blank"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> ruIndicationTemplateRequest=At least one language content (de, fr or it) must be provided."));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_blankTitle() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "", "text": "Text DE" },
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> de.title=must not be blank"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_emptyCompanies() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Titel DE", "text": "Text DE" },
                        "companies": []
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> companies=must not be empty"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_notAllowedCompanies() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Titel DE", "text": "Text DE" },
                        "companies": ["9999"]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void update_RuIndicationTemplate_ok() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "UPDATED",
                        "de": { "title": "Geändert", "text": "Neuer Text DE" },
                        "fr": { "title": "Modifié", "text": "Nouveau texte FR" },
                        "companies": ["1111", "2222"]
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
            .andExpect(jsonPath("$.data[0].it.text").doesNotExist())
            .andExpect(jsonPath("$.data[0].companies").value(containsInAnyOrder("1111", "2222")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_RuIndicationTemplate_notFound() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/99")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Hinweis", "text": "Text DE" },
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_RuIndicationTemplate_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> ruIndicationTemplateRequest=At least one language content (de, fr or it) must be provided."));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_RuIndicationTemplate_invalid_blankTitle() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "fr": { "title": " ", "text": "Texte FR" },
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> fr.title=must not be blank"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void update_RuIndicationTemplate_forbidden_withNotAllowedCompanies() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "UPDATED",
                        "de": { "title": "Geändert", "text": "Neuer Text DE" },
                        "fr": { "title": "Modifié", "text": "Nouveau texte FR" },
                        "companies": ["1111", "9999"]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void update_RuIndicationTemplate_forbidden_whenExistingCompaniesNotAllowed() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/4")
                .contentType("application/json")
                .content("""
                    {
                        "category": "UPDATED",
                        "de": { "title": "Geändert", "text": "Neuer Text DE" },
                        "companies": ["1111"]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void deleteRuIndicationTemplateByIds_ok() throws Exception {
        mockMvc.perform(delete(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "ids": [1, 1, 2]
                    }
                    """))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(3))
            .andExpect(jsonPath("$.data[0].category").value("INFO"));

        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES + "/1"))
            .andExpect(status().isNotFound());

        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES + "/2"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void deleteRuIndicationTemplateByIds_invalid_body() throws Exception {
        mockMvc.perform(delete(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
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
    @Sql("classpath:createRuIndicationTemplates.sql")
    void deleteRuIndicationTemplateByIds_forbidden_whenNotAllowedCompanies() throws Exception {
        mockMvc.perform(delete(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "ids": [2, 4]
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }
}
