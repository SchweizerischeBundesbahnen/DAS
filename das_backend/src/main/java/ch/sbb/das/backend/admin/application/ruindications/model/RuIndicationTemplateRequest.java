package ch.sbb.das.backend.admin.application.ruindications.model;

import ch.sbb.das.backend.admin.application.common.TranslatedContentRequest;
import ch.sbb.das.backend.admin.application.common.ValidTranslatedContent;
import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.Set;

@Schema(description = "RU indication template payload. At least one language object (de, fr, or it) must be provided.")
@ValidTranslatedContent
public record RuIndicationTemplateRequest(
    @Schema(description = "RU indication template category.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank String category,
    @Schema(description = "German RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationEntry de,
    @Schema(description = "French RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationEntry fr,
    @Schema(description = "Italian RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationEntry it,
    @Schema(description = "The RICS company codes for which this template is provided.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty Set<CompanyCode> companies
) implements TranslatedContentRequest<RuIndicationEntry> {

    public RuIndicationTemplateRequest {
        de = normalize(de);
        fr = normalize(fr);
        it = normalize(it);
    }

    @Override
    public RuIndicationEntry normalize(RuIndicationEntry entry) {
        return RuIndicationEntry.normalize(entry);
    }
}
