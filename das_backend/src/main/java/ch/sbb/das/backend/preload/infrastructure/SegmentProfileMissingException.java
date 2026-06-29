package ch.sbb.das.backend.preload.infrastructure;

public class SegmentProfileMissingException extends RuntimeException {

    public SegmentProfileMissingException(String message) {
        super(message);
    }
}
