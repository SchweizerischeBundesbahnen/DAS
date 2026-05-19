package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHolidayRequest;
import java.util.List;

public interface SpecialHolidayService {

    List<SpecialHoliday> getAllUpcoming();

    SpecialHoliday getById(Integer id);

    SpecialHoliday create(SpecialHolidayRequest createRequest);

    SpecialHoliday update(Integer id, SpecialHolidayRequest updateRequest);

    void deleteByIds(Integer id);

    void deleteByIds(List<Integer> ids);
}

