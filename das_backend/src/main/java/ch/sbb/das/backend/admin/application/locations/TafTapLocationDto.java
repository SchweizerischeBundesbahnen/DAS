package ch.sbb.das.backend.admin.application.locations;

import ch.sbb.das.backend.admin.domain.locations.TafTapLocation;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDate;

public record TafTapLocationDto(
    @Schema(description = "TAF/TAP location reference", requiredMode = RequiredMode.REQUIRED, example = "CH07000")
    String locationReference,
    @Schema(description = "Primary location name also called official designation", requiredMode = RequiredMode.REQUIRED, example = "Bern")
    String primaryLocationName,
    @Schema(description = "Location abbreviation", requiredMode = RequiredMode.NOT_REQUIRED, example = "BN")
    String locationAbbreviation,
    @Schema(description = "Location is valid in future", requiredMode = RequiredMode.NOT_REQUIRED)
    LocalDate validFrom
) {

    static TafTapLocationDto from(TafTapLocation location) {
        return new TafTapLocationDto(location.locationReference().toLocationCode(), location.primaryLocationName(), location.locationAbbreviation(), location.futureValidFrom());
    }
}
