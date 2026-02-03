package ch.sbb.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import org.apache.catalina.connector.ClientAbortException;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

// Further tests see e2e ProblemHandlingTest
class TopLevelHandlerTest {

    private final TopLevelHandler handler = new TopLevelHandler();

    @Test
    void handleUnexpectedError() {
        final ResponseEntity<Problem> entity = handler.handleUnexpectedError(new IOException("IO fault"));
        assertThat(entity).isNotNull();
        assertThat(entity.getStatusCode().value()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR.value());
        Problem problem = entity.getBody();
        assertThat(problem.getStatus()).isEqualTo(500);
        assertThat(problem.getTitle()).isEqualTo("Unexpected error");
        assertThat(problem.getDetail()).startsWith("no explanation yet");
        assertThat(problem.getInstance()).isNotNull();
        assertThat(problem.getType()).isNull();
    }

    @Test
    void handleUnexpectedError_withInnerNullPointerException() {
        final ResponseEntity<Problem> entity = handler.handleUnexpectedError(new RuntimeException("Dummy fault", new NullPointerException("inner NP")));

        assertThat(entity).isNotNull();
        assertThat(entity.getStatusCode().value()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR.value());
        Problem problem = entity.getBody();
        assertThat(problem.getStatus()).isEqualTo(500);
        assertThat(problem.getTitle()).isEqualTo("Developer error");
        assertThat(problem.getDetail()).startsWith("about 'NP: RuntimeException'");
        assertThat(problem.getInstance()).isNotNull();
        assertThat(problem.getType()).isNull();
    }
}
