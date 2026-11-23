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

    /**
     * @param g2bCode G2B error code(s) TMS-VAD replied with, separated by {@code ", "}, {@code null} if the error came without G2B error codes
     */
    record Error(String message, Throwable ex, String g2bCode) implements PreloadResult {

        public Error(String message) {
            this(message, null, null);
        }

        public Error(String message, Throwable ex) {
            this(message, ex, null);
        }

        public static Error g2b(String message, String g2bCode) {
            return new Error(message, null, g2bCode.isEmpty() ? null : g2bCode);
        }
    }

    record Timeout(String message, Throwable ex) implements PreloadResult {

    }
}
