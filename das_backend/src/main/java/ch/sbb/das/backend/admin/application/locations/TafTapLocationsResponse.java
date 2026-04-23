package ch.sbb.das.backend.admin.application.locations;

import ch.sbb.das.backend.admin.domain.locations.TafTapLocation;
import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record TafTapLocationsResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1) List<TafTapLocationDto> data)
    implements ApiResponse<TafTapLocationDto> {

    public static TafTapLocationsResponse from(List<TafTapLocation> locations) {
        return new TafTapLocationsResponse(locations.stream()
            .map(TafTapLocationDto::from).toList());
    }
}
