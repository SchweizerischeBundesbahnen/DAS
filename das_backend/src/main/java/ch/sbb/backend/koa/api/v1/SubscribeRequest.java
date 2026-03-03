package ch.sbb.backend.koa.api.v1;

import java.time.Instant;

public record SubscribeRequest(
    String messageId,
    String zugnr,
    String deviceId,
    String pushToken,
    Instant expired,
    String evu,
    String type
) {

}
