package ch.sbb.das.backend.trainjourneyplan;

import ch.sbb.das.backend.companies.CompanyCode;
import java.time.OffsetDateTime;
import java.util.Set;
import lombok.NonNull;

public record TrainIdentification(@NonNull Integer id, @NonNull String operationalTrainNumber, @NonNull OffsetDateTime startDateTime, @NonNull Set<CompanyCode> companies) {

    public CompanyCode company() {
        return companies.stream().findFirst().orElseThrow(() -> new IllegalStateException("TrainIdentification must have at least one company"));
    }
}

