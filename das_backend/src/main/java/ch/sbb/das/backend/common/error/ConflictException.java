package ch.sbb.das.backend.common.error;

import org.springframework.http.HttpStatus;

/**
 * 409: the request conflicts with the current state of a resource (for e.g. a duplicate).
 */
public class ConflictException extends ProblemException {

    public ConflictException(String detail) {
        super(HttpStatus.CONFLICT, HttpStatus.CONFLICT.getReasonPhrase(), detail);
    }
}
