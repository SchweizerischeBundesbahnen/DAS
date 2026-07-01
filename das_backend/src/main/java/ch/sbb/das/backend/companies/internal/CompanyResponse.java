package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.common.ApiResponse;
import ch.sbb.das.backend.companies.Company;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record CompanyResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<Company> data)
    implements ApiResponse<Company> {

}
