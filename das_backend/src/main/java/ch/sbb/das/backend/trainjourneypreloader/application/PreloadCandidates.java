package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadAttempt;
import java.time.OffsetDateTime;
import java.util.Collection;
import java.util.List;

/**
 * The trains a preload run still has to preload. A preload candidate is a train identification departing within the run's time window that is not yet preloaded and is due under the
 * retry backoff. Candidates are read at the start of a run with {@link #between} and, once the run's journeys are saved, every attempt is recorded with {@link #recordAttempts} so later
 * runs skip preloaded trains and back off from failing ones.
 */
public interface PreloadCandidates {

    /**
     * @param from start of the departure window
     * @param to end of the departure window
     * @return the candidates within the window in the order they should be fetched, and how many trains in the window the retry backoff held back
     */
    Selection between(OffsetDateTime from, OffsetDateTime to);

    /**
     * Records the outcome of each attempt, so successful trains are no longer returned as candidates and failing ones are retried later.
     *
     * @param runStartedAt start of the preload run that made the attempts
     * @param attempts one attempt per train the run fetched
     */
    void recordAttempts(OffsetDateTime runStartedAt, Collection<PreloadAttempt> attempts);

    /**
     * @param trains candidates in fetch order
     * @param deferred number of not yet preloaded trains in the window that are not due under the retry backoff
     */
    record Selection(List<TrainIdentification> trains, int deferred) {

    }
}
