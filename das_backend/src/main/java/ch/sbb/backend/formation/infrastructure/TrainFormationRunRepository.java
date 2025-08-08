package ch.sbb.backend.formation.infrastructure;

import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface TrainFormationRunRepository extends ListCrudRepository<TrainFormationRunEntity, Integer> {

    @Query("""
            SELECT t FROM train_formation_run t
            WHERE (t.tafTapLocationReferenceStart, t.tafTapLocationReferenceEnd, t.modifiedDateTime) IN (
                SELECT t2.tafTapLocationReferenceStart, t2.tafTapLocationReferenceEnd, MAX(t2.modifiedDateTime)
                FROM train_formation_run t2
                WHERE t2.operationalTrainNumber = :operationalTrainNumber
                  AND t2.operationalDay = :operationalDay
                  AND t2.company = :company
                GROUP BY t2.tafTapLocationReferenceStart, t2.tafTapLocationReferenceEnd
            )
            ORDER BY t.modifiedDateTime ASC
        """)
    List<TrainFormationRunEntity> findLastModifiedByTrainIdentifier(
        @Param("operationalTrainNumber") String operationalTrainNumber,
        @Param("operationalDay") LocalDate operationalDay,
        @Param("company") String company
    );
}
