package ch.sbb.das.backend.preload.domain;

import ch.sbb.das.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.das.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.das.backend.preload.sfera.model.v0300.TrainCharacteristics;
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
