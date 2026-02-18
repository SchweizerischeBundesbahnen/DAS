package ch.sbb.backend.admin.domain.settings.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDate;

public record AppVersion(
    // todo descriptions and ..
    @Schema(description = "The unique identifier fot the app version entry", requiredMode = Schema.RequiredMode.REQUIRED)
    Integer id,
    @Schema(description = "The version number of the app", requiredMode = Schema.RequiredMode.REQUIRED, example = "1.2.3")
    String version,
    @Schema(description = "App versions below this versions are blocked", requiredMode = Schema.RequiredMode.REQUIRED)
    Boolean minimalVersion,
    @Schema(description = "The expiration date", requiredMode = RequiredMode.NOT_REQUIRED)
    LocalDate expiryDate
) {

}
