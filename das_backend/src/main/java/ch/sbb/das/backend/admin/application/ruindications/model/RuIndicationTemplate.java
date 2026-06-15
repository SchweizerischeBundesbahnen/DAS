package ch.sbb.das.backend.admin.application.ruindications.model;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDateTime;
import java.util.Set;

@Schema(description = "RU indication template payload. At least one language object (de, fr, or it) is provided.")
public record RuIndicationTemplate(
    @Schema(description = "The unique identifier for the RU indication template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "The category of the RU indication template.", requiredMode = RequiredMode.REQUIRED)
    String category,
    @Schema(description = "The german RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    RuIndicationEntry de,
    @Schema(description = "The french RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    RuIndicationEntry fr,
    @Schema(description = "The italian RU indication template.", requiredMode = RequiredMode.NOT_REQUIRED)
    RuIndicationEntry it,
    @Schema(description = "The RICS company codes for which this template is provided.", requiredMode = RequiredMode.REQUIRED)
    Set<CompanyCode> companies,
    @Schema(description = "The timestamp of the last update to the RU indication template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    LocalDateTime lastModifiedAt,
    @Schema(description = "The user who created or last updated the RU indication template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    String lastModifiedBy
) {

    public RuIndicationTemplate(Integer id, String category, RuIndicationEntry de, RuIndicationEntry fr, RuIndicationEntry it, Set<CompanyCode> companies) {
        this(id, category, de, fr, it, companies, null, null);
    }
}
