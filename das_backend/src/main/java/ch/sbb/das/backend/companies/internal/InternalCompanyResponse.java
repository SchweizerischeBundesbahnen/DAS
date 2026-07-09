package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record InternalCompanyResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED)) List<InternalCompany> data)
    implements ApiResponse<InternalCompany> {

    public InternalCompanyResponse(InternalCompany single) {
        this(List.of(single));
    }
}
