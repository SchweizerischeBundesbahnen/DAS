package ch.sbb.das.backend.admin.application.ruindications.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;

@Schema(description = "RU indication template payload. At least one language object (de, fr, or it) is provided.")
public record RuIndicationTemplate(
    @Schema(description = "The unique identifier for the RU indication template entry.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "The category of the RU indication template.", requiredMode = RequiredMode.REQUIRED)
    String category,
    @Schema(description = "The german RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    Content de,
    @Schema(description = "The french RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    Content fr,
    @Schema(description = "The italian RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    Content it,
    @Schema(description = "The user who created or last updated the RU indication template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    String lastModifiedBy
) {

    public RuIndicationTemplate(Integer id, String category, Content de, Content fr, Content it) {
        this(id, category, de, fr, it, null);
    }

}
