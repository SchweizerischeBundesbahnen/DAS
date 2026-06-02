package ch.sbb.das.backend.admin.application.ruindications.model;

import static ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationEntry.normalizeIfEmpty;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import jakarta.validation.Valid;

@Schema(description = "RU indication content. At least one language object (de, fr, or it) must be provided.")
@ValidTranslatedContent
public record RuIndicationContent(
    @Schema(description = "RU indication category.", requiredMode = RequiredMode.NOT_REQUIRED)
    String category,
    @Schema(description = "German RU indication entry.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationEntry de,
    @Schema(description = "French RU indication entry.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationEntry fr,
    @Schema(description = "Italian RU indication entry.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    RuIndicationEntry it
) implements TranslatedContentRequest {

    public RuIndicationContent {
        de = normalizeIfEmpty(de);
        fr = normalizeIfEmpty(fr);
        it = normalizeIfEmpty(it);
    }
}
