package ch.sbb.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Notice template payload. At least one language object (de, fr, or it) must be provided.")
public record NoticeTemplateRequest(
    @Schema(description = "Notice template category.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull String category,
    @Schema(description = "German notice template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateLanguage de,
    @Schema(description = "French notice template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateLanguage fr,
    @Schema(description = "Italian notice template content.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateLanguage it
) {

}

