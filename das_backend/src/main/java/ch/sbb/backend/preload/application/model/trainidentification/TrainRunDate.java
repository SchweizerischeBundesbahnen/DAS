package ch.sbb.backend.preload.application.model.trainidentification;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@Getter
public class TrainRunDate {

    @NonNull
    LocalDate operationalDate;

    @NonNull
    OffsetDateTime startDateTime;

}
