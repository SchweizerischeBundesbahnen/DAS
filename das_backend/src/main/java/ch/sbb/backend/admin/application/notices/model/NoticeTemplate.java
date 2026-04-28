package ch.sbb.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDateTime;

@Schema(description = "Notice template payload. At least one language object (de, fr, or it) is provided.")
public record NoticeTemplate(
    @Schema(description = "The unique identifier for the notice template entry.", requiredMode = RequiredMode.REQUIRED)
    Integer id,
    @Schema(description = "The category of the notice template.", requiredMode = RequiredMode.REQUIRED)
    String category,
    @Schema(description = "The german notice template.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateLanguage de,
    @Schema(description = "The french notice template.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateLanguage fr,
    @Schema(description = "The italian notice template.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateLanguage it,
    @Schema(description = "The user who created or last updated the notice template.", requiredMode = RequiredMode.REQUIRED)
    String lastModifiedBy,
    @Schema(description = "The timestamp of when the notice template was created or last updated.", requiredMode = RequiredMode.REQUIRED)
    LocalDateTime lastModifiedAt
) {

}
