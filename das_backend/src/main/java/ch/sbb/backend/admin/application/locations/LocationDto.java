package ch.sbb.backend.admin.application.locations;

import ch.sbb.backend.admin.domain.locations.Location;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;

public record LocationDto(
    @Schema(description = "TAF/TAP location reference", requiredMode = RequiredMode.REQUIRED, example = "CH07000")
    String locationReference,
    @Schema(description = "Primary location name also called official designation", requiredMode = RequiredMode.REQUIRED, example = "Bern")
    String primaryLocationName,
    @Schema(description = "Location abbreviation", requiredMode = RequiredMode.NOT_REQUIRED, example = "BN")
    String locationAbbreviation,
    @Schema(description = "Location is only valid in future timetable period", requiredMode = RequiredMode.REQUIRED)
    boolean future
) {

    static LocationDto from(Location location) {
        return new LocationDto(location.locationReference().toLocationCode(), location.primaryLocationName(), location.locationAbbreviation(), location.isFuture());
    }
}
