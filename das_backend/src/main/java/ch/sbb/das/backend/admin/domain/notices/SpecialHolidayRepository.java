package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.SpecialHoliday;
import java.util.List;
import java.util.Optional;

public interface SpecialHolidayRepository {

    List<SpecialHoliday> findUpcoming();

    Optional<SpecialHoliday> findById(Integer id);

    List<SpecialHoliday> findAllById(Iterable<Integer> ids);

    SpecialHoliday save(SpecialHoliday specialHoliday);

    void deleteById(Integer id);

    void deleteAllById(Iterable<Integer> ids);
}

