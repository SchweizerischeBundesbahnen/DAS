package ch.sbb.das.backend.preload.application.model.trainidentification;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@Getter
public class TrainRunDate {

    @NonNull
    LocalDate operatingDay;

    @NonNull
    OffsetDateTime startDateTime;

    @NonNull
    List<String> vehicleModes;

}
