package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.common.ApiResponse;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

public record AdminCompanyResponse(
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED)) List<AdminCompany> data)
    implements ApiResponse<AdminCompany> {

    public AdminCompanyResponse(AdminCompany single) {
        this(List.of(single));
    }
}
