package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

public class SegmentProfileMissingException extends Exception {

    public SegmentProfileMissingException(String message) {
        super(message);
    }
}
