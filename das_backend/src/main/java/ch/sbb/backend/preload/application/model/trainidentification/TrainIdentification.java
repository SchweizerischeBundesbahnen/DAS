package ch.sbb.backend.preload.application.model.trainidentification;

import java.time.LocalDate;
import java.util.Set;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@Getter
public class TrainIdentification {

    @NonNull
    String operationalTrainNumber;

    @NonNull
    LocalDate startDate;

    @NonNull
    @Builder.Default
    Set<CompanyCode> companies = Set.of();
}
