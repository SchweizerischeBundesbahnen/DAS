package ch.sbb.backend.admin.application.locations;

import ch.sbb.backend.admin.domain.locations.Location;
import ch.sbb.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record LocationsResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 0, maxItems = 1) List<LocationDto> data)
    implements ApiResponse<LocationDto> {

    public static LocationsResponse from(List<Location> locations) {
        return new LocationsResponse(locations.stream()
            .map(LocationDto::from).toList());
    }
}
