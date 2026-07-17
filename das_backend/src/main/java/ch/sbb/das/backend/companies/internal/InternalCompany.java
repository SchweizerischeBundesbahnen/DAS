package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyShortName;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "A company with technical id for CRUD operations (Admin only)")
record InternalCompany(
    @Schema(description = "The technical identifier.", requiredMode = Schema.RequiredMode.REQUIRED)
    Integer id,
    @Schema(description = "The RICS company code.", requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyCode code,
    @Schema(description = "The human-readable short name (NeTS).", requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyShortName shortName,
    @Schema(description = "The tenant ID this company belongs to.", requiredMode = Schema.RequiredMode.REQUIRED)
    String tenantId,
    @Schema(description = "The timestamp of the last edit to the company.", requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
    LocalDateTime lastModifiedAt,
    @Schema(description = "The user who last edited the company.", requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
    String lastModifiedBy
) {

}
