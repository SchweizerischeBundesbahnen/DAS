package ch.sbb.backend.preload.domain;

import ch.sbb.backend.preload.sfera.model.v0300.JourneyProfile;
import ch.sbb.backend.preload.sfera.model.v0300.SegmentProfile;
import ch.sbb.backend.preload.sfera.model.v0300.TrainCharacteristics;
import java.util.Set;

public record PreloadResult(Set<JourneyProfile> jps, Set<SegmentProfile> sps, Set<TrainCharacteristics> tcs) {

}
