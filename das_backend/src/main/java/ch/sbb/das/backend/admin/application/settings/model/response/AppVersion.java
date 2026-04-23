package ch.sbb.das.backend.admin.application.settings.model.response;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDate;

public record AppVersion(
    @Schema(description = "The unique identifier for the app version entry.", requiredMode = Schema.RequiredMode.REQUIRED)
    Integer id,
    @Schema(description = "The version number of the app visible by users in the App-Store.", requiredMode = Schema.RequiredMode.REQUIRED, example = "1.2.3")
    String version,
    @Schema(description = "App versions below minimalVersion are outdated and must be blocked for DAS-Client usage.", requiredMode = Schema.RequiredMode.REQUIRED)
    Boolean minimalVersion,
    @Schema(description = "App versions after the expiration date must be blocked from further usage.", requiredMode = RequiredMode.NOT_REQUIRED)
    LocalDate expiryDate
) {

}
