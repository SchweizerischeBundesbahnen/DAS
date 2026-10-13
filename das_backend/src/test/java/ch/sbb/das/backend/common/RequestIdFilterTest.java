package ch.sbb.das.backend.common;

import static ch.sbb.das.backend.appversions.internal.AppVersionController.API_APP_VERSIONS;
import static ch.sbb.das.backend.personalnotes.internal.PersonalNoteController.API_PERSONAL_NOTES;
import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
class RequestIdFilterTest {

    private static final String REQUEST_ID = "shouldEcho[1] requestId=4711, rail";

    @Autowired
    private MockMvc mockMvc;

    @Test
    void sanitize_absentOrBlank_null() {
        assertThat(RequestIdFilter.sanitize(null)).isNull();
        assertThat(RequestIdFilter.sanitize(" ")).isNull();
    }

    @Test
    void sanitize_printableAscii_keptTrimmed() {
        assertThat(RequestIdFilter.sanitize(" " + REQUEST_ID + " ")).isEqualTo(REQUEST_ID);
    }

    @Test
    void sanitize_tooLong_truncatedPrefix() {
        final String tooLong = "x".repeat(RequestIdFilter.MAX_LENGTH + 10);

        assertThat(RequestIdFilter.sanitize(tooLong)).isEqualTo(tooLong.substring(0, RequestIdFilter.MAX_LENGTH));
    }

    @Test
    void sanitize_nonPrintable_null() {
        assertThat(RequestIdFilter.sanitize("id\tinjected")).isNull();
        assertThat(RequestIdFilter.sanitize("id\ninjected")).isNull();
        assertThat(RequestIdFilter.sanitize("Zürich")).isNull();
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void ok_requestIdEchoed() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isOk())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void ok_withoutRequestId_noHeader() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES))
            .andExpect(status().isOk())
            .andExpect(header().doesNotExist(ApiParametersDefault.HEADER_REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void controllerNotFound_requestIdEchoed() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES + "/nonexistent").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isNotFound())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN, adminTenant = false)
    void topLevelHandlerForbidden_requestIdEchoed() throws Exception {
        mockMvc.perform(get(API_APP_VERSIONS).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isForbidden())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void topLevelHandlerBadRequest_requestIdEchoed() throws Exception {
        mockMvc.perform(put(API_PERSONAL_NOTES + "/train-1").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{not json"))
            .andExpect(status().isBadRequest())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    void securityUnauthorized_requestIdEchoed() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isUnauthorized())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    void unknownPath_requestIdEchoed() throws Exception {
        mockMvc.perform(get("/driver/v1/does-not-exist").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isNotFound())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }
}
