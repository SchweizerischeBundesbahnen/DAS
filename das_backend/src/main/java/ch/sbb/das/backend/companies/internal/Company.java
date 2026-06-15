package ch.sbb.das.backend.companies.internal;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "A company entry.")
public record Company(
    @Schema(description = "The RICS company code.", requiredMode = Schema.RequiredMode.REQUIRED)
    String code,
    @Schema(description = "The human-readable short name of the company.", requiredMode = Schema.RequiredMode.REQUIRED)
    String name
) {

}
