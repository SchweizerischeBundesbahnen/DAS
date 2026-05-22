package ch.sbb.das.backend.admin.application.ruindications.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.List;

@Schema(description = "Delete request of RU indication template by ids.")
public record RuIndicationTemplateByIdsDeleteRequest(
    @Schema(description = "RU indication template ids to delete.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty List<@NotNull Integer> ids
) {

}
