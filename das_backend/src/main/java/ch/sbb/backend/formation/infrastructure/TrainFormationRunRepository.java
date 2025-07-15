package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainFormationRunRepository extends ListCrudRepository<TrainFormationRunEntity, Integer> {

    TrainFormationRunEntity findByModifiedDateTimeAndOperationalTrainNumberAndOperationalDayAndCompanyAndTafTapLocationReferenceStartAndTafTapLocationReferenceEnd(
        OffsetDateTime modifiedDateTime,
        String operationalTrainNumber,
        LocalDate operationalDay,
        String company,
        String tafTapLocationReferenceStart,
        String tafTapLocationReferenceEnd
    );
}
