package ch.sbb.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.common.model.response.Problem;
import java.io.IOException;
import org.apache.catalina.connector.ClientAbortException;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

class TopLevelHandlerTest {

    private final TopLevelHandler handler = new TopLevelHandler();

    @Test
    void handleBadArguments() {
        final ResponseEntity<Problem> entity = handler.handleBadArguments(new IllegalArgumentException("Some validation fault"));
        assertThat(entity).isNotNull();
        assertThat(entity.getStatusCode().value()).isEqualTo(HttpStatus.BAD_REQUEST.value());
        Problem problem = entity.getBody();
        assertThat(problem.getStatus()).isEqualTo(400);
        assertThat(problem.getTitle()).isEqualTo("Bad Request");
        assertThat(problem.getDetail()).contains("Refine your arguments: Some validation fault");
        assertThat(problem.getType()).isNotNull();
        assertThat(problem.getInstance()).isNotNull();
    }

    @Test
    void handleUnexpectedError() {
        final ResponseEntity<Problem> entity = handler.handleUnexpectedError(new IOException("IO fault"));
        assertThat(entity).isNotNull();
        assertThat(entity.getStatusCode().value()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR.value());
        Problem problem = entity.getBody();
        assertThat(problem.getStatus()).isEqualTo(500);
        assertThat(problem.getTitle()).isEqualTo("Unexpected error");
        assertThat(problem.getDetail()).startsWith("about 'no explanation yet: IOException'");
        assertThat(problem.getType()).isNotNull();
        assertThat(problem.getInstance()).isNotNull();
    }

    @Test
    void handleIOError_ClientAbortException() {
        final ResponseEntity<Problem> entity = handler.handleIOError(new ClientAbortException("Broken Pipe"));

        assertThat(entity).isNotNull();
        assertThat(entity.getStatusCode().value()).isEqualTo(HttpStatus.GATEWAY_TIMEOUT.value());
        Problem problem = entity.getBody();
        assertThat(problem.getStatus()).isEqualTo(504);
        assertThat(problem.getTitle()).isEqualTo("Timeout");
        assertThat(problem.getDetail()).startsWith("about 'Client aborted (timeout) if not a temporary problem'");
        assertThat(problem.getType()).isNotNull();
        assertThat(problem.getInstance()).isNotNull();
    }

    @Test
    void handleIOError_IOExceptionWithInnerException() {
        final ResponseEntity<Problem> entity = handler.handleIOError(new IOException("IO fault", new ClientAbortException("Broken Pipe")));

        assertThat(entity).isNotNull();
        assertThat(entity.getStatusCode().value()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR.value());
        Problem problem = entity.getBody();
        assertThat(problem.getStatus()).isEqualTo(500);
        assertThat(problem.getTitle()).isEqualTo("Unexpected error");
        assertThat(problem.getDetail()).startsWith("about 'I/O: IOException'");
        assertThat(problem.getType()).isNotNull();
        assertThat(problem.getInstance()).isNotNull();
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
        assertThat(problem.getType()).isNotNull();
        assertThat(problem.getInstance()).isNotNull();
    }
}
