package ch.sbb.das.backend.externallinks.internal;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

public record ExternalLinkContent(
    @Schema(description = "The title of the external link in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank
    String title,
    @Schema(description = "The link of the external link in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    @ValidURL
    String link) {

}
