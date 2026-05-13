package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;

@Schema(description = "Notice template payload. At least one language object (de, fr, or it) is provided.")
public record NoticeTemplate(
    @Schema(description = "The unique identifier for the notice template entry.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "The category of the notice template.", requiredMode = RequiredMode.REQUIRED)
    String category,
    @Schema(description = "The german notice template.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateContent de,
    @Schema(description = "The french notice template.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateContent fr,
    @Schema(description = "The italian notice template.", requiredMode = RequiredMode.NOT_REQUIRED)
    NoticeTemplateContent it,
    @Schema(description = "The user who created or last updated the notice template.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    String lastModifiedBy
) {

    public NoticeTemplate(Integer id, String category, NoticeTemplateContent de, NoticeTemplateContent fr, NoticeTemplateContent it) {
        this(id, category, de, fr, it, null);
    }

}
