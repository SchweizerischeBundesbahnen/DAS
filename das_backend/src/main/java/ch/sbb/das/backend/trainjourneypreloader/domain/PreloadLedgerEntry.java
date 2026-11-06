package ch.sbb.das.backend.trainjourneypreloader.domain;

import java.time.OffsetDateTime;

/**
 * The part of a train's preload history in the train preload ledger that decides whether it is a preload candidate.
 *
 * @param attempts number of preload attempts so far
 * @param lastAttemptAt start of the preload run that made the last attempt, {@code null} if never attempted
 * @param preloadedAt when the journey was preloaded, {@code null} if not (yet) preloaded
 */
public record PreloadLedgerEntry(int attempts, OffsetDateTime lastAttemptAt, OffsetDateTime preloadedAt) {

    public static final PreloadLedgerEntry NEVER_ATTEMPTED = new PreloadLedgerEntry(0, null, null);

    public boolean isPreloaded() {
        return preloadedAt != null;
    }
}
