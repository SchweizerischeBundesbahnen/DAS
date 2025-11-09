package ch.sbb.das.backend.restapi.helper;

/**
 * Exception to be thrown if developer made a fault and could do better. (This might be useful in cases like "should not happen".)
 */
public class DeveloperException extends RuntimeException {

    public DeveloperException(String message) {
        super(message);
    }

    /**
     * Hopefully never called in operating mode.
     *
     * @param message hint for responsible developer
     * @param cause optional trigger reason
     */
    public DeveloperException(String message, Throwable cause) {
        super(message, cause);
    }
}
