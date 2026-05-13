package ch.sbb.das.backend.admin.application.notices.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

@Schema(description = "Batch delete notice templates payload.")
public record NoticeTemplateBatchDeleteRequest(
    @Schema(description = "Notice template ids to delete.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty List<@NotNull Integer> ids
) {

}

