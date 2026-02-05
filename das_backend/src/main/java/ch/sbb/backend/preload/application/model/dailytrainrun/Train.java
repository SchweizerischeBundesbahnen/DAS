package ch.sbb.backend.preload.application.model.dailytrainrun;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@Getter
public class Train {

    @NonNull
    String eventType;

    @NonNull
    String pathId;

    @NonNull
    Integer period;

    @NonNull
    String trainNumber;

    @NonNull
    String infrastructureNet;

    @NonNull
    String orderingRU;

    @JsonProperty("trainRuns")
    @NonNull
    @Builder.Default
    List<TrainRun> trainRuns = List.of();
}
