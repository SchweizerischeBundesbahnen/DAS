package ch.sbb.das.backend.restapi.configuration;

import lombok.Builder;
import lombok.Value;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;

/**
 * Direct Openshift endpoint.
 */
@Builder
@Value
@Slf4j
public class DasBackendEndpoint {

    String endpoint;
    String port;
    /**
     * Holds information about the authorization-process
     */
    SSOConfiguration ssoConfiguration;

    public String getEndpointAndPort() {
        return endpoint + (StringUtils.isBlank(port) ? "" : ":" + port);
    }

    /**
     * @return no APIM between
     */
    public boolean isLocalHost() {
        return getEndpoint().contains("localhost");
    }

    /**
     * @return no APIM between
     */
    public boolean isDev() {
        return getEndpoint().contains(".dev.");
    }

    /**
     * @return true: APIM involved to verify token
     */
    public boolean isApim() {
        return !is(Stage.DEV) && (
            getEndpoint().contains("api.sbb.ch" /*external route*/)
                || getEndpoint().contains(".sbb-cloud.net")
                || getEndpoint().contains(".api.sbb.ch")
                || getEndpoint().contains(".sbb-aws.net")
        );
    }

    public boolean is(Stage... stages) {
        Stage currentStage = getCurrentStage();
        return ArrayUtils.contains(stages, currentStage);
    }

    public void assume(Stage... stages) {
        Stage currentStage = getCurrentStage();

        if (!ArrayUtils.contains(stages, currentStage)) {
            //TODO Assumptions.abort("expected stage in " + List.of(stages) + " but was " + currentStage);
        }
    }

    public void assumeNot(Stage... stages) {
        Stage currentStage = getCurrentStage();
        if (ArrayUtils.contains(stages, currentStage)) {
            //TODO Assumptions.abort("expected stage not in " + List.of(stages) + " but was " + currentStage);
        }
    }

    Stage getCurrentStage() {
        if (endpoint.contains("local") || endpoint.contains("127.0.0.1")) {
            return Stage.LOCAL;
        } else if (endpoint.contains(".dev.")) {
            return Stage.DEV;
        } else if (endpoint.contains(".int.") || endpoint.contains("-int-") || endpoint.contains("-test.")) {
            return Stage.INT;
        } else if (endpoint.contains("journey-service")) {
            return Stage.PROD;
        } else {
            log.warn("unrecognize stage in endpoint={}", endpoint);
            return null;
        }
    }

    public enum Stage {
        LOCAL, DEV, INT, PROD
    }
}
