package ch.sbb.das.backend.useractivity.internal;

import static ch.sbb.das.backend.driversettings.internal.SettingsController.API_SETTINGS;
import static ch.sbb.das.backend.personalnotes.internal.PersonalNoteController.API_PERSONAL_NOTES;
import static ch.sbb.das.backend.userproperties.internal.UserPropertyController.API_USER_PROPERTIES;
import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
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
@Sql({"classpath:emptyUserActivity.sql", "classpath:emptyPersonalNotes.sql", "classpath:emptyUserProperties.sql"})
@SqlMergeMode(MergeMode.MERGE)
class UserActivityInterceptorIntegrationTest {

    private static final String TEST_OID = "test-oid";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserActivityRepository userActivityRepository;

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("getAllPersonalNotes_recordsUserActivity|VTcve2uhoUzq4uOdZOEx|tests:2133")
    void getAllPersonalNotes_recordsUserActivity() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES)).andExpect(status().isOk());

        assertThat(userActivityRepository.findByOid(TEST_OID)).isPresent();
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createPersonalNotes.sql")
    @DisplayName("getPersonalNoteByKey_recordsUserActivity|nmLMLJ2BOIu41Fsj8KiR|tests:2133")
    void getPersonalNoteByKey_recordsUserActivity() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES + "/train-12345")).andExpect(status().isOk());

        assertThat(userActivityRepository.findByOid(TEST_OID)).isPresent();
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("getAllUserProperties_recordsUserActivity|ZhZSBMPcYVjUqnkSWEBU|tests:2133")
    void getAllUserProperties_recordsUserActivity() throws Exception {
        mockMvc.perform(get(API_USER_PROPERTIES)).andExpect(status().isOk());

        assertThat(userActivityRepository.findByOid(TEST_OID)).isPresent();
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @Sql("classpath:createUserProperties.sql")
    @DisplayName("getUserPropertyByKey_recordsUserActivity|uD24ygHtKnkD2Zm8DD4o|tests:2133")
    void getUserPropertyByKey_recordsUserActivity() throws Exception {
        mockMvc.perform(get(API_USER_PROPERTIES + "/tourSystem")).andExpect(status().isOk());

        assertThat(userActivityRepository.findByOid(TEST_OID)).isPresent();
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("putRequest_doesNotRecordUserActivity|Kp9wRt3xLm2vQc7nHb1d|tests:2133")
    void putRequest_doesNotRecordUserActivity() throws Exception {
        mockMvc.perform(put(API_PERSONAL_NOTES + "/train-99999")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"text\": \"note\"}"))
            .andExpect(status().isOk());

        assertThat(userActivityRepository.findByOid(TEST_OID)).isEmpty();
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("otherRequest_doesNotRecordUserActivity|Clpeor4Kau31XV1YAsqK|tests:2133")
    void otherRequest_doesNotRecordUserActivity() throws Exception {
        mockMvc.perform(get(API_SETTINGS)
                .header("X-App-Version", "0.1.1")
                .contentType(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk());

        assertThat(userActivityRepository.findByOid(TEST_OID)).isEmpty();
    }
}
