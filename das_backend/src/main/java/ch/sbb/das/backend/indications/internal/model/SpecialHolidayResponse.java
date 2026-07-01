package ch.sbb.das.backend.indications.internal.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record SpecialHolidayResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<SpecialHoliday> data
) implements ApiResponse<SpecialHoliday> {

    public SpecialHolidayResponse(SpecialHoliday specialHoliday) {
        this(List.of(specialHoliday));
    }
}

