package ch.sbb.das.backend.indications.internal.model;

import ch.sbb.das.backend.common.TranslatedContentRequest;
import ch.sbb.das.backend.common.ValidTranslatedContent;
import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "RU indication template payload. At least one language object (de, fr, or it) must be provided.")
@ValidTranslatedContent
public record RuIndicationTemplateRequest(
    @Schema(description = "RU indication template category.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank String category,
    @Schema(description = "German RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationTemplateEntry de,
    @Schema(description = "French RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationTemplateEntry fr,
    @Schema(description = "Italian RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationTemplateEntry it
) implements TranslatedContentRequest<RuIndicationTemplateEntry> {

    public RuIndicationTemplateRequest {
        de = normalize(de);
        fr = normalize(fr);
        it = normalize(it);
    }

    @Override
    public RuIndicationTemplateEntry normalize(RuIndicationTemplateEntry entry) {
        return RuIndicationTemplateEntry.normalize(entry);
    }
}
