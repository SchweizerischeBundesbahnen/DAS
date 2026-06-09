package ch.sbb.das.backend.companies;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "A company entry.")
public record Company(
    @Schema(description = "The RICS company code.", requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyCode code,
    @Schema(description = "The human-readable short name.", requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyShortName shortName
) {

}
