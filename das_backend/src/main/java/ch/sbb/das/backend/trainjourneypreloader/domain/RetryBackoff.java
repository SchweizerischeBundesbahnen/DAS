package ch.sbb.das.backend.trainjourneypreloader.domain;

import java.time.Duration;
import java.time.OffsetDateTime;

/**
 * A train whose preload attempts keep failing waits longer before its next attempt: {@code min(base × 2^(attempts−1), max)} after the last attempt. With the base equal to the
 * fetch-cron interval, a train that failed once is retried by the next run.
 */
public class RetryBackoff {

    /**
     * Absorbs scheduling jitter: runs one base interval apart may start a few milliseconds less than the base after each other.
     */
    private static final Duration TOLERANCE = Duration.ofSeconds(30);

    /**
     * 2^30 × any sensible base exceeds any sensible max, and stays far from {@link Duration} overflow.
     */
    private static final int MAX_DOUBLINGS = 30;

    private final Duration base;
    private final Duration max;

    public RetryBackoff(Duration base, Duration max) {
        this.base = base;
        this.max = max;
    }

    public boolean isDue(PreloadLedgerEntry entry, OffsetDateTime now) {
        if (entry.attempts() == 0) {
            return true;
        }
        OffsetDateTime dueAt = entry.lastAttemptAt().plus(waitAfter(entry.attempts())).minus(TOLERANCE);
        return !now.isBefore(dueAt);
    }

    private Duration waitAfter(int attempts) {
        Duration wait = base.multipliedBy(1L << Math.min(attempts - 1, MAX_DOUBLINGS));
        return wait.compareTo(max) > 0 ? max : wait;
    }
}
