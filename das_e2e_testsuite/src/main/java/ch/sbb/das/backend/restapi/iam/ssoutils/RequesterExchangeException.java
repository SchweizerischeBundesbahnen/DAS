package ch.sbb.das.backend.restapi.iam.ssoutils;

import java.io.Serial;
import lombok.Builder;
import lombok.Getter;
import org.springframework.http.HttpStatusCode;

/**
 * This Exception represents a failure in the exchange between client and server.
 * <p>
 * Allows decoupling of WebClient Error-Handling logic and content specific logic.
 *
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Builder
@Getter
public class RequesterExchangeException extends RuntimeException {

    @Serial private static final long serialVersionUID = 2223899992505125899L;

    private final Object rootResponse;
    private final String requestedUrl;
    private final String body;
    private final HttpStatusCode status;
    private final Throwable cause;

    @Override
    public String getMessage() {
        return status + " <- " + requestedUrl;
    }
}
