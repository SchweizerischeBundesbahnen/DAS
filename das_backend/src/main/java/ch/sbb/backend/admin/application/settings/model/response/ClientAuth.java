package ch.sbb.backend.admin.application.settings.model.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record ClientAuth(
    @Schema(description = "Auth Key")
    String key,
    @Schema(description = "Auth Secret")
    String secret
) {

}
