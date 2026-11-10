package ch.sbb.das.backend.common.error;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.oauth2.server.resource.web.access.BearerTokenAccessDeniedHandler;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;
import tools.jackson.databind.json.JsonMapper;

/**
 * 403 for an authenticated caller lacking permission: keeps the RFC 6750 {@code WWW-Authenticate} header of {@link BearerTokenAccessDeniedHandler} and adds a
 * {@link ch.sbb.das.backend.common.Problem} body.
 * <p>
 * Used for URL based rules (Spring Security filter chain) as well as for method security and {@link ch.sbb.das.backend.companies.CompanyAuthorizer} (via
 * {@link GlobalExceptionHandler}), so every 403 looks the same. The detail does not tell which role or company is missing.
 *
 * @see <a href="https://datatracker.ietf.org/doc/html/rfc6750#section-3">RFC 6750 section 3</a>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ProblemAccessDeniedHandler implements AccessDeniedHandler {

    static final String DETAIL = "Not allowed!";

    private final BearerTokenAccessDeniedHandler delegate = new BearerTokenAccessDeniedHandler();
    private final JsonMapper jsonMapper;

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException {
        // sets status 403 and WWW-Authenticate
        delegate.handle(request, response, accessDeniedException);
        log.info("{} access denied: {}, path={}", HttpStatus.FORBIDDEN, accessDeniedException.getMessage(), request.getRequestURI());
        ProblemFactory.writeResponse(response, HttpStatus.FORBIDDEN, HttpStatus.FORBIDDEN.getReasonPhrase(), DETAIL, request, jsonMapper);
    }
}
