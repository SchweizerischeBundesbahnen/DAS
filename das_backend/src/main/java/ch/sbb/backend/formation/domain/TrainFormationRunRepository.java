package ch.sbb.backend.formation.domain;

import ch.sbb.backend.formation.domain.model.TrainFormationRun;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public interface TrainFormationRunRepository {

    TrainFormationRun findByModifiedDateTimeAndOperationalTrainNumberAndOperationalDayAndCompanyAndTafTapLocationReferenceStartAndTafTapLocationReferenceEnd(
        OffsetDateTime modifiedDateTime,
        String operationalTrainNumber,
        LocalDate operationalDay,
        String company,
        String tafTapLocationReferenceStart,
        String tafTapLocationReferenceEnd
    );

    void save(TrainFormationRun trainFormationRun);
}
