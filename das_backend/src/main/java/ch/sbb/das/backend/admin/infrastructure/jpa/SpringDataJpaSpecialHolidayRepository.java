package ch.sbb.das.backend.admin.infrastructure.jpa;

import java.time.LocalDate;
import java.util.List;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaSpecialHolidayRepository extends ListCrudRepository<SpecialHolidayEntity, Integer> {

    List<SpecialHolidayEntity> findAllByDateGreaterThanEqualOrderByDate(LocalDate dateAfter);
}

