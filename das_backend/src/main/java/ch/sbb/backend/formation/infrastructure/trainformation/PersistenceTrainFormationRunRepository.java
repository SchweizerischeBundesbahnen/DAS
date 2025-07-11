package ch.sbb.backend.formation.infrastructure.trainformation;

import ch.sbb.backend.formation.domain.TrainFormationRunRepository;
import ch.sbb.backend.formation.domain.model.TrainFormationRun;
import ch.sbb.backend.formation.infrastructure.trainformation.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import org.springframework.stereotype.Component;

@Component
class PersistenceTrainFormationRunRepository implements TrainFormationRunRepository {

    private final JpaTrainFormationRunRepository trainFormationRunRepository;

    PersistenceTrainFormationRunRepository(JpaTrainFormationRunRepository trainFormationRunRepository) {
        this.trainFormationRunRepository = trainFormationRunRepository;
    }

    @Override
    public TrainFormationRun findByModifiedDateTimeAndOperationalTrainNumberAndOperationalDayAndCompanyAndTafTapLocationReferenceStartAndTafTapLocationReferenceEnd(
        OffsetDateTime modifiedDateTime, String operationalTrainNumber, LocalDate operationalDay, String company, String tafTapLocationReferenceStart, String tafTapLocationReferenceEnd) {
        return trainFormationRunRepository.findByModifiedDateTimeAndOperationalTrainNumberAndOperationalDayAndCompanyAndTafTapLocationReferenceStartAndTafTapLocationReferenceEnd(
            modifiedDateTime, operationalTrainNumber, operationalDay, company, tafTapLocationReferenceStart, tafTapLocationReferenceEnd).toTrainFormationRun();
    }

    @Override
    public void save(TrainFormationRun trainFormationRun) {
        trainFormationRunRepository.save(new TrainFormationRunEntity(trainFormationRun));
    }
}
