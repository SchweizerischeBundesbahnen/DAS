package ch.sbb.das.backend.common.error;

import ch.sbb.das.backend.common.Problem;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.stream.Collectors;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.jspecify.annotations.Nullable;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.FieldError;
import org.springframework.validation.ObjectError;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;
import tools.jackson.databind.json.JsonMapper;

/**
 * Turns every failure thrown while handling a {@link org.springframework.web.bind.annotation.RestController} call into a {@link Problem} (via {@link ProblemFactory}):
 * <ul>
 *     <li>Spring MVC failures and {@link ProblemException}s (any {@link ErrorResponse}) keep their status, title and detail</li>
 *     <li>{@link AccessDeniedException} (method security, {@link ch.sbb.das.backend.companies.CompanyAuthorizer}) is answered like the security filter chain does</li>
 *     <li>5xx never expose internals: details are logged only and correlated by {@link Problem#getTraceId()}</li>
 * </ul>
 * Failures in the Spring Security filter chain never reach this handler, see {@link ProblemAuthenticationEntryPoint} and {@link ProblemAccessDeniedHandler}.
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    static final String TITLE_DOWNSTREAM_ERROR = "Downstream Service Error";
    static final String DETAIL_UNEXPECTED_ERROR = "An unexpected error occurred.";
    static final String DETAIL_CONCURRENT_MODIFICATION = "Resource was modified concurrently, please retry.";

    private final ProblemAccessDeniedHandler accessDeniedHandler;

    /**
     * Not injecting the {@link ProblemAccessDeniedHandler} bean keeps {@code @WebMvcTest} slices (which only pick up web components) working.
     */
    public GlobalExceptionHandler(JsonMapper jsonMapper) {
        this.accessDeniedHandler = new ProblemAccessDeniedHandler(jsonMapper);
    }

    /**
     * Single exit for all {@link ErrorResponse} based failures handled by {@link ResponseEntityExceptionHandler}, including {@link ProblemException} and
     * {@link org.springframework.web.server.ResponseStatusException}.
     */
    @Override
    protected ResponseEntity<Object> handleExceptionInternal(@NonNull Exception ex, @Nullable Object body, @NonNull HttpHeaders headers, @NonNull HttpStatusCode statusCode,
        @NonNull WebRequest request) {
        final ResponseEntity<Object> response = super.handleExceptionInternal(ex, body, headers, statusCode, request);
        if (response == null) {
            // response already committed
            return null;
        }

        final ProblemDetail problemDetail = (response.getBody() instanceof ProblemDetail pd) ? pd : null;
        final HttpStatus status = resolve(statusCode);
        final String title = (problemDetail == null) ? null : problemDetail.getTitle();
        final String detail = (problemDetail == null) ? null : problemDetail.getDetail();
        if (status.is5xxServerError()) {
            return toObject(createUnexpectedErrorResponse(status, ex, toServletRequest(request), response.getHeaders()));
        }

        log.info("{} title={}, detail={}, path={}", status, title, detail, toServletRequest(request).getRequestURI());
        return toObject(ProblemFactory.createResponse(status, StringUtils.defaultIfBlank(title, status.getReasonPhrase()), detail, toServletRequest(request),
            response.getHeaders()));
    }

    /**
     * Adds the failing fields to the detail.
     */
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(MethodArgumentNotValidException ex, @NonNull HttpHeaders headers, @NonNull HttpStatusCode status,
        @NonNull WebRequest request) {
        final String bindingErrors = ex.getBindingResult().getAllErrors().stream()
            .map(this::formatBindingError)
            .collect(Collectors.joining("; "));
        final String detail = StringUtils.defaultIfBlank(ex.getBody().getDetail(), "Validation failed");
        ex.getBody().setDetail(StringUtils.isBlank(bindingErrors) ? detail : detail + " -> " + bindingErrors);
        return handleExceptionInternal(ex, ex.getBody(), headers, status, request);
    }

    private String formatBindingError(ObjectError error) {
        if (error instanceof FieldError fieldError) {
            return fieldError.getField() + "=" + StringUtils.defaultIfBlank(fieldError.getDefaultMessage(), "invalid value");
        }
        return error.getObjectName() + "=" + StringUtils.defaultIfBlank(error.getDefaultMessage(), "invalid object");
    }

    /**
     * Covers {@link org.springframework.security.authorization.AuthorizationDeniedException} as well.
     */
    @ExceptionHandler(AccessDeniedException.class)
    void handleAccessDenied(AccessDeniedException exception, HttpServletRequest request, HttpServletResponse response) throws IOException {
        accessDeniedHandler.handle(request, response, exception);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    ResponseEntity<Problem> handleDataIntegrityViolation(DataIntegrityViolationException exception, HttpServletRequest request) {
        log.info("{} data integrity violation, path={}", HttpStatus.CONFLICT, request.getRequestURI(), exception);
        return ProblemFactory.createResponse(HttpStatus.CONFLICT, HttpStatus.CONFLICT.getReasonPhrase(), DETAIL_CONCURRENT_MODIFICATION, request);
    }

    @ExceptionHandler(ProxyClientException.class)
    ResponseEntity<Problem> handleProxyClientError(ProxyClientException exception, HttpServletRequest request) {
        log.warn("Proxy service returned {} with message: {}, path={}", exception.getStatusCode(), exception.getProxyErrorMessage(), request.getRequestURI(), exception);
        return ProblemFactory.createResponse(HttpStatus.BAD_GATEWAY, TITLE_DOWNSTREAM_ERROR,
            "Downstream service responded with status " + exception.getStatusCode().value() + ".", request);
    }

    /**
     * Any other failure, like a {@link NullPointerException} or a DB problem.
     */
    @ExceptionHandler(Exception.class)
    ResponseEntity<Problem> handleUnexpectedError(Exception exception, HttpServletRequest request) {
        return createUnexpectedErrorResponse(HttpStatus.INTERNAL_SERVER_ERROR, exception, request, HttpHeaders.EMPTY);
    }

    /**
     * @see <a href="https://stackoverflow.com/questions/2411487/nullpointerexception-in-java-with-no-stacktrace">StackTraces are given only a few times, then nulled to optimize performance and
     *     logs</a>
     */
    private ResponseEntity<Problem> createUnexpectedErrorResponse(HttpStatus status, Exception exception, HttpServletRequest request, HttpHeaders headers) {
        // see logback config for other log relevant params (like the Instana traceId)
        log.error("{} unexpected error, path={}", status, request.getRequestURI(), exception);
        return ProblemFactory.createResponse(status, status.getReasonPhrase(), DETAIL_UNEXPECTED_ERROR, request, headers);
    }

    private static HttpStatus resolve(HttpStatusCode statusCode) {
        final HttpStatus status = HttpStatus.resolve(statusCode.value());
        if (status == null) {
            log.warn("Developer fault - HttpStatus unknown: {}", statusCode.value());
            return HttpStatus.INTERNAL_SERVER_ERROR;
        }
        return status;
    }

    private static HttpServletRequest toServletRequest(WebRequest request) {
        return ((NativeWebRequest) request).getNativeRequest(HttpServletRequest.class);
    }

    @SuppressWarnings("unchecked")
    private static ResponseEntity<Object> toObject(ResponseEntity<? extends Problem> response) {
        return (ResponseEntity<Object>) (ResponseEntity<?>) response;
    }
}
