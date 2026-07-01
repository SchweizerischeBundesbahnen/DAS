package ch.sbb.das.backend.trainjourneypreloader.domain;

import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.JourneyProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.SegmentProfile;
import ch.sbb.das.backend.trainjourneypreloader.sfera.model.v0400.TrainCharacteristics;
import java.util.List;

public sealed interface PreloadResult {

    record Success(JourneyProfile jp, List<SegmentProfile> sps, List<TrainCharacteristics> tcs) implements PreloadResult {

    }

    record Unavailable() implements PreloadResult {

    }

    record Error(String message, Throwable ex) implements PreloadResult {

        public Error(String message) {
            this(message, null);
        }
    }
}
