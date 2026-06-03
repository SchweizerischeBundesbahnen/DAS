package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.ruindications.model.SpecialHolidayRequest;
import java.time.LocalDate;
import java.util.List;

public interface SpecialHolidayService {

    List<SpecialHoliday> getAllUpcoming();

    SpecialHoliday getById(Integer id);

    SpecialHoliday create(SpecialHolidayRequest createRequest);

    SpecialHoliday update(Integer id, SpecialHolidayRequest updateRequest);

    void deleteByIds(List<Integer> ids);

    void deleteAllBefore(LocalDate localDate);
}

