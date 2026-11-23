package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.util.Collection;

/**
 * Persists the journeys of a preload run to the preload bucket. Segment Profiles go through the {@link SegmentProfileStore}.
 */
public interface PreloadStore {

    void save(Collection<JourneyProfile> journeyProfiles, Collection<TrainCharacteristics> trainCharacteristics);
}
