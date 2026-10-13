package ch.sbb.das.backend.common;

import static ch.sbb.das.backend.appversions.internal.AppVersionController.API_APP_VERSIONS;
import static ch.sbb.das.backend.personalnotes.internal.PersonalNoteController.API_PERSONAL_NOTES;
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
class RequestIdFilterIntegrationTest {

    private static final String REQUEST_ID = "0c6f3d2e-8a4b-4f1e-9b7d-2e5a1c9f4b83";

    @Autowired
    private MockMvc mockMvc;

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("doFilter_okResponse_echoesRequestId|xAk2Q506ot0yMzo9RuqR|tests:2649")
    void doFilter_okResponse_echoesRequestId() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isOk())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("doFilter_noRequestId_omitsHeader|inbgdJjI2JGzmDt7E5v3|tests:2649")
    void doFilter_noRequestId_omitsHeader() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES))
            .andExpect(status().isOk())
            .andExpect(header().doesNotExist(ApiParametersDefault.HEADER_REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("doFilter_controllerNotFound_echoesRequestId|a3ZSJ9DJAILaGW4eyeQ3|tests:2649")
    void doFilter_controllerNotFound_echoesRequestId() throws Exception {
        mockMvc.perform(get(API_PERSONAL_NOTES + "/nonexistent").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isNotFound())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN, adminTenant = false)
    @DisplayName("doFilter_topLevelHandlerForbidden_echoesRequestId|N0t179JvwIlw230k66vX|tests:2649")
    void doFilter_topLevelHandlerForbidden_echoesRequestId() throws Exception {
        mockMvc.perform(get(API_APP_VERSIONS).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isForbidden())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("doFilter_topLevelHandlerBadRequest_echoesRequestId|JPfJqxbT0GI26izgYCBf|tests:2649")
    void doFilter_topLevelHandlerBadRequest_echoesRequestId() throws Exception {
        mockMvc.perform(put(API_PERSONAL_NOTES + "/train-1").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID)
                .contentType(MediaType.APPLICATION_JSON)
                .content("{not json"))
            .andExpect(status().isBadRequest())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @DisplayName("doFilter_securityUnauthorized_echoesRequestId|GQIY7IDggLp9DtPcpvTk|tests:2649")
    void doFilter_securityUnauthorized_echoesRequestId() throws Exception {
        mockMvc.perform(post(API_APP_VERSIONS).header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isUnauthorized())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("doFilter_unknownPath_echoesRequestId|X78ull0dNiDm3VOpAn05|tests:2649")
    void doFilter_unknownPath_echoesRequestId() throws Exception {
        mockMvc.perform(get("/driver/v1/does-not-exist").header(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID))
            .andExpect(status().isNotFound())
            .andExpect(header().stringValues(ApiParametersDefault.HEADER_REQUEST_ID, REQUEST_ID));
    }
}
