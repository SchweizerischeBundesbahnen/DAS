package ch.sbb.sferamock.messages.model;

import lombok.NonNull;

public record SegmentIdentification(@NonNull String id, String majorVersion, String minorVersion, @NonNull CompanyCode zone) {

}
