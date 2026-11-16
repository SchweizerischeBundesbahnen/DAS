package ch.sbb.das.backend.common.error;

import org.springframework.http.HttpStatus;

/**
 * 413: the request payload exceeds an allowed size.
 */
public class PayloadTooLargeException extends ProblemException {

    public PayloadTooLargeException(String detail) {
        super(HttpStatus.CONTENT_TOO_LARGE, HttpStatus.CONTENT_TOO_LARGE.getReasonPhrase(), detail);
    }
}
