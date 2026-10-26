package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadResult;
import ch.sbb.das.backend.trainjourneypreloader.domain.SegmentProfileIdentification;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import java.util.Map;

/**
 * Fetches the journey of a single train from TMS-VAD within a connected session.
 */
public interface JourneyFetch {

    void connect();

    /**
     * @param segmentProfilesMap segment profiles already fetched in this run, which are not requested again
     */
    PreloadResult preload(TrainIdentification trainId, Map<SegmentProfileIdentification, SegmentProfile> segmentProfilesMap);

    void disconnect();
}
