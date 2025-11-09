package ch.sbb.das.backend.restapi.iam.ssoutils;

import lombok.NonNull;
import lombok.experimental.UtilityClass;
import lombok.extern.slf4j.Slf4j;

/**
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Slf4j
@UtilityClass
public final class ExchangeConstants {

    /**
     * Timeout setting [ms] is critical for a correct interaction with middleware. It has a great impact in load-scenarios and end-user experience!
     * <ul>
     *     <li>Connect-Timeout is set to max 30s</li>
     *     <li>Read-Timeout is set to max 30s. However, a min. of 10s is recommended</li>
     * </ul>
     */
    public static final Integer DEFAULT_TIMEOUT_IN_MS = 30000;

    /**
     * Choose your timeouts wisely. Impact on cross system behaviour and end-consumer experience!
     *
     * @param timeout value greater 0 and limited by configured systems in chain
     * @param connectTimeout true: connect; false: read
     * @return timout value if acceptable
     */
    public static Integer restrictTimeout(@NonNull Integer timeout, boolean connectTimeout) {
        if (timeout <= 0) {
            throw new IllegalArgumentException("timeout (must be > 0)");
        }

        if (timeout > DEFAULT_TIMEOUT_IN_MS) {
            throw new IllegalArgumentException("timeout (> " + DEFAULT_TIMEOUT_IN_MS + "ms exceeds max timeout of middleware!)");
        } else {
            log.debug("{}-timeout configured to: {}[ms]", getExpression(connectTimeout), timeout);
            return timeout;
        }
    }

    private static String getExpression(boolean connectTimeout) {
        return connectTimeout ? "Connect" : "Read";
    }
}
