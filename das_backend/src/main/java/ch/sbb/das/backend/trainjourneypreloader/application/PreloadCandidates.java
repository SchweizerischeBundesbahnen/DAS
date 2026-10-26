package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;

/**
 * The trains a preload run still has to preload. A preload candidate is a train identification departing within the run's time window that is not yet marked preloaded. Candidates
 * are read at the start of a run with {@link #between} and, once their journeys are saved, recorded with {@link #markPreloaded} so later runs skip them.
 */
public interface PreloadCandidates {

    /**
     * @param from start of the departure window
     * @param to end of the departure window
     * @return train identifications within the window that are not yet marked preloaded, in the order they should be fetched
     */
    List<TrainIdentification> between(OffsetDateTime from, OffsetDateTime to);

    /**
     * Records the given train identifications as preloaded, so they are no longer returned as candidates.
     *
     * @param trainIdentificationIds ids of the train identifications whose journeys were saved
     */
    void markPreloaded(Set<Integer> trainIdentificationIds);
}
