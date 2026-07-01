package ch.sbb.das.backend.indications.internal;

import java.time.LocalDate;
import java.util.List;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpecialHolidayRepository extends ListCrudRepository<SpecialHolidayEntity, Integer> {

    List<SpecialHolidayEntity> findAllByDateGreaterThanEqualOrderByDate(LocalDate dateAfter);

    List<SpecialHolidayEntity> findAllByDate(LocalDate date);

    void deleteAllByDateLessThan(LocalDate date);
}

