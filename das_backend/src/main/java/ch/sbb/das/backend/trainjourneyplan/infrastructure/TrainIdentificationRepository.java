package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import ch.sbb.das.backend.trainjourneyplan.infrastructure.model.entities.TrainIdentificationEntity;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

/**
 * JPA repository for reading and querying the {@code train_identification} table.
 *
 * <p>For high-throughput batch writes (upserts and bulk deletes), see {@link TrainIdentificationBatchWriter}.
 */
@Repository
public interface TrainIdentificationRepository extends JpaRepository<TrainIdentificationEntity, Long> {

    List<TrainIdentificationEntity> findAllByStartDateTimeAfterAndStartDateTimeBefore(OffsetDateTime after, OffsetDateTime before);

    @Query(nativeQuery = true, value = """
        SELECT t.* FROM train_identification t
        WHERE t.operational_train_number = :operationalTrainNumber
          AND t.start_date_time >= :from
          AND t.start_date_time < :to
        """)
    List<TrainIdentificationEntity> findAllByStartDateTimeRangeAndOperationalTrainNumber(
        @Param("from") OffsetDateTime from, @Param("to") OffsetDateTime to, @Param("operationalTrainNumber") String operationalTrainNumber);
}
