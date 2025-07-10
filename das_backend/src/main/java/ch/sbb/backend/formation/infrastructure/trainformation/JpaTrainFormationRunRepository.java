package ch.sbb.backend.formation.infrastructure.trainformation;

import ch.sbb.backend.formation.infrastructure.trainformation.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JpaTrainFormationRunRepository extends ListCrudRepository<TrainFormationRunEntity, Integer> {

    TrainFormationRunEntity findByModifiedDateTimeAndOperationalTrainNumberAndOperationalDayAndCompanyAndTafTapLocationReferenceStartAndTafTapLocationReferenceEnd(
        OffsetDateTime modifiedDateTime,
        String operationalTrainNumber,
        LocalDate operationalDay,
        String company,
        String tafTapLocationReferenceStart,
        String tafTapLocationReferenceEnd
    );
}
