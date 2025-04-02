package ch.sbb.backend.common;

import jakarta.servlet.http.HttpServletRequest;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.event.Level;
import org.springframework.http.HttpHeaders;
import org.springframework.util.StopWatch;

public class RequestLogger {

    private static final Logger log = LoggerFactory.getLogger(RequestLogger.class);
    private final StopWatch stopWatch;
    private final Level level;

    public RequestLogger(StopWatch stopWatch, Level level) {
        this.stopWatch = stopWatch;
        this.level = level;
    }

    public static RequestLogger from(HttpServletRequest request) {
        Level level = request.getRequestURI().startsWith("/actuator") ? Level.DEBUG : Level.INFO;
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        return new RequestLogger(stopWatch, level);
    }

    public void log(HttpServletRequest request, Integer httpStatusCode) {
        stopWatch.stop();
        if (request == null) {
            return;
        }
        String params = request.getParameterMap().entrySet().stream()
            .map(entry -> entry.getKey() + ":" + String.join(",", entry.getValue()))
            .collect(Collectors.joining("&"));

        var loggingEventBuilder = log.atLevel(level);
        loggingEventBuilder.log("Request path=" + request.getRequestURI() + ", " +
            "requestId=" + request.getRequestId() + ", " +
            "method=" + request.getMethod() + ", " +
            "query=" + params + ", " +
            "user_agent=" + request.getHeader(HttpHeaders.USER_AGENT) + ", " +
            "responseStatusCode=" + httpStatusCode + ", " +
            "runTimeMs=" + stopWatch.getTotalTimeMillis());
    }
}

