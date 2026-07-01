package ch.sbb.das.backend.indications.internal.model;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
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
    Set<CompanyCode> companies,
    @Schema(description = "The timestamp of the last update to the special holiday.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    LocalDateTime lastModifiedAt,
    @Schema(description = "The user who created or last updated the special holiday.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    String lastModifiedBy
) {

    public SpecialHoliday(Integer id, String name, LocalDate date, ScheduleType scheduleType, Set<CompanyCode> companies) {
        this(id, name, date, scheduleType, companies, null, null);
    }
}

