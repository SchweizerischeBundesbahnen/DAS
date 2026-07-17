package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyShortName;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Request to create or update a company.")
public record CompanyRequest(
    @Schema(description = "The RICS company code.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull CompanyCode code,
    @Schema(description = "The human-readable short name (NeTS).", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull CompanyShortName shortName,
    @Schema(description = "The tenant ID this company belongs to.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank String tenantId) {

}
