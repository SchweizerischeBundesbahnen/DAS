package ch.sbb.das.backend.admin.application.notices.model;

import ch.sbb.das.backend.common.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDate;
import java.util.Set;

@Schema(description = "Special holiday.")
public record SpecialHoliday(
    @Schema(description = "The unique identifier for the holiday entry.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "The special holiday name.", requiredMode = RequiredMode.REQUIRED, example = "Auffahrt")
    String name,
    @Schema(description = "The calendar day on which the holiday is valid.", requiredMode = RequiredMode.REQUIRED)
    LocalDate date,
    @Schema(description = "Whether the holiday is treated like a Sunday or a Monday schedule.", requiredMode = RequiredMode.REQUIRED)
    ScheduleType scheduleType,
    @Schema(description = "The RICS company codes for which this holiday applies.", requiredMode = RequiredMode.REQUIRED)
    Set<CompanyCode> companies
) {

}

