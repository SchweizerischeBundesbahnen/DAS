package ch.sbb.das.backend.admin.application.ruindications.model;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Timetable logic to apply to a special holiday date.")
public enum ScheduleType {
    SUNDAY_SCHEDULE,
    MONDAY_SCHEDULE
}

