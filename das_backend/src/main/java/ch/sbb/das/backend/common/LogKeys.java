package ch.sbb.das.backend.common;

import lombok.experimental.UtilityClass;

/**
 * Key registry for structured log fields (MDC entries and key-value pairs), see {@code das_backend/CODING_STANDARDS.md}.
 * <p>
 * ECS names where ECS has one, camelCase domain names where it does not. A key is never put into the MDC and passed as key-value pair on the same line: the
 * ECS formatter rejects duplicate keys.
 */
@UtilityClass
public class LogKeys {

    // ECS
    public static final String HTTP_REQUEST_METHOD = "http.request.method";
    public static final String HTTP_RESPONSE_STATUS_CODE = "http.response.status_code";
    public static final String URL_PATH = "url.path";
    public static final String URL_QUERY = "url.query";
    public static final String USER_AGENT_ORIGINAL = "user_agent.original";

    // domain
    public static final String REQUEST_ID = "requestId";
    public static final String DURATION_MS = "durationMs";
    public static final String TRAIN_NUMBER = "trainNumber";
    public static final String OPERATIONAL_DAY = "operationalDay";
    public static final String ZIP_KEY = "zipKey";
    public static final String KAFKA_PARTITION = "kafka.partition";
    public static final String KAFKA_OFFSET = "kafka.offset";
    public static final String DOWNSTREAM_STATUS_CODE = "downstreamStatusCode";
    public static final String PROBLEM_TITLE = "problemTitle";
    public static final String PROBLEM_DETAIL = "problemDetail";
    public static final String REASON = "reason";
    public static final String RESOURCE = "resource";
    public static final String RESOURCE_ID = "resourceId";
}
