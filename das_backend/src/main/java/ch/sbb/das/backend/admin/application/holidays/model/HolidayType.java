package ch.sbb.das.backend.admin.application.holidays.model;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Defines whether the holiday is treated like a Sunday or a Monday.")
public enum HolidayType {
    SUNDAY,
    MONDAY
}

