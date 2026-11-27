package ch.sbb.das.backend.common.downstream;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * A downstream service called synchronously, configured in {@code downstream.clients} of {@code application.yaml}.
 */
@Getter
@RequiredArgsConstructor
public enum Downstream {
    GEMS("gems"),
    ORCA("orca"),
    ATLAS("atlas"),
    /**
     * Only its Entra ID token is fetched synchronously, the SFERA messages go over MQTT.
     */
    SFERA("sfera");

    /**
     * Value of {@link ch.sbb.das.backend.common.LogKeys#DOWNSTREAM}.
     */
    private final String logName;

    /**
     * Value of {@link ch.sbb.das.backend.common.LogKeys#DOWNSTREAM} when the Entra ID token call for this downstream failed.
     */
    public String getTokenLogName() {
        return logName + "-token";
    }
}
