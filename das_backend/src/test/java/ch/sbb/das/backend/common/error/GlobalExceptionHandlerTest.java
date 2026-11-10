package ch.sbb.das.backend.common.error;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.common.Problem;
import java.io.IOException;
import java.util.List;
import org.hibernate.exception.SQLGrammarException;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.context.request.ServletWebRequest;
import tools.jackson.databind.json.JsonMapper;

// end-to-end behaviour see ProblemHandlingIntegrationTest
class GlobalExceptionHandlerTest {

    private static final String PATH = "/v1/dummy/42";

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler(JsonMapper.builder().build());
    private final MockHttpServletRequest request = new MockHttpServletRequest("GET", PATH);

    @Test
    void handleUnexpectedError_hidesInternals() {
        final ResponseEntity<Problem> entity = handler.handleUnexpectedError(new IOException("IO fault"), request);

        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(entity.getHeaders().getContentType()).isEqualTo(MediaType.APPLICATION_PROBLEM_JSON);
        final Problem problem = entity.getBody();
        assertThat(problem.getStatus()).isEqualTo(500);
        assertThat(problem.getTitle()).isEqualTo("Internal Server Error");
        assertThat(problem.getDetail()).isEqualTo(GlobalExceptionHandler.DETAIL_UNEXPECTED_ERROR);
        assertThat(problem.getInstance()).hasToString(PATH);
        assertThat(problem.getType()).isNull();
    }

    @Test
    void handleUnexpectedError_withInnerNullPointerException_hidesExceptionClass() {
        final ResponseEntity<Problem> entity = handler.handleUnexpectedError(new RuntimeException("Dummy fault", new NullPointerException("inner NP")), request);

        assertThat(entity.getBody().getTitle()).isEqualTo("Internal Server Error");
        assertThat(entity.getBody().getDetail()).isEqualTo(GlobalExceptionHandler.DETAIL_UNEXPECTED_ERROR)
            .doesNotContain("NullPointerException", "RuntimeException", "NP");
    }

    @Test
    void handleUnexpectedError_withSqlGrammarException_hidesExceptionClass() {
        final ResponseEntity<Problem> entity = handler.handleUnexpectedError(new SQLGrammarException("bad SQL", null), request);

        assertThat(entity.getBody().getDetail()).isEqualTo(GlobalExceptionHandler.DETAIL_UNEXPECTED_ERROR);
    }

    @Test
    void handleProxyClientError_keepsDownstreamStatusButNotMessage() {
        final ResponseEntity<Problem> entity = handler.handleProxyClientError(new ProxyClientException(HttpStatus.NOT_FOUND, "secret downstream details"), request);

        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.BAD_GATEWAY);
        assertThat(entity.getBody().getTitle()).isEqualTo(GlobalExceptionHandler.TITLE_DOWNSTREAM_ERROR);
        assertThat(entity.getBody().getDetail()).isEqualTo("Downstream service responded with status 404.");
    }

    @Test
    void handleDataIntegrityViolation_conflict() {
        final ResponseEntity<Problem> entity = handler.handleDataIntegrityViolation(new DataIntegrityViolationException("duplicate key"), request);

        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(entity.getBody().getTitle()).isEqualTo("Conflict");
        assertThat(entity.getBody().getDetail()).isEqualTo(GlobalExceptionHandler.DETAIL_CONCURRENT_MODIFICATION);
    }

    @Test
    void handleException_problemException_keepsStatusTitleAndDetail() throws Exception {
        final ResponseEntity<Object> entity = handler.handleException(new ConflictException("Version already exists"), new ServletWebRequest(request, new MockHttpServletResponse()));

        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(entity.getHeaders().getContentType()).isEqualTo(MediaType.APPLICATION_PROBLEM_JSON);
        final Problem problem = (Problem) entity.getBody();
        assertThat(problem.getTitle()).isEqualTo("Conflict");
        assertThat(problem.getDetail()).isEqualTo("Version already exists");
        assertThat(problem.getInstance()).hasToString(PATH);
    }

    @Test
    void handleException_springFailure_keepsHeadersAndHasNoParamsInDetail() throws Exception {
        request.setQueryString("dummy=VALUE");
        request.addParameter("dummy", "VALUE");

        final ResponseEntity<Object> entity = handler.handleException(new HttpRequestMethodNotSupportedException("PATCH", List.of("GET")),
            new ServletWebRequest(request, new MockHttpServletResponse()));

        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.METHOD_NOT_ALLOWED);
        assertThat(entity.getHeaders().getFirst(HttpHeaders.ALLOW)).isEqualTo("GET");
        final Problem problem = (Problem) entity.getBody();
        assertThat(problem.getDetail()).doesNotContain("dummy", "VALUE");
        assertThat(problem.getInstance()).as("without query").hasToString(PATH);
    }
}
