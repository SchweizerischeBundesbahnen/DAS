package ch.sbb.das.backend.common.error;

import org.springframework.http.HttpStatus;

/**
 * 404: the requested resource or query has no result.
 */
public class NotFoundException extends ProblemException {

    public static final String TITLE = "No results found";
    public static final String DETAIL_DEFAULT = "Refine your query parameters.";

    public NotFoundException() {
        this(DETAIL_DEFAULT);
    }

    public NotFoundException(String detail) {
        super(HttpStatus.NOT_FOUND, TITLE, detail);
    }
}
