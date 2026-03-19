package ch.sbb.backend.proxy.model.request;

import java.time.Instant;
import java.time.LocalDate;

public record CustomerOrientedDepartureSubscribe(
    String messageId,
    String operationalTrainNumber,
    String company,
    LocalDate startDate,
    String deviceId,
    String pushToken,
    Instant expiresAt,
    String type,
    boolean driver
) {

}
