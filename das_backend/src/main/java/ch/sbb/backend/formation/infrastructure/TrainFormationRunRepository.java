package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainFormationRunRepository extends ListCrudRepository<TrainFormationRunEntity, Integer> {

    List<TrainFormationRunEntity> findByOperationalTrainNumberAndOperationalDayAndCompanyOrderByInspectionDateTime(String operationalTrainNumber, LocalDate operationalDay, String company);
    
    void deleteByTrassenIdAndOperationalDay(String trassenId, LocalDate operationalDay);
}
