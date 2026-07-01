package ch.sbb.das.backend.common;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import org.jspecify.annotations.NonNull;

@Schema(description = "Delete request containing ids of entries.")
public record DeleteByIdsRequest(
    @Schema(description = "Entry ids to delete.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty List<@NonNull Integer> ids
) {

}
