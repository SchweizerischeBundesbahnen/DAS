package ch.sbb.das.backend.driversettings.internal;

import ch.sbb.das.backend.appversions.CurrentAppVersion;
import ch.sbb.das.backend.config.Logging;
import ch.sbb.das.backend.config.Preload;
import ch.sbb.das.backend.features.RuFeature;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record Settings(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<RuFeature> ruFeatures,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    Logging logging,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    Preload preload,
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    CurrentAppVersion currentAppVersion
) {

}
