package ch.sbb.das.backend.personalnotes.internal;

import static ch.sbb.das.backend.personalnotes.internal.PersonalNoteController.API_PERSONAL_NOTES;
import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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
import org.springframework.test.context.jdbc.SqlMergeMode.MergeMode;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyPersonalNotes.sql")
@SqlMergeMode(MergeMode.MERGE)
class PersonalNoteControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PersonalNoteRepository personalNoteRepository;

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("getAllPersonalNotes_ok_returnsOnlyOwnNotes|pN1aB2cD3eF4gH5iJ6kL|tests:2256")
    void getAllPersonalNotes_ok_returnsOnlyOwnNotes() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[?(@.key == 'train-12345')]").exists())
            .andExpect(jsonPath("$.data[?(@.key == 'bp-67890')]").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("getPersonalNoteByKey_ok|qO2bC3dE4fG5hI6jK7lM|tests:2256")
    void getPersonalNoteByKey_ok() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES + "/train-12345"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].key", is("train-12345")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("getPersonalNoteByKey_notFound|rP3cD4eF5gH6iJ7kL8mN|tests:2256")
    void getPersonalNoteByKey_notFound() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES + "/nonexistent"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("savePersonalNote_ok_createsNew|sQ4dE5fG6hI7jK8lM9nO|tests:2256")
    void savePersonalNote_ok_createsNew() throws Exception {
        mockMvc.perform(put(API_PERSONAL_NOTES + "/train-99999")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"text\": \"New note\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].key", is("train-99999")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("savePersonalNote_ok_updatesExisting|tR5eF6gH7iJ8kL9mN0oP|tests:2256")
    void savePersonalNote_ok_updatesExisting() throws Exception {
        mockMvc.perform(put(API_PERSONAL_NOTES + "/train-12345")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"text\": \"Updated note\"}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].key", is("train-12345")));

        mockMvc.perform(get(API_PERSONAL_NOTES + "/train-12345"))
            .andExpect(status().isOk());
    }

    @Test
    @DisplayName("getAllPersonalNotes_unauthorized|uS6fG7hI8jK9lM0nO1pQ|tests:2256")
    void getAllPersonalNotes_unauthorized() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("savePersonalNote_payloadTooLarge_rejected|vT7gH8iJ9kL0mN1oP2qR|tests:2256")
    void savePersonalNote_payloadTooLarge_rejected() throws Exception {
        String oversizedValue = "\"" + "a".repeat(16384) + "\"";

        mockMvc.perform(put(API_PERSONAL_NOTES + "/train-12345")
                .contentType(MediaType.APPLICATION_JSON)
                .content(oversizedValue))
            .andExpect(status().isContentTooLarge());

        mockMvc.perform(get(API_PERSONAL_NOTES + "/train-12345"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("deletePersonalNote_ok_removesOwnNote|wU8hI9jK0lM1nO2pQ3rS|tests:2256")
    void deletePersonalNote_ok_removesOwnNote() throws Exception {
        mockMvc.perform(delete(API_PERSONAL_NOTES + "/train-12345"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_PERSONAL_NOTES + "/train-12345"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("deletePersonalNote_idempotent_whenKeyDoesNotExist|xV9iJ0kL1mN2oP3qR4sT|tests:2256")
    void deletePersonalNote_idempotent_whenKeyDoesNotExist() throws Exception {
        mockMvc.perform(delete(API_PERSONAL_NOTES + "/nonexistent"))
            .andExpect(status().isNoContent());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("deletePersonalNote_doesNotDeleteOtherUsersNote|yW0jK1lM2nO3pP4qR5sU|tests:2256")
    void deletePersonalNote_doesNotDeleteOtherUsersNote() throws Exception {
        mockMvc.perform(delete(API_PERSONAL_NOTES + "/train-12345"))
            .andExpect(status().isNoContent());

        assertThat(personalNoteRepository.findByOidAndKey("test-oid", "train-12345")).isEmpty();
        assertThat(personalNoteRepository.findByOidAndKey("other-oid", "train-12345")).isPresent();
    }
}
