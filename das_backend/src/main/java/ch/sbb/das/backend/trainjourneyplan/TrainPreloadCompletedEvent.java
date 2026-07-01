package ch.sbb.das.backend.trainjourneyplan;

import java.util.Set;
import lombok.NonNull;

public record TrainPreloadCompletedEvent(@NonNull Set<Integer> trainIdentificationIds) {
}

