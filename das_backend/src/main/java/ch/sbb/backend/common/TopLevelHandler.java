package ch.sbb.backend.common;

import ch.sbb.backend.common.model.response.Problem;
import java.io.IOException;
import java.util.Map;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.catalina.connector.ClientAbortException;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.hibernate.exception.SQLGrammarException;
import org.jetbrains.annotations.NotNull;
import org.springframework.dao.InvalidDataAccessResourceUsageException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageConversionException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
@Slf4j
public class TopLevelHandler extends ResponseEntityExceptionHandler {

    private static final String UNEXPECTED_ERROR = "Unexpected error";

    /**
     * Handles the exception thrown by Spring.
     */
    @Override
    protected ResponseEntity<Object> handleExceptionInternal(@NotNull Exception ex, Object body, @NotNull HttpHeaders headers,
        @NotNull HttpStatusCode statusCode, @NotNull WebRequest request) {

        ResponseEntity<Object> response = super.handleExceptionInternal(ex, body, headers, statusCode, request);
        if (response != null && response.getBody() instanceof ProblemDetail responseProblem) {
            Map<String, Object> customProperties = responseProblem.getProperties();
            if (customProperties != null && !customProperties.isEmpty()) {
                log.warn("custom properties of Spring's ProblemDetail will not be converted: {}", customProperties);
            }

            HttpStatus status = HttpStatus.resolve(statusCode.value());
            if (status == null) {
                log.warn("Developer fault - HttpStatus unknown: {}", statusCode.value());
                status = HttpStatus.INTERNAL_SERVER_ERROR;
            }
            ResponseEntity<Problem> responseEntity = createProblemResponse(status, responseProblem.getTitle(), responseProblem.getDetail(), ex);
            return new ResponseEntity<>(responseEntity.getBody(), responseEntity.getStatusCode());
        }
        return response;
    }

    // 400 Bad Request
    @ExceptionHandler(value = {IllegalArgumentException.class})
    ResponseEntity<Problem> handleBadArguments(IllegalArgumentException exception) {
        return createBadParamResponse(exception, HttpStatus.BAD_REQUEST.getReasonPhrase(), "Refine your arguments");
    }

    // 500
    @ExceptionHandler(value = {IOException.class})
    ResponseEntity<Problem> handleIOError(Exception exception) {
        if (exception instanceof ClientAbortException) {
            // might be caused by debugging -> timeout
            return createTimeoutResponse(getMaskedDetailMessage("Client aborted (timeout) if not a temporary problem", null), exception);
        }

        return createUnexpectedProblemResponse(getMaskedDetailMessage("I/O", exception), exception);
    }

    // 500
    @ExceptionHandler(value = {InvalidDataAccessResourceUsageException.class})
    ResponseEntity<Problem> handleDbDeploymentError(Exception exception) {
        if ((exception.getCause() != null) && (exception.getCause() instanceof SQLGrammarException)) {
            return createDeveloperFaultResponse(getMaskedDetailMessage("DB update not yet deployed.", null), exception);
        }

        return createUnexpectedProblemResponse(getMaskedDetailMessage("Invalid resource", exception), exception);
    }

    // 500
    @ExceptionHandler(value = {Exception.class})
    ResponseEntity<Problem> handleUnexpectedError(Exception exception) {
        if ((exception instanceof NullPointerException) || (exception.getCause() instanceof NullPointerException)) {
            return createDeveloperFaultResponse(getMaskedDetailMessage("NP", exception), exception);
        }
        if ((exception instanceof SQLGrammarException) || (exception.getCause() instanceof SQLGrammarException)) {
            // might happen if testing against an older db version (for e.g. develop tests call PROD environment, where latest schema updates are not deployed yet)
            return createDeveloperFaultResponse(getMaskedDetailMessage("internal DB problems", exception), exception);
        }
        if (exception instanceof HttpMessageConversionException) {
            // for e.g. no JSON constructor -> check @Builder vs @Data, #*ArgsConstructor
            return createDeveloperFaultResponse(getMaskedDetailMessage("internal mapping problem", exception), exception);
        }
        return createUnexpectedProblemResponse(getMaskedDetailMessage("no explanation yet", exception), exception);
    }

    private ResponseEntity<Problem> createBadParamResponse(Exception exception, @NonNull String param, @NonNull String fault) {
        Throwable rootCause = ExceptionUtils.getRootCause(exception);
        String detail = (exception == null) ? "" : ": " + exception.getMessage() + ((exception == rootCause) ? "" : ": " + rootCause.getMessage());
        return createProblemResponse(HttpStatus.BAD_REQUEST, param, fault + detail, null);
    }

    private ResponseEntity<Problem> createDeveloperFaultResponse(@NonNull String detail, Throwable exceptionToLog) {
        return createProblemResponse(HttpStatus.INTERNAL_SERVER_ERROR, "Developer error", detail, exceptionToLog);
    }

    private ResponseEntity<Problem> createTimeoutResponse(@NonNull String detail, @NonNull Throwable exceptionToLog) {
        return createProblemResponse(HttpStatus.GATEWAY_TIMEOUT, "Timeout", detail, exceptionToLog);
    }

    private ResponseEntity<Problem> createUnexpectedProblemResponse(@NonNull String detail, @NonNull Throwable exceptionToLog) {
        return createProblemResponse(HttpStatus.INTERNAL_SERVER_ERROR, UNEXPECTED_ERROR, detail, exceptionToLog);
    }

    /**
     * @see <a href="https://stackoverflow.com/questions/2411487/nullpointerexception-in-java-with-no-stacktrace">StackTraces are given only a few times, then nulled to optimize performance and
     *     logs</a>
     */
    private ResponseEntity<Problem> createProblemResponse(HttpStatus status, String title, String detail, Throwable internalExceptionToLog) {
        //TODO final RequestContext requestContext = requestContextHolder.getRequestContext();
        final String apiPath = "/v1/toplevel-error"; // requestContext.getApiPath();
        //final String traceId = getTraceId(); //TODO io.micrometer.tracing.Tracer -> tracer.currentTraceContext().context().traceId();
        final String requestId = null; // requestContext.getRequestId();

        if (status.is4xxClientError()) {
            log.info("{} title={}, detail={}, path={}", status, title, detail, apiPath, internalExceptionToLog);
        } else {
            // see logback.xml for other log relevant params
            log.error("{} title={}, detail={}, path={}", status, title, detail, apiPath, internalExceptionToLog);
        }
        return ResponseEntityFactory.createProblemResponse(status, title, detail, ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT, requestId, apiPath);
    }

    private String getMaskedDetailMessage(String about, Exception ex) {
        final String exceptionName = (ex == null) ? StringUtils.EMPTY : ": " + ex.getClass().getSimpleName();
        return "about '" + about + exceptionName + "' ";
    }
}
