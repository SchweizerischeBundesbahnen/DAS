package ch.sbb.das.backend.restapi.configuration;

import lombok.Builder;
import lombok.Value;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;

@Builder
@Value
@Slf4j
public class DasBackendEndpoint {

    String endpoint;
    String port;

    public String getEndpointAndPort() {
        return endpoint + (StringUtils.isBlank(port) ? "" : ":" + port);
    }

    /**
     * @return no APIM between
     */
    public boolean isLocalHost() {
        return getEndpoint().contains("localhost") || endpoint.contains("127.0.0.1");
    }

    public boolean isDev() {
        return getEndpoint().contains("-dev-");
    }
}
