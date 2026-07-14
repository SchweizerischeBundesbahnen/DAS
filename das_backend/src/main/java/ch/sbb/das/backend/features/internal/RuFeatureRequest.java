package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Request to create or update a RU feature toggle.")
public record RuFeatureRequest(
    @Schema(description = CompanyCode.DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull CompanyCode companyCode,

    @Schema(description = "The identifier of the feature.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull RuFeatureKey key,

    @Schema(description = "Toggle indicating whether the feature is enabled.", requiredMode = Schema.RequiredMode.REQUIRED)
    boolean enabled
) {

}
