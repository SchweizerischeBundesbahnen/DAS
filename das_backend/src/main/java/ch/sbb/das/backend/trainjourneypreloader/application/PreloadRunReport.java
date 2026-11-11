package ch.sbb.das.backend.trainjourneypreloader.application;

import java.time.Duration;
import java.util.Map;

/**
 * Outcome of a single preload run.
 *
 * @param requested number of preload candidates selected for this run
 * @param processed number of candidates a journey fetch was attempted for
 * @param skipped number of candidates left for the next run
 * @param deferred number of trains in the window the retry backoff held back, not part of {@code requested}
 * @param errorsByG2bCode number of errors per G2B error code; an error that came with several codes counts once for each of them
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
    int deferred,
    Map<String, Integer> errorsByG2bCode,
    StopReason stopReason,
    Duration duration
) {

    public enum StopReason {
        COMPLETED,
        TIME_BUDGET_EXCEEDED,
        INTERRUPTED
    }
}
