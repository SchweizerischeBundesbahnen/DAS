package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.entities.TrainIdentificationEntity;
import jakarta.transaction.Transactional;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 * JPA repository for reading and querying the {@code train_identification} table.
 *
 * <p>Also provides targeted field updates such as marking entries as preloaded
 * ({@link #updatePreloadedAtByIds}).
 *
 * <p>For high-throughput batch writes (upserts and bulk deletes), see {@link TrainIdentificationBatchWriter}.
 */
@Repository
public interface TrainIdentificationRepository extends JpaRepository<TrainIdentificationEntity, Long> {

    List<TrainIdentificationEntity> findAllByStartDateTimeAfterAndStartDateTimeBeforeAndPreloadedAtNull(OffsetDateTime after, OffsetDateTime before);

    @Modifying
    @Transactional
    @Query("UPDATE TrainIdentificationEntity t SET t.preloadedAt = :timestamp WHERE t.id IN :ids")
    int updatePreloadedAtByIds(@Param("timestamp") OffsetDateTime timestamp, @Param("ids") Set<Integer> ids);
}
