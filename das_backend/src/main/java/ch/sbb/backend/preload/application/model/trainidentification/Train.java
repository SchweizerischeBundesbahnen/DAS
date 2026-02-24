package ch.sbb.backend.preload.application.model.trainidentification;

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
    String trainPathId;

    @NonNull
    Integer period;

    @NonNull
    String operationalTrainNumber;

    @JsonProperty("trainRuns")
    @NonNull
    @Builder.Default
    List<TrainRun> trainRuns = List.of();
}
