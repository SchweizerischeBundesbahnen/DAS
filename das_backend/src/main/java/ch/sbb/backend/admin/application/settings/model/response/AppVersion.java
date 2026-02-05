package ch.sbb.backend.admin.application.settings.model.response;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;

public record AppVersion(
    @Schema(description = "App Version update required")
    Boolean updateRequired,
    @Schema(description = "App Version expiry Date")
    LocalDate expiryDate,
    @Schema(description = "App Version current Version")
    String currentVersion
) {

}
