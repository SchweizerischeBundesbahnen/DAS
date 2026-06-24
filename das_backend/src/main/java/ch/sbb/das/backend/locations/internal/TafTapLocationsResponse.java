package ch.sbb.das.backend.locations.internal;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record TafTapLocationsResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1) List<TafTapLocation> data)
    implements ApiResponse<TafTapLocation> {

}
