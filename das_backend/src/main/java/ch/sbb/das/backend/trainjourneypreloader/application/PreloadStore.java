package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.util.Collection;

/**
 * Persists the result of a preload run to the preload bucket.
 */
public interface PreloadStore {

    void save(Collection<JourneyProfile> journeyProfiles, Collection<SegmentProfile> segmentProfiles, Collection<TrainCharacteristics> trainCharacteristics);
}
