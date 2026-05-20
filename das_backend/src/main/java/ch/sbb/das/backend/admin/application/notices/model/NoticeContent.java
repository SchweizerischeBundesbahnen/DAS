package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import jakarta.validation.Valid;
import org.apache.commons.lang3.StringUtils;

@Schema(description = "Notice content. At least one language object (de, fr, or it) must be provided.")
@ValidTranslatedContent
public record NoticeContent(
    String category,
    @Schema(description = "German notice content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    NoticeTemplateContent de,
    @Schema(description = "French notice content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    NoticeTemplateContent fr,
    @Schema(description = "Italian notice content.", requiredMode = RequiredMode.NOT_REQUIRED)
    @Valid
    NoticeTemplateContent it
) implements TranslatedContentRequest {

    public NoticeContent {
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
