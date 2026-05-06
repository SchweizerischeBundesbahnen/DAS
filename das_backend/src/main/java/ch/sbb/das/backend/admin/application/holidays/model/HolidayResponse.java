package ch.sbb.das.backend.admin.application.holidays.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record HolidayResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1)
    List<Holiday> data
) implements ApiResponse<Holiday> {

    public HolidayResponse(Holiday holiday) {
        this(List.of(holiday));
    }
}

