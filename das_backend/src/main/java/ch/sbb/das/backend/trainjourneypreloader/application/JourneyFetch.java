package ch.sbb.das.backend.trainjourneypreloader.application;

import ch.sbb.das.backend.trainjourneyplan.TrainIdentification;
import ch.sbb.das.backend.trainjourneypreloader.domain.PreloadResult;

/**
 * Fetches the journey of a single train from TMS-VAD within a connected session. Segment Profiles the {@link SegmentProfileStore} already holds are not requested again.
 */
public interface JourneyFetch {

    void connect();

    PreloadResult preload(TrainIdentification trainId);

    void disconnect();
}
