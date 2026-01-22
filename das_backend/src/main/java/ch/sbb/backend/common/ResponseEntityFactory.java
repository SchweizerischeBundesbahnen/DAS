package ch.sbb.backend.common;

import ch.sbb.backend.common.model.response.ApiResponse;
import ch.sbb.backend.common.model.response.Problem;
import java.net.URI;
import java.util.Locale;
import lombok.NonNull;
import lombok.experimental.UtilityClass;
import org.apache.commons.lang3.StringUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

@UtilityClass
public class ResponseEntityFactory {

    private static final String TITLE_NOT_FOUND = "Object not found";
    private static final URI TYPE = URI.create(ApiDocumentation.PROBLEM_TYPE);

    public static <R extends ApiResponse<?>> ResponseEntity<R> createOkResponse(@NonNull R body, Locale locale, String requestId) {
        return createOkResponse(createOkHeaders(locale, requestId), body);
    }

    public static <R extends ApiResponse<?>> ResponseEntity<R> createOkResponse(HttpHeaders headers, @NonNull R hit) {
        return new ResponseEntity<>(hit, headers, HttpStatus.OK);
    }

    public ResponseEntity<Problem> createNotFoundResponse(String requestId, String instance) {
        return createNotFoundResponse(TITLE_NOT_FOUND, "Refine your query parameters.", null, requestId, instance);
    }

    public static ResponseEntity<Problem> createNotFoundResponse(@NonNull String title, @NonNull String detail, Locale locale, String requestId, String instance) {
        return createProblemResponse(HttpStatus.NOT_FOUND, title, detail, locale == null ? ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT : locale.getLanguage(), requestId, instance);
    }

    static ResponseEntity<Problem> createProblemResponse(HttpStatus status, String title, String detail, String language, String requestId, String instance) {
        return new ResponseEntity<>(
            createProblem(status, title, detail, instance),
            createProblemHeader(StringUtils.isBlank(language) ? ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT : language, requestId),
            status);
    }

    public static HttpHeaders createOkHeaders(Locale locale, String requestId) {
        return createHeaders(locale == null ? null : locale.getLanguage(), requestId, MediaType.APPLICATION_JSON_VALUE);
    }

    private static HttpHeaders createHeaders(String language, String requestId, @NonNull String mediaType) {
        final HttpHeaders headers = createHeaders(requestId);
        headers.add(HttpHeaders.CONTENT_TYPE, mediaType);
        if (StringUtils.isNotBlank(language)) {
            headers.add(HttpHeaders.CONTENT_LANGUAGE, language);
        }
        return headers;
    }

    private static HttpHeaders createHeaders(String requestId) {
        final HttpHeaders headers = new HttpHeaders();
        if (StringUtils.isNotBlank(requestId)) {
            headers.add(MonitoringConstants.HEADER_REQUEST_ID, requestId);
        }
        return headers;
    }

    public static HttpHeaders createProblemHeader(String language, String requestId) {
        return createHeaders(StringUtils.isEmpty(language) ? ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT : language,
            requestId, MediaType.APPLICATION_PROBLEM_JSON_VALUE);
    }

    public static Problem createProblem(HttpStatusCode status, String title, String detail, String instance) {
        return Problem.builder()
            .type(TYPE)
            .status(status.value())
            .title(title)
            .detail(detail)
            .instance(instance == null ? null : URI.create(instance))
            .build();
    }
}
