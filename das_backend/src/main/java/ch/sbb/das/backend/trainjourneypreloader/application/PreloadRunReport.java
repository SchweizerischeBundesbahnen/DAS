package ch.sbb.das.backend.trainjourneypreloader.application;

import java.time.Duration;

/**
 * Outcome of a single preload run.
 *
 * @param requested number of preload candidates selected for this run
 * @param processed number of candidates a journey fetch was attempted for
 * @param skipped number of candidates left for the next run
 * @param stopReason why the run stopped before processing all candidates, {@link StopReason#COMPLETED} otherwise
 */
public record PreloadRunReport(
    int requested,
    int processed,
    int succeeded,
    int unavailable,
    int errors,
    int timeouts,
    int skipped,
    StopReason stopReason,
    Duration duration
) {

    public enum StopReason {
        COMPLETED,
        TIME_BUDGET_EXCEEDED,
        INTERRUPTED
    }
}
