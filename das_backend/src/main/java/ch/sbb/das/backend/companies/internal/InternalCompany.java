package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyShortName;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "A company with technical id for CRUD operations (Admin only)")
record InternalCompany(
    @Schema(description = "The technical identifier.", requiredMode = Schema.RequiredMode.REQUIRED) Integer id,
    @Schema(description = "The RICS company code.", requiredMode = Schema.RequiredMode.REQUIRED) CompanyCode code,
    @Schema(description = "The human-readable short name.", requiredMode = Schema.RequiredMode.REQUIRED) CompanyShortName shortName) {

}
