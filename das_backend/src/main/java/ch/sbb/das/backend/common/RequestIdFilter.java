package ch.sbb.das.backend.common;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.apache.commons.lang3.StringUtils;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Echoes the consumer given {@link ApiParametersDefault#HEADER_REQUEST_ID} on every response (success, {@link Problem}, security rejections), so controllers do not have to wire it
 * manually.
 * <p>
 * Runs before Spring Security and sets the header before the response is committed.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestIdFilter extends OncePerRequestFilter {

    static final int MAX_LENGTH = 128;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        final String requestId = sanitize(request.getHeader(ApiParametersDefault.HEADER_REQUEST_ID));
        if (requestId != null) {
            response.setHeader(ApiParametersDefault.HEADER_REQUEST_ID, requestId);
        }
        filterChain.doFilter(request, response);
    }

    /**
     * The value is echoed and logged, therefore only printable ASCII is accepted and its length is limited (consumers must expect a truncated prefix).
     *
     * @return null if absent or not acceptable
     */
    static String sanitize(String requestId) {
        if (StringUtils.isBlank(requestId)) {
            return null;
        }
        final String trimmed = StringUtils.truncate(requestId.strip(), MAX_LENGTH);
        return StringUtils.isAsciiPrintable(trimmed) ? trimmed : null;
    }
}
