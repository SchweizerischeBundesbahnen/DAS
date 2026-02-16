package ch.sbb.backend.preload.application.model.trainidentification;

import java.util.List;
import java.util.Set;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@Getter
public class TrainRun {

    @NonNull
    List<TrainRunDate> trainRunDates;

    @NonNull
    Integer firstDepartureTime;

    @NonNull
    @Builder.Default
    Set<String> companies = Set.of();
}
