package ch.sbb.das.backend.indications.internal.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDateTime;

@Schema(description = "RU indication template payload. At least one language object (de, fr, or it) is provided.")
public record RuIndicationTemplate(
    @Schema(description = "The unique identifier for the RU indication template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "The category of the RU indication template.", requiredMode = RequiredMode.REQUIRED)
    String category,
    @Schema(description = "The german RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    RuIndicationTemplateEntry de,
    @Schema(description = "The french RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    RuIndicationTemplateEntry fr,
    @Schema(description = "The italian RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    RuIndicationTemplateEntry it,
    @JsonIgnore
    String tenant,
    @Schema(description = "The timestamp of the last update to the RU indication template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    LocalDateTime lastModifiedAt,
    @Schema(description = "The user who created or last updated the RU indication template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    String lastModifiedBy
) {

    public RuIndicationTemplate(Integer id, String category, RuIndicationTemplateEntry de, RuIndicationTemplateEntry fr, RuIndicationTemplateEntry it, String tenant) {
        this(id, category, de, fr, it, tenant, null, null);
    }
}
