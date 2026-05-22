package ch.sbb.das.backend.admin.application.ruindications.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record RuIndicationMatchesResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<RuIndicationMatch> data
) implements ApiResponse<RuIndicationMatch> {

}
