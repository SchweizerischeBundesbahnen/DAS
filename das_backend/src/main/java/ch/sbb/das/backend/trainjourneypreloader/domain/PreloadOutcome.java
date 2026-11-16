package ch.sbb.das.backend.trainjourneypreloader.domain;

/**
 * The kind of {@link PreloadResult} a preload attempt ended with, without its payload.
 */
public enum PreloadOutcome {
    SUCCESS,
    UNAVAILABLE,
    ERROR,
    TIMEOUT;

    public static PreloadOutcome of(PreloadResult result) {
        return switch (result) {
            case PreloadResult.Success _ -> SUCCESS;
            case PreloadResult.Unavailable _ -> UNAVAILABLE;
            case PreloadResult.Error _ -> ERROR;
            case PreloadResult.Timeout _ -> TIMEOUT;
        };
    }
}
