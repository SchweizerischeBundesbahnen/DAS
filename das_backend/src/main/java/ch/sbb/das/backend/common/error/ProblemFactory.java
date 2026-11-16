package ch.sbb.das.backend.common.error;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.Problem;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URI;
import lombok.NonNull;
import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.MDC;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import tools.jackson.databind.json.JsonMapper;

/**
 * The only place creating {@link Problem} responses, whether raised by a controller ({@link GlobalExceptionHandler}) or by Spring Security
 * ({@link ProblemAuthenticationEntryPoint}, {@link ProblemAccessDeniedHandler}).
 * <p>
 * Fills the request related members consistently:
 * <ul>
 *     <li>{@link Problem#getInstance()}: the called path without query (parameters are logged by {@link ch.sbb.das.backend.common.RequestLogger} instead)</li>
 *     <li>{@link Problem#getTraceId()}: the Instana trace id, put into the {@link MDC} by the Instana agent attached on OpenShift (absent if not traced, e.g. locally)</li>
 * </ul>
 */
@Slf4j
@UtilityClass
public class ProblemFactory {

    /**
     * MDC key populated by the Instana Java agent for request scoped logs.
     *
     * @see <a href="https://www.ibm.com/docs/en/instana-observability?topic=technologies-monitoring-java-virtual-machine">Instana: MDC populated with the trace id</a>
     */
    public static final String MDC_INSTANA_TRACE_ID = "instana.trace.id";

    public static Problem createProblem(@NonNull HttpStatusCode status, String title, String detail, @NonNull HttpServletRequest request) {
        return Problem.builder()
            .status(status.value())
            .title(title)
            .detail(detail)
            .instance(toInstance(request))
            .traceId(StringUtils.trimToNull(MDC.get(MDC_INSTANA_TRACE_ID)))
            .build();
    }

    public static ResponseEntity<Problem> createResponse(@NonNull HttpStatusCode status, String title, String detail, @NonNull HttpServletRequest request) {
        return createResponse(status, title, detail, request, HttpHeaders.EMPTY);
    }

    /**
     * @param additionalHeaders given by the failure (for e.g. {@link HttpHeaders#ALLOW} on 405)
     */
    public static ResponseEntity<Problem> createResponse(@NonNull HttpStatusCode status, String title, String detail, @NonNull HttpServletRequest request,
        @NonNull HttpHeaders additionalHeaders) {
        final HttpHeaders headers = new HttpHeaders();
        headers.addAll(additionalHeaders);
        headers.set(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        headers.set(HttpHeaders.CONTENT_LANGUAGE, ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT);
        return new ResponseEntity<>(createProblem(status, title, detail, request), headers, status);
    }

    /**
     * For failures handled outside of Spring MVC (Spring Security filter chain), where no message converter writes the body. Headers already set on the response (like
     * {@link HttpHeaders#WWW_AUTHENTICATE}) are kept.
     */
    static void writeResponse(@NonNull HttpServletResponse response, @NonNull HttpStatusCode status, String title, String detail, @NonNull HttpServletRequest request,
        @NonNull JsonMapper jsonMapper) throws IOException {
        response.setStatus(status.value());
        response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        response.setHeader(HttpHeaders.CONTENT_LANGUAGE, ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT);
        jsonMapper.writeValue(response.getOutputStream(), createProblem(status, title, detail, request));
    }

    private static URI toInstance(HttpServletRequest request) {
        final String path = request.getRequestURI();
        if (StringUtils.isBlank(path)) {
            return null;
        }
        try {
            return URI.create(path);
        } catch (IllegalArgumentException e) {
            log.debug("Problem::instance omitted, request path is not a valid URI: {}", path);
            return null;
        }
    }
}
