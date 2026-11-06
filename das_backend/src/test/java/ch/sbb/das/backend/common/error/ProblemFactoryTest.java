package ch.sbb.das.backend.common.error;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.common.Problem;
import ch.sbb.das.backend.common.RequestIdFilter;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;

class ProblemFactoryTest {

    private static final String TRACE_ID = "4bf92f3577b34da6";

    @AfterEach
    void clearMdc() {
        MDC.remove(ProblemFactory.MDC_INSTANA_TRACE_ID);
    }

    @Test
    void createResponse_headersAndBody() {
        final ResponseEntity<Problem> response = ProblemFactory.createResponse(HttpStatus.NOT_FOUND, "notFound", "Pojo not found", new MockHttpServletRequest("GET", "/nowhere"));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(response.getHeaders().getContentType()).isEqualTo(MediaType.APPLICATION_PROBLEM_JSON);
        assertThat(response.getHeaders().getContentLanguage()).hasToString("en");
        assertThat(response.getHeaders().containsHeader(RequestIdFilter.HEADER_REQUEST_ID)).as("set centrally by RequestIdFilter").isFalse();
        final Problem problem = response.getBody();
        assertThat(problem.getStatus()).isEqualTo(404);
        assertThat(problem.getTitle()).isEqualTo("notFound");
        assertThat(problem.getDetail()).isEqualTo("Pojo not found");
        assertThat(problem.getInstance()).hasToString("/nowhere");
        assertThat(problem.getType()).isNull();
    }

    @Test
    void createProblem_instanceIsPathWithoutQuery() {
        final MockHttpServletRequest request = new MockHttpServletRequest("GET", "/v1/formations");
        request.setQueryString("operationalTrainNumber=123");

        final Problem problem = ProblemFactory.createProblem(HttpStatus.BAD_REQUEST, "Bad Request", null, request);

        assertThat(problem.getInstance()).hasToString("/v1/formations");
    }

    @Test
    void createProblem_withInstanaTrace_hasTraceId() {
        MDC.put(ProblemFactory.MDC_INSTANA_TRACE_ID, TRACE_ID);

        final Problem problem = ProblemFactory.createProblem(HttpStatus.BAD_REQUEST, "Bad Request", null, new MockHttpServletRequest("GET", "/v1/settings"));

        assertThat(problem.getTraceId()).isEqualTo(TRACE_ID);
    }

    @Test
    void createProblem_withoutInstanaTrace_hasNoTraceId() {
        final Problem problem = ProblemFactory.createProblem(HttpStatus.BAD_REQUEST, "Bad Request", null, new MockHttpServletRequest("GET", "/v1/settings"));

        assertThat(problem.getTraceId()).isNull();
    }
}
