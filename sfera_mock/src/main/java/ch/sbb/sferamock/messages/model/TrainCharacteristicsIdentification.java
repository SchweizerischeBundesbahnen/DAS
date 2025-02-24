package ch.sbb.sferamock.messages.model;

import lombok.NonNull;

public record TrainCharacteristicsIdentification(@NonNull String id, String majorVersion, String minorVersion, @NonNull CompanyCode ruId) {

}
