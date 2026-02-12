package ch.sbb.backend.admin.application.settings.model.response;

import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;

public record CurrentAppVersion(
    @Schema(description = "Indicates whether an app update is expired", requiredMode = Schema.RequiredMode.REQUIRED)
    Boolean expired,
    @Schema(description = "The expiration date of the current app version", requiredMode = Schema.RequiredMode.NOT_REQUIRED)
    LocalDate expiryDate
) {

    public static CurrentAppVersion DEFAULT = new CurrentAppVersion(false, null);

}
