package ch.sbb.das.backend.common.error;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.server.resource.web.BearerTokenAuthenticationEntryPoint;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;
import tools.jackson.databind.json.JsonMapper;

/**
 * Missing or rejected bearer token (usually 401): keeps the RFC 6750 {@code WWW-Authenticate} header of {@link BearerTokenAuthenticationEntryPoint} and adds a
 * {@link ch.sbb.das.backend.common.Problem} body.
 *
 * @see <a href="https://datatracker.ietf.org/doc/html/rfc6750#section-3">RFC 6750 section 3</a>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ProblemAuthenticationEntryPoint implements AuthenticationEntryPoint {

    static final String DETAIL = "Missing or invalid access token.";

    private final BearerTokenAuthenticationEntryPoint delegate = new BearerTokenAuthenticationEntryPoint();
    private final JsonMapper jsonMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException {
        // sets status (401, or 400/403 acc. to the bearer token error) and WWW-Authenticate
        delegate.commence(request, response, authException);
        final HttpStatus status = HttpStatus.valueOf(response.getStatus());
        log.info("{} authentication failed: {}, path={}", status, authException.getMessage(), request.getRequestURI());
        ProblemFactory.writeResponse(response, status, status.getReasonPhrase(), DETAIL, request, jsonMapper);
    }
}
