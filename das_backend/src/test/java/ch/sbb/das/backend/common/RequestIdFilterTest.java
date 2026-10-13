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
import org.junit.jupiter.api.DisplayName;
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
    @DisplayName("sanitize_absentOrBlank_null|1KOQPM5ubxIgJpihYPdI|tests:2649")
    void sanitize_absentOrBlank_null() {
        assertThat(RequestIdFilter.sanitize(null)).isNull();
        assertThat(RequestIdFilter.sanitize(" ")).isNull();
    }

    @Test
    @DisplayName("sanitize_printableAscii_keptTrimmed|QevES31UXc5SbGsb5luj|tests:2649")
    void sanitize_printableAscii_keptTrimmed() {
        assertThat(RequestIdFilter.sanitize(" " + REQUEST_ID + " ")).isEqualTo(REQUEST_ID);
    }

    @Test
    @DisplayName("sanitize_tooLong_truncatedPrefix|Gkr79LuJb7roPfBbYEkQ|tests:2649")
    void sanitize_tooLong_truncatedPrefix() {
        final String tooLong = "x".repeat(RequestIdFilter.MAX_LENGTH + 10);

        assertThat(RequestIdFilter.sanitize(tooLong)).isEqualTo(tooLong.substring(0, RequestIdFilter.MAX_LENGTH));
    }

    @Test
    @DisplayName("sanitize_nonPrintable_null|yGDMyAgzchk1iFheWxiC|tests:2649")
    void sanitize_nonPrintable_null() {
        assertThat(RequestIdFilter.sanitize("id\tinjected")).isNull();
        assertThat(RequestIdFilter.sanitize("id\ninjected")).isNull();
        assertThat(RequestIdFilter.sanitize("Zürich")).isNull();
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("ok_requestIdEchoed|xAk2Q506ot0yMzo9RuqR|tests:2649")
    void ok_requestIdEchoed() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isOk())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("ok_withoutRequestId_noHeader|inbgdJjI2JGzmDt7E5v3|tests:2649")
    void ok_withoutRequestId_noHeader() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES))
            .andExpect(status().isOk())
            .andExpect(header().doesNotExist(ApiParametersDefault.HEADER_REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("controllerNotFound_requestIdEchoed|a3ZSJ9DJAILaGW4eyeQ3|tests:2649")
    void controllerNotFound_requestIdEchoed() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES + "/nonexistent").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isNotFound())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN, adminTenant = false)
    @DisplayName("topLevelHandlerForbidden_requestIdEchoed|N0t179JvwIlw230k66vX|tests:2649")
    void topLevelHandlerForbidden_requestIdEchoed() throws Exception {
        mockMvc.perform(get(API_APP_VERSIONS).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isForbidden())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("topLevelHandlerBadRequest_requestIdEchoed|JPfJqxbT0GI26izgYCBf|tests:2649")
    void topLevelHandlerBadRequest_requestIdEchoed() throws Exception {
        mockMvc.perform(put(API_PERSONAL_NOTES + "/train-1").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{not json"))
            .andExpect(status().isBadRequest())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @DisplayName("securityUnauthorized_requestIdEchoed|GQIY7IDggLp9DtPcpvTk|tests:2649")
    void securityUnauthorized_requestIdEchoed() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isUnauthorized())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("unknownPath_requestIdEchoed|X78ull0dNiDm3VOpAn05|tests:2649")
    void unknownPath_requestIdEchoed() throws Exception {
        mockMvc.perform(get("/driver/v1/does-not-exist").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isNotFound())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }
}
