package ch.sbb.das.backend.admin.infrastructure.jpa;

import java.time.LocalDate;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface SpringDataJpaRuIndicationRepository extends ListCrudRepository<RuIndicationEntity, Integer> {

    @Modifying
    @Transactional
    @Query(value = """
        delete from ru_indication ri
        where (
            select max((period ->> 'validTo')::date)
            from jsonb_array_elements(coalesce(ri.periods, '[]'::jsonb)) period
        ) < :cutoffDate
        """, nativeQuery = true)
    void deleteAllByLastPeriodBefore(@Param("cutoffDate") LocalDate cutoffDate);
}
