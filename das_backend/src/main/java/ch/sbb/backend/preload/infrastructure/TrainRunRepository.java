package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.infrastructure.model.entities.TrainRunViewEntity;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainRunRepository extends JpaRepository<TrainRunViewEntity, Long> {

    List<TrainRunViewEntity> findAllByStartDateBefore(LocalDate startDate);

}
