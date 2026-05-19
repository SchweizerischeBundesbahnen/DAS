package ch.sbb.das.backend.admin.application.notices.model;

import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

@Schema(description = "A requested TAF/TAP location reference enriched with matched notice contents in a single resolved language.")
public record NoticeMatch(
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    TafTapLocationReference tafTapLocationReference,
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<NoticeTemplateContent> noticeContents
) {

}
