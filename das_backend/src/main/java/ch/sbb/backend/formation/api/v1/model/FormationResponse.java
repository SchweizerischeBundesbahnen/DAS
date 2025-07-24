package ch.sbb.backend.formation.api.v1.model;

import ch.sbb.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record FormationResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 1, maxItems = 1)
    List<Formation> data
) implements ApiResponse<Formation> {

}
