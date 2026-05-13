package ch.sbb.das.backend.tenancy.application.model;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record CompaniesResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<Company> data)
    implements ApiResponse<Company> {

}
