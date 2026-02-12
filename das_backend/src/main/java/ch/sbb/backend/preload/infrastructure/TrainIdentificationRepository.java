package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.infrastructure.model.entities.TrainIdentificationEntity;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainIdentificationRepository extends JpaRepository<TrainIdentificationEntity, Long> {

    List<TrainIdentificationEntity> findAllByStartDateTimeBefore(OffsetDateTime startDate);

}
