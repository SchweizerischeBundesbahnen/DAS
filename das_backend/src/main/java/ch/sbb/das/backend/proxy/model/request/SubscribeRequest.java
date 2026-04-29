package ch.sbb.das.backend.proxy.model.request;

import java.time.Instant;

public record SubscribeRequest(
    String messageId,
    String zugnr,
    String deviceId,
    String pushToken,
    Instant expiresAt,
    String evu,
    String type,
    boolean driver
) {

}
