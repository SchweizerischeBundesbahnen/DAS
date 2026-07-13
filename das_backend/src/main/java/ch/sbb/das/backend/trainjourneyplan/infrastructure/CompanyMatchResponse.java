package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

record CompanyMatchResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<CompanyMatch> data
) implements ApiResponse<CompanyMatch> {

}
