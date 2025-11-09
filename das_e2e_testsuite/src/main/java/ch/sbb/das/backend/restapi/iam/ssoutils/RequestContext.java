package ch.sbb.das.backend.restapi.iam.ssoutils;

import ch.sbb.das.backend.restapi.monitoring.MonitoringConstants;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Set;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.apache.commons.lang3.StringUtils;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.util.ContentCachingRequestWrapper;

/**
 * Request-Context
 * <p>
 * Headers of Requests are stored in this RequestContext. The Context is initialized on every Request.
 */
@Getter
@Builder
@ToString
@Deprecated
public class RequestContext {

    private final HttpServletRequest request;

    private ContentCachingRequestWrapper cachingRequestWrapper;

    private final HttpServletResponse response;

    /**
     * Consumer-Context.
     *
     * @see MonitoringConstants#HEADER_REQUEST_ID
     */
    private final String requestId;

    /**
     * Relative API path from base-path like "/v?/*" relevant for Problem::instance
     */
    private final String apiPath;

    /**
     * Relative API path from base-path like "/v?/"
     * <p>
     * Useful for monitoring
     */
    @Setter
    private String apiPathPattern;

    /**
     * APIM ClientId (developer.sbb.ch)
     */
    private final String clientId;

    /**
     * @see "<a href="https://portal.azure.com">APIM Azure Roles</a>
     */
    private final Set<String> roles;

    public MultiValueMap<String, String> getContent() {
        MultiValueMap<String, String> content = new LinkedMultiValueMap<>();

        if (StringUtils.isNotBlank(requestId)) {
            content.put(MonitoringConstants.HEADER_REQUEST_ID, List.of(requestId));
        }

        return content;
    }
}

