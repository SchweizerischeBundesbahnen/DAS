package ch.sbb.das.backend.admin.application.holidays.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.Set;

@Schema(description = "Holiday request payload.")
public record HolidayRequest(
    @Schema(description = "Holiday name.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank String name,
    @Schema(description = "The calendar day on which the holiday is valid.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull LocalDate validAt,
    @Schema(description = "Whether the holiday is treated like a Sunday or a Monday.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull HolidayType type,
    @Schema(description = "The RICS company codes for which this holiday applies.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty Set<@NotBlank String> companies
) {

}

