package ch.sbb.backend.preload.application.model.dailytrainrun;

import java.time.LocalDate;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@Getter
public class TrainRunDate {

    @NonNull
    LocalDate operationalDate;

    @NonNull
    LocalDate startDate;

}
