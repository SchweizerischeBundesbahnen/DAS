package ch.sbb.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;

public record NoticeTemplateLanguage(
    @Schema(description = "The title of the notice template in the respective language.", requiredMode = Schema.RequiredMode.REQUIRED)
    String title,
    @Schema(description = "The text of the notice template in the respective language.", requiredMode = Schema.RequiredMode.REQUIRED)
    String text
) {

}
