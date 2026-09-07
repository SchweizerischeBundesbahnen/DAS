package ch.sbb.das.backend.userproperties.internal;

import static ch.sbb.das.backend.userproperties.internal.UserPropertyController.API_USER_PROPERTIES;
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
@Sql("classpath:emptyUserProperties.sql")
@SqlMergeMode(MergeMode.MERGE)
class UserPropertyControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserPropertyRepository userPropertyRepository;

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("getAllUserProperties_ok_returnsOnlyOwnProperties|aB1cD2eF3gH4iJ5kL6mN|tests:2258")
    void getAllUserProperties_ok_returnsOnlyOwnProperties() throws Exception {
        mockMvc.perform(get(API_USER_PROPERTIES))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(2)))
            .andExpect(jsonPath("$.data[?(@.key == 'tourSystem')]").exists())
            .andExpect(jsonPath("$.data[?(@.key == 'companyCodes')]").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("getUserPropertyByKey_ok|bC2dE3fG4hI5jK6lM7nO|tests:2258")
    void getUserPropertyByKey_ok() throws Exception {
        mockMvc.perform(get(API_USER_PROPERTIES + "/tourSystem"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].key", is("tourSystem")))
            .andExpect(jsonPath("$.data[0].value", is("tour1")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("getUserPropertyByKey_notFound|cD3eF4gH5iJ6kL7mN8oP|tests:2258")
    void getUserPropertyByKey_notFound() throws Exception {
        mockMvc.perform(get(API_USER_PROPERTIES + "/nonexistent"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("saveUserProperty_ok_createsNew|dE4fG5hI6jK7lM8nO9pQ|tests:2258")
    void saveUserProperty_ok_createsNew() throws Exception {
        mockMvc.perform(put(API_USER_PROPERTIES + "/tourSystem")
                .contentType(MediaType.APPLICATION_JSON)
                .content("\"tip\""))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].key", is("tourSystem")))
            .andExpect(jsonPath("$.data[0].value", is("tip")))
            .andExpect(jsonPath("$.data[0].lastModifiedAt").exists());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("saveUserProperty_ok_updatesExisting|eF5gH6iJ7kL8mN9oP0qR|tests:2258")
    void saveUserProperty_ok_updatesExisting() throws Exception {
        mockMvc.perform(put(API_USER_PROPERTIES + "/tourSystem")
                .contentType(MediaType.APPLICATION_JSON)
                .content("\"caros\""))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].key", is("tourSystem")))
            .andExpect(jsonPath("$.data[0].value", is("caros")));

        mockMvc.perform(get(API_USER_PROPERTIES + "/tourSystem"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data[0].value", is("caros")));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("saveUserProperty_payloadTooLarge_rejected|gH7iJ8kL9mN0oP1qR2sT|tests:2258")
    void saveUserProperty_payloadTooLarge_rejected() throws Exception {
        String oversizedValue = "\"" + "a".repeat(4096) + "\"";

        mockMvc.perform(put(API_USER_PROPERTIES + "/tourSystem")
                .contentType(MediaType.APPLICATION_JSON)
                .content(oversizedValue))
            .andExpect(status().isContentTooLarge());

        mockMvc.perform(get(API_USER_PROPERTIES + "/tourSystem"))
            .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("getAllUserProperties_unauthorized|fG6hI7jK8lM9nO0pQ1rS|tests:2258")
    void getAllUserProperties_unauthorized() throws Exception {
        mockMvc.perform(get(API_USER_PROPERTIES))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("deleteUserProperty_ok_removesOwnProperty|hI8jK9lM0nO1pQ2rS3tU|tests:2258")
    void deleteUserProperty_ok_removesOwnProperty() throws Exception {
        mockMvc.perform(delete(API_USER_PROPERTIES + "/tourSystem"))
            .andExpect(status().isNoContent());

        mockMvc.perform(get(API_USER_PROPERTIES + "/tourSystem"))
            .andExpect(status().isNotFound());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("deleteUserProperty_idempotent_whenKeyDoesNotExist|iJ9kL0mN1oP2qR3sT4uV|tests:2258")
    void deleteUserProperty_idempotent_whenKeyDoesNotExist() throws Exception {
        mockMvc.perform(delete(API_USER_PROPERTIES + "/nonexistent"))
            .andExpect(status().isNoContent());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("deleteUserProperty_doesNotDeleteOtherUsersProperty|jK0lM1nO2pP3qR4sT5uW|tests:2258")
    void deleteUserProperty_doesNotDeleteOtherUsersProperty() throws Exception {
        mockMvc.perform(delete(API_USER_PROPERTIES + "/tourSystem"))
            .andExpect(status().isNoContent());

        assertThat(userPropertyRepository.findByOidAndKey("test-oid", "tourSystem")).isEmpty();
        assertThat(userPropertyRepository.findByOidAndKey("other-oid", "tourSystem")).isPresent();
    }
}
