package ch.sbb.das.backend.admin.application.ruindications.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.apache.commons.lang3.StringUtils;

@Schema(description = "RU indication template payload. At least one language object (de, fr, or it) must be provided.")
@ValidTranslatedContent
public record RuIndicationTemplateRequest(
    @Schema(description = "RU indication template category.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank String category,
    @Schema(description = "German RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    Content de,
    @Schema(description = "French RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    Content fr,
    @Schema(description = "Italian RU indication template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    Content it
) implements TranslatedContentRequest {

    public RuIndicationTemplateRequest {
        de = normalizeIfEmpty(de);
        fr = normalizeIfEmpty(fr);
        it = normalizeIfEmpty(it);
    }

    private static Content normalizeIfEmpty(Content content) {
        if (content == null) {
            return null;
        }
        if (StringUtils.isBlank(content.title()) && StringUtils.isBlank(content.text())) {
            return null;
        }
        return content;
    }
}

