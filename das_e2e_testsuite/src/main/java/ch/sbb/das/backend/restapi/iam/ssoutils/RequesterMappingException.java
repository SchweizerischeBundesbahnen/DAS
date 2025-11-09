package ch.sbb.das.backend.restapi.iam.ssoutils;

/**
 * This Exception represents failures while mapping responses to java objects.
 * <p>
 * Allows decoupling WebClient Error-Handling logic from underlying business knowledge.
 *
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
public class RequesterMappingException extends Exception {

    public RequesterMappingException(String text) {
        super(text);
    }

    public RequesterMappingException(String text, Exception ex) {
        super(text, ex);
    }

    public RequesterMappingException(String text, Throwable throwable) {
        super(text, throwable);
    }
}
