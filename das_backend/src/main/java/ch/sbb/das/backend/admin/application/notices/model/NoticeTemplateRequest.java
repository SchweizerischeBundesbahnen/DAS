package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Notice template payload. At least one language object (de, fr, or it) must be provided.")
@ValidTranslatedContent
public record NoticeTemplateRequest(
    @Schema(description = "Notice template category.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank String category,
    @Schema(description = "German notice template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    NoticeTemplateContent de,
    @Schema(description = "French notice template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    NoticeTemplateContent fr,
    @Schema(description = "Italian notice template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    NoticeTemplateContent it
) implements TranslatedContentRequest {

    public NoticeTemplateRequest {
        de = normalizeIfEmpty(de);
        fr = normalizeIfEmpty(fr);
        it = normalizeIfEmpty(it);
    }

    private static NoticeTemplateContent normalizeIfEmpty(NoticeTemplateContent content) {
        if (content == null) {
            return null;
        }
        if (StringUtils.isBlank(content.title()) && StringUtils.isBlank(content.text())) {
            return null;
        }
        return content;
    }
}

