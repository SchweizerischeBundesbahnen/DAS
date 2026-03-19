package ch.sbb.backend.proxy;

import ch.sbb.backend.proxy.model.request.CustomerOrientedDepartureSubscribe;
import java.time.Instant;

public record ProxySubscribeRequest(String messageId,
                                    String zugnr,
                                    String deviceId,
                                    String pushToken,
                                    Instant expiresAt,
                                    String evu,
                                    String type,
                                    boolean driver) {

    public static ProxySubscribeRequest from(CustomerOrientedDepartureSubscribe subscribe, String company) {
        return new ProxySubscribeRequest(subscribe.messageId(), subscribe.operationalTrainNumber(), subscribe.deviceId(), subscribe.pushToken(), subscribe.expiresAt(), company, subscribe.type(),
            subscribe.driver());
    }
}
