package ch.sbb.backend.admin.application.settings.model.response;

import io.swagger.v3.oas.annotations.media.Schema;

public record Logging (
    @Schema(description = "Logging URL")
    String url,
    @Schema(description = "Logging Token")
    String token
){}
