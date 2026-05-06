package ch.sbb.das.backend.admin.domain.holidays;

import ch.sbb.das.backend.admin.application.holidays.model.Holiday;
import ch.sbb.das.backend.admin.application.holidays.model.HolidayRequest;
import java.util.List;

public interface HolidayService {

    List<Holiday> getAll();

    Holiday getById(Integer id);

    Holiday create(HolidayRequest createRequest);

    Holiday update(Integer id, HolidayRequest updateRequest);

    void delete(Integer id);

    void delete(List<Integer> ids);
}

