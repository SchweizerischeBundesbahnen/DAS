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
 * Echoes the consumer given {@link #HEADER_REQUEST_ID} on every response (success, {@link Problem}, security rejections), so controllers do not have to wire it
 * manually.
 * <p>
 * Runs before Spring Security and sets the header before the response is committed.
 * <p>
 * Only printable ASCII is echoed, stripped and truncated to {@value #MAX_LENGTH} characters; any other value is dropped (see {@link #sanitize(String)}).
 * <p>
 * Unlike {@link RequestLoggingFilter} this is not a {@code @WebFilter}: filters picked up by {@code @ServletComponentScan} ignore {@link Order} and are registered with
 * {@link Ordered#LOWEST_PRECEDENCE}, i.e. after Spring Security, which writes 401/403 itself without ever reaching them. {@link RequestLogger} relies on this order too, since it
 * logs the value from the response header set here.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestIdFilter extends OncePerRequestFilter {

    /**
     * devOps relevant header:
     * <ul>
     *     <li>Instana-Tracing among a chane of Instana based Applications is maintained by introspection intrinsically.</li>
     *     <li>Splunk logging</li>
     * </ul>
     * <p>
     *
     * @see <a href="https://www.instana.com/docs/ecosystem/opentelemetry/">OpenTelemtry</a>
     * @see <a href="https://confluence.sbb.ch/display/MON/Instana+-+HTTP+Header+Whitelist">Request-ID</a>
     */
    public static final String HEADER_REQUEST_ID = "Request-ID";

    static final int MAX_LENGTH = 256;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        final String requestId = sanitize(request.getHeader(HEADER_REQUEST_ID));
        if (requestId != null) {
            response.setHeader(HEADER_REQUEST_ID, requestId);
        }
        filterChain.doFilter(request, response);
    }

    /**
     * The value is echoed and logged, therefore only printable ASCII is accepted and its length is limited to {@value #MAX_LENGTH} characters (consumers must expect a truncated prefix).
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
