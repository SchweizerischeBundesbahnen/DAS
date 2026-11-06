package ch.sbb.das.backend.common;

import java.util.Locale;
import lombok.NonNull;
import lombok.experimental.UtilityClass;
import org.apache.commons.lang3.StringUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

/**
 * Successful responses only; error responses are created by {@link ch.sbb.das.backend.common.error.ProblemFactory}.
 */
@UtilityClass
public class ResponseEntityFactory {

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

    public static ResponseEntity<Void> createNoContentResponse() {
        return ResponseEntity.noContent().build();
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
}
