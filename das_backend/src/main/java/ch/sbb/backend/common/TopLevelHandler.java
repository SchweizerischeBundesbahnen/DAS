package ch.sbb.backend.common;

import java.io.IOException;
import java.net.URI;
import java.util.Arrays;
import java.util.Iterator;
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
    private static final String INSTANCE_FALLBACK="/v1/toplevel-error";
    // experimental -> Spring WebRequest::description prefix
    private static final String INSTANCE_PREFIX = "uri=";

    /**
     * Handle any unexpected {@link org.springframework.web.bind.annotation.RestController} failure based on Spring {@link ProblemDetail}.
     * @return wrapped {@link Problem}
     */
    @Override
    protected ResponseEntity<Object> handleExceptionInternal(@NotNull Exception ex, Object body, @NotNull HttpHeaders headers,
        @NotNull HttpStatusCode statusCode, @NotNull WebRequest request) {

        final ResponseEntity<Object> response = super.handleExceptionInternal(ex, body, headers, statusCode, request);
        if (response == null || !(response.getBody() instanceof ProblemDetail responseProblemDetail)) {
            log.warn("developer fault: Spring ProblemDetail not properly configured");
            return response;
        }

        Map<String, Object> customProperties = responseProblemDetail.getProperties();
        if (customProperties != null && !customProperties.isEmpty()) {
            log.warn("ProblemDetail::properties by Spring ignored yet: {}", customProperties);
        }

        HttpStatus status = HttpStatus.resolve(statusCode.value());
        if (status == null) {
            log.warn("Developer fault - HttpStatus unknown: {}", statusCode.value());
            status = HttpStatus.INTERNAL_SERVER_ERROR;
        }

        final Problem problem = ResponseEntityFactory.createProblem(
            status,
            StringUtils.isBlank(responseProblemDetail.getTitle()) ? UNEXPECTED_ERROR : responseProblemDetail.getTitle(),
            extractDetail(responseProblemDetail, request),
            extractInstance(responseProblemDetail, request)            );

        return new ResponseEntity<>(problem,
            ResponseEntityFactory.createProblemHeader(ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT, request.getHeader(ApiParametersDefault.HEADER_REQUEST_ID)),
            status);
    }

    private String extractDetail(ProblemDetail problemDetail, WebRequest request) {
        final StringBuilder builder = new StringBuilder();
        builder.append(StringUtils.isBlank(problemDetail.getDetail())? "<UNKNOWN>" : problemDetail.getDetail());
        builder.append(" -> params: ");
        Map<String, String[]> params = request.getParameterMap();
        if (!params.isEmpty()) {
            Iterator<String> i = request.getParameterNames();
            while (i.hasNext()) {
                String paramName = i.next();
                builder.append(paramName);
                builder.append("=");
                builder.append(Arrays.toString(params.get(paramName)));
                builder.append(";");
            }
        }
        return builder.toString();
    }

    private String extractInstance(ProblemDetail problemDetail, WebRequest request) {
        if (problemDetail.getInstance() != null) {
            return problemDetail.getInstance().toString();
        }
        if (StringUtils.isNotBlank(request.getContextPath())) {
            return request.getContextPath();
        }
        if (StringUtils.isNotBlank(request.getDescription(false))) {
            String instance = request.getDescription(false);
            if (instance.startsWith(INSTANCE_PREFIX)) {
                return instance.substring(INSTANCE_PREFIX.length());
            }
        }

        return INSTANCE_FALLBACK;
    }

    /**
     * Handle any unexpected failure which is not thrown by {@link #handleExceptionInternal(Exception, Object, HttpHeaders, HttpStatusCode, WebRequest)}
     * @return wrapped {@link Problem} 500
     */
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
        return createProblemResponse(HttpStatus.INTERNAL_SERVER_ERROR, UNEXPECTED_ERROR, "no explanation yet", exception);
    }

    private ResponseEntity<Problem> createDeveloperFaultResponse(@NonNull String detail, Throwable exceptionToLog) {
        return createProblemResponse(HttpStatus.INTERNAL_SERVER_ERROR, "Developer error", detail, exceptionToLog);
    }

    /**
     * @see <a href="https://stackoverflow.com/questions/2411487/nullpointerexception-in-java-with-no-stacktrace">StackTraces are given only a few times, then nulled to optimize performance and
     *     logs</a>
     */
    private ResponseEntity<Problem> createProblemResponse(HttpStatus status, String title, String detail, Throwable internalExceptionToLog) {
        final String apiPath = INSTANCE_FALLBACK; // TODO requestContext.getApiPath();
        //final String traceId = getTraceId(); //TODO io.micrometer.tracing.Tracer -> tracer.currentTraceContext().context().traceId();
        final String requestId = null; // TODO requestContext.getRequestId();

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
