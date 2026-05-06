package ch.sbb.das.backend.admin.domain.holidays;

import ch.sbb.das.backend.admin.application.holidays.model.Holiday;
import java.util.List;
import java.util.Optional;

public interface HolidayRepository {

    List<Holiday> findAll();

    Optional<Holiday> findById(Integer id);

    Holiday save(Holiday holiday);

    void deleteById(Integer id);

    void deleteAllById(Iterable<Integer> ids);
}

