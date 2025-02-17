package ch.sbb.sferamock.messages.model;

import lombok.NonNull;

public record TrainCharacteristicsIdentification(@NonNull String id, int majorVersion, int minorVersion, @NonNull CompanyCode ruId) {

}
