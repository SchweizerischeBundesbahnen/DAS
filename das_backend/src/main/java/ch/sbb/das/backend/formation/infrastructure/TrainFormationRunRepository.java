package ch.sbb.das.backend.formation.infrastructure;

import ch.sbb.das.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainFormationRunRepository extends ListCrudRepository<TrainFormationRunEntity, Integer> {

    List<TrainFormationRunEntity> findByOperationalTrainNumberAndOperationalDayAndCompanyOrderByPositionAsc(String operationalTrainNumber, LocalDate operationalDay, String company);

    void deleteByTrainPathIdAndOperationalDay(String trainPathId, LocalDate operationalDay);

    void deleteByInspectionDateTimeBefore(OffsetDateTime before);
}
