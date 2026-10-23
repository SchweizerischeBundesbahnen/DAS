package ch.sbb.das.backend.common.error;

import org.springframework.http.HttpStatus;

/**
 * 400: the request is well-formed but refers to something that does not fit (for e.g. an unknown company), detected beyond bean validation.
 */
public class BadRequestException extends ProblemException {

    public BadRequestException(String detail) {
        super(HttpStatus.BAD_REQUEST, HttpStatus.BAD_REQUEST.getReasonPhrase(), detail);
    }
}
