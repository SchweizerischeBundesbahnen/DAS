package ch.sbb.das.backend.indications.internal;

import static ch.sbb.das.backend.indications.internal.RuIndicationTemplateController.API_RU_INDICATION_TEMPLATES;
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
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyRuIndicationTemplates.sql")
@SqlMergeMode(MERGE)
class RuIndicationTemplateControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @DisplayName("getAll_RuIndicationTemplates_ok|u8Ft1IrGIlzFdP8mKb2o|tests:1626")
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
            .andExpect(jsonPath("$.data[0].tenant").doesNotExist())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @DisplayName("getAll_RuIndicationTemplates_forbidden_role|E4cLW7Z6menVZfyLRQV4|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    void getAll_RuIndicationTemplates_forbidden_role() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isForbidden());
    }

    @DisplayName("getAll_RuIndicationTemplates_empty|7igIFKzDHTkR0hqWmLij|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void getAll_RuIndicationTemplates_empty() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(0)));
    }

    @DisplayName("getAll_RuIndicationTemplates_otherTenant_returnsOnlyOwnTenantTemplates|G22wQZGJUhC0qUaka8Fc|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN, adminTenant = false)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void getAll_RuIndicationTemplates_otherTenant_returnsOnlyOwnTenantTemplates() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(4))
            .andExpect(jsonPath("$.data[0].category").value("OPERATIONS"))
            .andExpect(jsonPath("$.data[0].tenant").doesNotExist());
    }

    @DisplayName("getRuIndicationTemplateById_ok|kXJHoF4Fcoyzb71icjlH|tests:1626")
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
            .andExpect(jsonPath("$.data[0].tenant").doesNotExist())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("unit_test"));
    }

    @DisplayName("getRuIndicationTemplateById_notFound|0ANh7zhbbbhOEsnIfeOV|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void getRuIndicationTemplateById_notFound() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES + "/99"))
            .andExpect(status().isNotFound());
    }

    @DisplayName("getRuIndicationTemplateById_forbidden_tenant|FxC4Sa7VXKwK2wfwtFJK|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void getRuIndicationTemplateById_forbidden_tenant() throws Exception {
        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES + "/4"))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @DisplayName("create_RuIndicationTemplate_ok_allLanguages|HMtS3Zr1gSw0xf82qtYT|tests:1626")
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
            .andExpect(jsonPath("$.data[0].it.text").value("Testo IT"))
            .andExpect(jsonPath("$.data[0].tenant").doesNotExist())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));

    }

    @DisplayName("create_RuIndicationTemplate_ok_singleLanguage_assignsCurrentTenant|nvYae169SEmBJONMBMDI|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN, adminTenant = false)
    void create_RuIndicationTemplate_ok_singleLanguage_assignsCurrentTenant() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Nur Deutsch", "text": "Nur Deutsch Text" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].category").value("INFO"))
            .andExpect(jsonPath("$.data[0].de.title").value("Nur Deutsch"))
            .andExpect(jsonPath("$.data[0].tenant").doesNotExist())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));

        mockMvc.perform(get(API_RU_INDICATION_TEMPLATES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].id").value(1))
            .andExpect(jsonPath("$.data[0].category").value("INFO"));
    }

    @DisplayName("create_RuIndicationTemplate_ok_ignores_empty_language_placeholders|oZXsBbGxah0q31VDK076|tests:1626")
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
                        "it": { "title": "", "text": "" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].category").value("Testkat"))
            .andExpect(jsonPath("$.data[0].de").isEmpty())
            .andExpect(jsonPath("$.data[0].fr.title").value("hellou fr"))
            .andExpect(jsonPath("$.data[0].fr.text").value("min text"))
            .andExpect(jsonPath("$.data[0].it").isEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));

    }

    @DisplayName("create_RuIndicationTemplate_invalid_noCategory|GUFeePfAvFhGfheUrRzS|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_noCategory() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "de": { "title": "Hinweis", "text": "Text DE" }
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> category=must not be blank"));
    }

    @DisplayName("create_RuIndicationTemplate_invalid_noLanguageContent|JjXU1GJbx5129YrXjQAk|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO"
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> ruIndicationTemplateRequest=At least one language content (de, fr or it) must be provided."));
    }

    @DisplayName("create_RuIndicationTemplate_invalid_blankTitle|Gr9vysfAOkaCAXFJ8FYk|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_invalid_blankTitle() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
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

    @DisplayName("create_RuIndicationTemplate_ok_onlyTitleProvided|FJInfq9ggyPk3nSryjAG|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void create_RuIndicationTemplate_ok_onlyTitleProvided() throws Exception {
        mockMvc.perform(post(API_RU_INDICATION_TEMPLATES)
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Hinweis" }
                    }
                    """))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.data[0].category").value("INFO"))
            .andExpect(jsonPath("$.data[0].de.title").value("Hinweis"))
            .andExpect(jsonPath("$.data[0].de.text").isEmpty());
    }

    @DisplayName("update_RuIndicationTemplate_ok|cOlq8XlYe79qOvd5wiWF|tests:1626")
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
            .andExpect(jsonPath("$.data[0].it").isEmpty())
            .andExpect(jsonPath("$.data[0].it.title").doesNotExist())
            .andExpect(jsonPath("$.data[0].it.text").doesNotExist())
            .andExpect(jsonPath("$.data[0].lastModifiedAt").isNotEmpty())
            .andExpect(jsonPath("$.data[0].lastModifiedBy").value("test-user"));
    }

    @DisplayName("update_RuIndicationTemplate_notFound|hEmVgQKX63bEjxfCklRi|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_RuIndicationTemplate_notFound() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/99")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO",
                        "de": { "title": "Hinweis", "text": "Text DE" }
                    }
                    """))
            .andExpect(status().isNotFound());
    }

    @DisplayName("update_RuIndicationTemplate_invalid_noLanguageContent|9tXM7W3aKxZY5Q49LfKc|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_RuIndicationTemplate_invalid_noLanguageContent() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/1")
                .contentType("application/json")
                .content("""
                    {
                        "category": "INFO"
                    }
                    """))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.detail").value("Invalid request content. -> ruIndicationTemplateRequest=At least one language content (de, fr or it) must be provided."));
    }

    @DisplayName("update_RuIndicationTemplate_invalid_blankTitle|EdPBy9w7monLh6YXWWWz|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    void update_RuIndicationTemplate_invalid_blankTitle() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/1")
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

    @DisplayName("update_RuIndicationTemplate_forbidden_whenExistingTenantDoesNotMatch|gta8uR49DNBJrEdMJ931|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void update_RuIndicationTemplate_forbidden_whenExistingTenantDoesNotMatch() throws Exception {
        mockMvc.perform(put(API_RU_INDICATION_TEMPLATES + "/4")
                .contentType("application/json")
                .content("""
                    {
                        "category": "UPDATED",
                        "de": { "title": "Geändert", "text": "Neuer Text DE" }
                    }
                    """))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.detail").value("Not allowed!"));
    }

    @DisplayName("deleteRuIndicationTemplateByIds_ok|8yyIhBMnWVklay7PLETi|tests:1626")
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

    @DisplayName("deleteRuIndicationTemplateByIds_invalid_body|ePOG9IkJjvfJhSSTRluy|tests:1626")
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

    @DisplayName("deleteRuIndicationTemplateByIds_forbidden_whenTemplateBelongsToOtherTenant|YxAE5jxFzSu3JBNcdHZU|tests:1626")
    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql("classpath:createRuIndicationTemplates.sql")
    void deleteRuIndicationTemplateByIds_forbidden_whenTemplateBelongsToOtherTenant() throws Exception {
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
