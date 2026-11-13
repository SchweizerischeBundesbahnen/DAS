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

    /**
     * The only place that knows the wording for a resource addressed by id, e.g. {@code "Company with id 42 not found"}.
     *
     * @param resource human-readable resource name, e.g. {@code "Company"}
     * @param id the id the client addressed
     */
    public static NotFoundException forId(String resource, Object id) {
        return forIdentifier(resource, "id", id);
    }

    /**
     * Same wording as {@link #forId(String, Object)} for resources addressed by a key, e.g. {@code "Personal note with key foo not found"}.
     */
    public static NotFoundException forKey(String resource, Object key) {
        return forIdentifier(resource, "key", key);
    }

    private static NotFoundException forIdentifier(String resource, String identifierName, Object identifier) {
        return new NotFoundException(resource + " with " + identifierName + " " + identifier + " not found");
    }
}
