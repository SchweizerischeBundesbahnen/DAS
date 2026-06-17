package ch.sbb.das.backend.admin.application.common;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import org.jspecify.annotations.NonNull;

import java.util.List;

@Schema(description = "Delete request containing ids of entries.")
public record DeleteByIdsRequest(
    @Schema(description = "Entry ids to delete.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty List<@NonNull Integer> ids
) {
}
