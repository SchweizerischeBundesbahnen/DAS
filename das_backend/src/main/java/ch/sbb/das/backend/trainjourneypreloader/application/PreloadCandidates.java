package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;

/**
 * Source of the train identifications a preload run should fetch, and where successful preloads are recorded.
 */
public interface PreloadCandidates {

    /**
     * @return train identifications starting between {@code from} and {@code to} that are not yet marked preloaded, in the order they should be fetched
     */
    List<TrainIdentification> between(OffsetDateTime from, OffsetDateTime to);

    void markPreloaded(Set<Integer> trainIdentificationIds);
}
