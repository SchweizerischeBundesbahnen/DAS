package ch.sbb.das.backend.common.error;

import lombok.NonNull;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.ErrorResponseException;

/**
 * Base for failures a service or controller throws instead of building an error response itself. {@link GlobalExceptionHandler} turns it into a
 * {@link ch.sbb.das.backend.common.Problem} with the given status, title and detail.
 */
public abstract class ProblemException extends ErrorResponseException {

    protected ProblemException(@NonNull HttpStatus status, @NonNull String title, String detail) {
        super(status, createBody(status, title, detail), null);
    }

    /**
     * @return {@link ProblemDetail#getDetail()} only (instead of status and full body)
     */
    @Override
    public String getMessage() {
        return getBody().getDetail();
    }

    private static ProblemDetail createBody(HttpStatus status, String title, String detail) {
        final ProblemDetail body = ProblemDetail.forStatusAndDetail(status, detail);
        body.setTitle(title);
        return body;
    }
}
