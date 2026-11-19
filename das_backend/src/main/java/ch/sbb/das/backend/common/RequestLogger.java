package ch.sbb.das.backend.common;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.event.Level;
import org.springframework.http.HttpHeaders;
import org.springframework.util.StopWatch;

/**
 * One access line per request at its end. Method and path are already in the MDC ({@link RequestIdFilter}), so the line adds only what is known at the end.
 */
@Slf4j
public class RequestLogger {

    static final String MESSAGE = "Request handled";

    /**
     * Probes and actuator calls are logged at DEBUG only.
     */
    private static final String ACTUATOR_PATH_PREFIX = "/actuator";

    private final StopWatch stopWatch;
    private final Level level;

    public RequestLogger(StopWatch stopWatch, Level level) {
        this.stopWatch = stopWatch;
        this.level = level;
    }

    public static RequestLogger from(HttpServletRequest request) {
        final String path = request.getRequestURI();
        final Level level = path.startsWith(ACTUATOR_PATH_PREFIX) ? Level.DEBUG : Level.INFO;
        final StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        return new RequestLogger(stopWatch, level);
    }

    public void log(HttpServletRequest request, HttpServletResponse response) {
        stopWatch.stop();
        log.atLevel(level)
            .addKeyValue(LogKeys.URL_QUERY, request.getQueryString())
            .addKeyValue(LogKeys.HTTP_RESPONSE_STATUS_CODE, response.getStatus())
            .addKeyValue(LogKeys.USER_AGENT_ORIGINAL, request.getHeader(HttpHeaders.USER_AGENT))
            .addKeyValue(LogKeys.DURATION_MS, stopWatch.getTotalTimeMillis())
            .log(MESSAGE);
    }
}
