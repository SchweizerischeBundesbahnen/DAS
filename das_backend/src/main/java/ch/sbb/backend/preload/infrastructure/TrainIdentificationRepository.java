package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.infrastructure.model.entities.TrainIdentificationEntity;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainIdentificationRepository extends JpaRepository<TrainIdentificationEntity, Long> {

    List<TrainIdentificationEntity> findAllByStartDateTimeBefore(OffsetDateTime startDate);

    @Modifying
    @Transactional
    @Query("UPDATE TrainIdentificationEntity t SET t.preloadedAt = :timestamp WHERE t.id IN :ids")
    int updatePreloadedAtByIds(@Param("timestamp") OffsetDateTime timestamp, @Param("ids") Set<Integer> ids);
}
