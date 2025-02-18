package ch.sbb.sferamock.messages.model;

import lombok.NonNull;

public record SegmentIdentification(@NonNull String id, int majorVersion, int minorVersion, @NonNull CompanyCode zone) {

}
