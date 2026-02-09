package ch.sbb.backend.admin.application.settings.model.response;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;

public record CurrentAppVersion(
    @Schema(description = "Indicates whether an app update is required")
    Boolean updateRequired,
    @Schema(description = "The expiration date of the current app version")
    LocalDate expiryDate,
    @Schema(description = "The current version number of the app")
    String currentVersion
) {

}
