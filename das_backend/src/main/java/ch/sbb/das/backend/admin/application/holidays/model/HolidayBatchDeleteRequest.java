package ch.sbb.das.backend.admin.application.holidays.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

@Schema(description = "Batch delete holidays payload.")
public record HolidayBatchDeleteRequest(
    @Schema(description = "Holiday ids to delete.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty List<@NotNull Integer> ids
) {

}

