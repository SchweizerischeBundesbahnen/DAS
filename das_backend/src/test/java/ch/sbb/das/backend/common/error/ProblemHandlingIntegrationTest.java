package ch.sbb.das.backend.common.error;

import static ch.sbb.das.backend.appversions.internal.AppVersionController.API_APP_VERSIONS;
import static ch.sbb.das.backend.cargo.api.v1.TransportPaperController.API_TRANSPORT_PAPERS;
import static ch.sbb.das.backend.features.internal.RuFeatureController.API_RU_FEATURES;
import static ch.sbb.das.backend.personalnotes.internal.PersonalNoteController.API_PERSONAL_NOTES;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.hamcrest.Matchers.startsWith;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.WithMockRole;
import ch.sbb.das.backend.cargo.infrastructure.TransportPaperClient;
import ch.sbb.das.backend.common.security.UserRole;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.web.client.RestClientResponseException;

/**
 * Every error response produced by the backend is a consistent {@link ch.sbb.das.backend.common.Problem}, whether raised by Spring Security, Spring MVC or a controller.
 */
@IntegrationTest
class ProblemHandlingIntegrationTest {

    private static final String TRACE_ID = "4bf92f3577b34da6";
    private static final String TRANSPORT_PAPER_PATH = API_TRANSPORT_PAPERS + "/33014-021/2026-01-30";

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    TransportPaperClient transportPaperClient;

    @AfterEach
    void clearMdc() {
        MDC.remove(ProblemFactory.MDC_INSTANA_TRACE_ID);
    }

