package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.indications.internal.model.SpecialHoliday;
import ch.sbb.das.backend.indications.internal.model.SpecialHolidayRequest;
import org.springframework.stereotype.Component;

@Component
public class SpecialHolidayMapper {

    public SpecialHoliday toResponse(SpecialHolidayEntity entity) {
        return new SpecialHoliday(
            entity.getId(),
            entity.getName(),
            entity.getDate(),
            entity.getScheduleType(),
            entity.getCompanies(),
            entity.getLastModifiedAt(),
            entity.getLastModifiedBy()
        );
    }

    public SpecialHolidayEntity toEntityFromRequest(Integer id, SpecialHolidayRequest request) {
        SpecialHolidayEntity entity = new SpecialHolidayEntity();
        entity.setId(id);
        return updateEntityFromRequest(entity, request);
    }

    public SpecialHolidayEntity updateEntityFromRequest(SpecialHolidayEntity entity, SpecialHolidayRequest request) {
        entity.setName(request.name());
        entity.setDate(request.date());
        entity.setScheduleType(request.scheduleType());
        entity.setCompanies(request.companies());
        return entity;
    }
}
