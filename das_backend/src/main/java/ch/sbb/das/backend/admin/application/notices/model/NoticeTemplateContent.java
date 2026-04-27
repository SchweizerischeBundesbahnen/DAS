package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

public record NoticeTemplateContent(
    @Schema(description = "The title of the notice template in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank
    String title,
    @Schema(description = "The text of the notice template in the appropriate language.", requiredMode = Schema.RequiredMode.REQUIRED)
    String text
) {

}
