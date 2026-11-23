package ch.sbb.das.backend.trainjourneypreloader.domain;

/**
 * One fetch of one train's journey within a preload run.
 *
 * @param g2bCode G2B error code(s) TMS-VAD replied with, {@code null} if none
 */
public record PreloadAttempt(int trainIdentificationId, PreloadOutcome outcome, String g2bCode) {

    public static PreloadAttempt of(int trainIdentificationId, PreloadResult result) {
        String g2bCode = result instanceof PreloadResult.Error error ? error.g2bCode() : null;
        return new PreloadAttempt(trainIdentificationId, PreloadOutcome.of(result), g2bCode);
    }
}
