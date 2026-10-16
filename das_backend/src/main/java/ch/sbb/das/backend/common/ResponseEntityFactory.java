package ch.sbb.das.backend.common;

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

    public static final String TITLE_NOT_FOUND = "No results found";

    public static <R extends ApiResponse<?>> ResponseEntity<R> createOkResponse(@NonNull R body) {
        return createOkResponse(createOkHeaders(), body);
    }

    public static <R extends ApiResponse<?>> ResponseEntity<R> createOkResponse(@NonNull R body, Locale locale) {
        return createOkResponse(createOkHeaders(locale), body);
    }

    public static <R extends ApiResponse<?>> ResponseEntity<R> createOkResponse(HttpHeaders headers, @NonNull R hit) {
        return new ResponseEntity<>(hit, headers, HttpStatus.OK);
    }

    public static <R extends ApiResponse<?>> ResponseEntity<R> createCreatedResponse(@NonNull R body) {
        return createCreatedResponse(createOkHeaders(), body);
    }

    public static <R extends ApiResponse<?>> ResponseEntity<R> createCreatedResponse(@NonNull R body, Locale locale) {
        return createCreatedResponse(createOkHeaders(locale), body);
    }

    public static <R extends ApiResponse<?>> ResponseEntity<R> createCreatedResponse(HttpHeaders headers, @NonNull R body) {
        return new ResponseEntity<>(body, headers, HttpStatus.CREATED);
    }

    public static ResponseEntity<? extends Response> createNotFoundResponse() {
        return createNotFoundResponse(null);
    }

    public static ResponseEntity<? extends Response> createNotFoundResponse(String instance) {
        return createNotFoundResponse(TITLE_NOT_FOUND, "Refine your query parameters.", null, instance);
    }

    public static ResponseEntity<Problem> createNotFoundResponse(@NonNull String title, @NonNull String detail, Locale locale, String instance) {
        return createProblemResponse(HttpStatus.NOT_FOUND, title, detail, locale == null ? ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT : locale.getLanguage(), instance);
    }

    public static ResponseEntity<Void> createNoContentResponse() {
        return ResponseEntity.noContent().build();
    }

    public static ResponseEntity<Problem> createProblemResponse(HttpStatus status, String title, String detail, String language, String instance) {
        return new ResponseEntity<>(
            createProblem(status, title, detail, instance),
            createProblemHeader(StringUtils.isBlank(language) ? ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT : language),
            status);
    }

    public static HttpHeaders createOkHeaders() {
        return createOkHeaders(null);
    }

    public static HttpHeaders createOkHeaders(Locale locale) {
        return createHeaders(locale == null ? null : locale.getLanguage(), MediaType.APPLICATION_JSON_VALUE);
    }

    private static HttpHeaders createHeaders(String language, @NonNull String mediaType) {
        final HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_TYPE, mediaType);
        if (StringUtils.isNotBlank(language)) {
            headers.add(HttpHeaders.CONTENT_LANGUAGE, language);
        }
        return headers;
    }

    public static HttpHeaders createProblemHeader(String language) {
        return createHeaders(StringUtils.isEmpty(language) ? ApiDocumentation.HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT : language,
            MediaType.APPLICATION_PROBLEM_JSON_VALUE);
    }

    public static Problem createProblem(HttpStatusCode status, String title, String detail, String instance) {
        return Problem.builder()
            .status(status.value())
            .title(title)
            .detail(detail)
            .instance(instance == null ? null : URI.create(instance))
            .build();
    }
}
