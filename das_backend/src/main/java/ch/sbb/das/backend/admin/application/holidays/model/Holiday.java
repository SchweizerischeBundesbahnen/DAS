package ch.sbb.das.backend.admin.application.holidays.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDate;
import java.util.Set;

@Schema(description = "Holiday payload.")
public record Holiday(
    @Schema(description = "The unique identifier for the holiday entry.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "The holiday name.", requiredMode = RequiredMode.REQUIRED)
    String name,
    @Schema(description = "The calendar day on which the holiday is valid.", requiredMode = RequiredMode.REQUIRED)
    LocalDate validAt,
    @Schema(description = "Whether the holiday is treated like a Sunday or a Monday.", requiredMode = RequiredMode.REQUIRED)
    HolidayType type,
    @Schema(description = "The RICS company codes for which this holiday applies.", requiredMode = RequiredMode.REQUIRED)
    Set<String> companies
) {

}

