package ch.sbb.das.backend.trainjourneypreloader.infrastructure;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.model.entities.TrainPreloadLedgerEntity;
import java.util.Collection;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainPreloadLedgerRepository extends JpaRepository<TrainPreloadLedgerEntity, Integer> {

    List<TrainPreloadLedgerEntity> findAllByTrainIdentificationIdIn(Collection<Integer> trainIdentificationIds);
}
