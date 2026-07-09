package ch.sbb.das.backend.companies.internal;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "A tenant entry.")
public record TenantDto(
    @Schema(description = "The tenant display name.", requiredMode = Schema.RequiredMode.REQUIRED)
    String name,
    @Schema(description = "The Entra tenant ID.", requiredMode = Schema.RequiredMode.REQUIRED)
    String tenantId
) {

}
