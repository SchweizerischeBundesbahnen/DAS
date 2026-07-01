package ch.sbb.das.backend.departures.internal;

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
