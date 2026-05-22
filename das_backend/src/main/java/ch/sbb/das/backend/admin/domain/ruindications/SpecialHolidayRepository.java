package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHoliday;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface SpecialHolidayRepository {

    List<SpecialHoliday> getAllUpcoming();

    List<SpecialHoliday> findAllByDate(LocalDate date);

    Optional<SpecialHoliday> findById(Integer id);

    List<SpecialHoliday> findAllById(Iterable<Integer> ids);

    SpecialHoliday save(SpecialHoliday specialHoliday);

    void deleteById(Integer id);

    void deleteAllById(Iterable<Integer> ids);
}

