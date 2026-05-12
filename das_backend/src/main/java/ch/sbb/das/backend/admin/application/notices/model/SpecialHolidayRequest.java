package ch.sbb.das.backend.admin.application.notices.model;

import ch.sbb.das.backend.common.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.Set;

@Schema(description = "Special holiday request.")
public record SpecialHolidayRequest(
    @Schema(description = "Special holiday name.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank String name,
    @Schema(description = "The calendar day of the special holiday.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull LocalDate date,
    @Schema(description = "Timetable logic to apply to a special holiday.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull ScheduleType scheduleType,
    @Schema(description = "The RICS company codes for which this special holiday applies.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty Set<CompanyCode> companies
) {

}

