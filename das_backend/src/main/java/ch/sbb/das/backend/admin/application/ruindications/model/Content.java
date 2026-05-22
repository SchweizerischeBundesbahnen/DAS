package ch.sbb.das.backend.admin.application.ruindications.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

public record Content(
    @Schema(description = "The title of the RU indication template in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank
    String title,
    @Schema(description = "The text of the RU indication template in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    String text
) {

}
