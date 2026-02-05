package ch.sbb.backend.preload.application.model.dailytrainrun;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.NonNull;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
public class TrainRunPoint {

    @NonNull
    @JsonProperty("op")
    OperationPoint operationPoint;

    @JsonProperty("oa")
    Integer operationalArrivalTime;

    @JsonProperty("od")
    Integer operationalDepartureTime;

    @JsonProperty("ca")
    Integer commercialArrivalTime;

    @JsonProperty("cd")
    Integer commercialDepartureTime;

    @NonNull
    @JsonProperty("ms")
    Boolean mandatoryStop;
}