    private static void expectProblem(ResultActions result, HttpStatus status, String instance) throws Exception {
        result
            .andExpect(status().is(status.value()))
            .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON))
            .andExpect(header().string(HttpHeaders.CONTENT_LANGUAGE, "en"))
            .andExpect(jsonPath("$.status").value(status.value()))
            .andExpect(jsonPath("$.title").isNotEmpty())
            .andExpect(jsonPath("$.instance").value(instance));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("badRequest_malformedBody_isProblemWithTraceId|11TaHKegRPDQBAwCGJnV|tests:2650")
    void badRequest_malformedBody_isProblemWithTraceId() throws Exception {
        // the Instana agent puts the trace id into the MDC of the request thread
        MDC.put(ProblemFactory.MDC_INSTANA_TRACE_ID, TRACE_ID);

        final ResultActions result = mockMvc.perform(put(API_PERSONAL_NOTES + "/train-1")
            .contentType(MediaType.APPLICATION_JSON)
            .content("{not json"));

        expectProblem(result, HttpStatus.BAD_REQUEST, API_PERSONAL_NOTES + "/train-1");
        result.andExpect(jsonPath("$.traceId").value(TRACE_ID));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("notFound_untraced_isProblemWithoutTraceId|BCGlQqQKZCm6fl6cjaD4|tests:2650")
    void notFound_untraced_isProblemWithoutTraceId() throws Exception {
        final ResultActions result = mockMvc.perform(get(API_PERSONAL_NOTES + "/nonexistent"));

        expectProblem(result, HttpStatus.NOT_FOUND, API_PERSONAL_NOTES + "/nonexistent");
        result
            .andExpect(jsonPath("$.title").value(NotFoundException.TITLE))
            .andExpect(jsonPath("$.traceId").doesNotExist())
            .andExpect(jsonPath("$.type").doesNotExist());
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("notFound_unknownEndpoint_hasNoQueryParams|mUiTmke5OUElg6cjCRzq|tests:2650")
    void notFound_unknownEndpoint_hasNoQueryParams() throws Exception {
        final ResultActions result = mockMvc.perform(get("/v1/unknown").param("dummy", "VALUE"));

        expectProblem(result, HttpStatus.NOT_FOUND, "/v1/unknown");
        result.andExpect(jsonPath("$.detail", not(containsString("VALUE"))));
    }

    @Test
    @DisplayName("unauthorized_withoutToken_isProblemWithWwwAuthenticate|MSm6vMhiUdiiqyUh8h7d|tests:2650")
    void unauthorized_withoutToken_isProblemWithWwwAuthenticate() throws Exception {
        final ResultActions result = mockMvc.perform(get(API_APP_VERSIONS));

        expectProblem(result, HttpStatus.UNAUTHORIZED, API_APP_VERSIONS);
        result
            .andExpect(header().string(HttpHeaders.WWW_AUTHENTICATE, startsWith("Bearer")))
            .andExpect(jsonPath("$.title").value("Unauthorized"))
            .andExpect(jsonPath("$.detail").value(ProblemAuthenticationEntryPoint.DETAIL));
    }

    @Test
    @WithMockRole(roles = UserRole.OBSERVER)
    @DisplayName("forbidden_byUrlRule_isProblemWithWwwAuthenticate|LnEadky1ceHxyln5gj9g|tests:2650")
    void forbidden_byUrlRule_isProblemWithWwwAuthenticate() throws Exception {
        expectForbidden(mockMvc.perform(get(API_RU_FEATURES)), API_RU_FEATURES);
    }

    @Test
    @WithMockRole(roles = UserRole.ADMIN, adminTenant = false)
    @DisplayName("forbidden_byMethodSecurity_isProblemWithWwwAuthenticate|EXPlqenMexrk70p4c3AF|tests:2650")
    void forbidden_byMethodSecurity_isProblemWithWwwAuthenticate() throws Exception {
        expectForbidden(mockMvc.perform(get(API_APP_VERSIONS)), API_APP_VERSIONS);
    }

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO, adminTenant = false)
    @DisplayName("forbidden_byCompanyAuthorizer_isProblemWithWwwAuthenticate|ZatZEh58gGNAEZslnZhv|tests:2650")
    void forbidden_byCompanyAuthorizer_isProblemWithWwwAuthenticate() throws Exception {
        expectForbidden(performTransportPaper(), TRANSPORT_PAPER_PATH);
    }

    private static void expectForbidden(ResultActions result, String instance) throws Exception {
        expectProblem(result, HttpStatus.FORBIDDEN, instance);
        result
            .andExpect(header().string(HttpHeaders.WWW_AUTHENTICATE, containsString("insufficient_scope")))
            .andExpect(jsonPath("$.title").value("Forbidden"))
            .andExpect(jsonPath("$.detail").value(ProblemAccessDeniedHandler.DETAIL));
    }

    @Test
    @WithMockRole(roles = UserRole.RU_ADMIN)
    @Sql({"classpath:createCompaniesAndTenants.sql", "classpath:emptyRuFeatures.sql", "classpath:createRuFeatures.sql"})
    @DisplayName("conflict_duplicate_isProblem|Mn2xwMku8IiganjDJMk1|tests:2650")
    void conflict_duplicate_isProblem() throws Exception {
        final ResultActions result = mockMvc.perform(post(API_RU_FEATURES)
            .contentType(MediaType.APPLICATION_JSON)
            .content("""
                { "companyCode": "1111", "key": "WARNAPP", "enabled": false }
                """));

        expectProblem(result, HttpStatus.CONFLICT, API_RU_FEATURES);
        result.andExpect(jsonPath("$.detail", containsString("already exists")));
    }

    @Test
    @WithMockRole(roles = UserRole.DRIVER)
    @DisplayName("contentTooLarge_isProblem|dCsMsolklQeDyMsr3HwJ|tests:2650")
    void contentTooLarge_isProblem() throws Exception {
        final ResultActions result = mockMvc.perform(put(API_PERSONAL_NOTES + "/train-2")
            .contentType(MediaType.APPLICATION_JSON)
            .content("\"" + "a".repeat(16384) + "\""));

        expectProblem(result, HttpStatus.CONTENT_TOO_LARGE, API_PERSONAL_NOTES + "/train-2");
    }

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO)
    @DisplayName("internalServerError_hidesInternals|2R2R1FpYjD0wc66NjoGd|tests:2650")
    void internalServerError_hidesInternals() throws Exception {
        when(transportPaperClient.getDownloadUrl(any(), any(), any(), any(), any(), any())).thenThrow(new IllegalStateException("secret internal state"));

        final ResultActions result = performTransportPaper();

        expectProblem(result, HttpStatus.INTERNAL_SERVER_ERROR, TRANSPORT_PAPER_PATH);
        result
            .andExpect(jsonPath("$.detail").value(GlobalExceptionHandler.DETAIL_UNEXPECTED_ERROR))
            .andExpect(content().string(not(containsString("IllegalStateException"))))
            .andExpect(content().string(not(containsString("secret"))));
    }

    @Test
    @WithMockRole(roles = UserRole.SBB_CARGO)
    @DisplayName("badGateway_hidesDownstreamMessage|bG8tWy2pKqL4nR6sVx0Z|tests:2650")
    void badGateway_hidesDownstreamMessage() throws Exception {
        when(transportPaperClient.getDownloadUrl(any(), any(), any(), any(), any(), any()))
            .thenThrow(new RestClientResponseException("Message", 404, "Not found", null, "secret downstream body".getBytes(), null));

        final ResultActions result = performTransportPaper();

        expectProblem(result, HttpStatus.BAD_GATEWAY, TRANSPORT_PAPER_PATH);
        result
            .andExpect(jsonPath("$.title").value(GlobalExceptionHandler.TITLE_DOWNSTREAM_ERROR))
            .andExpect(jsonPath("$.detail").value("Downstream service responded with status 404."));
    }

    private ResultActions performTransportPaper() throws Exception {
        return mockMvc.perform(get(TRANSPORT_PAPER_PATH)
            .param("countryCodeIso", "CH")
            .param("locationPrimaryCode", "22137")
            .param("passIndex", "0"));
    }
}
