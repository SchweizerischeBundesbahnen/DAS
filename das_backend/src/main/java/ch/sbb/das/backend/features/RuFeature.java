package ch.sbb.das.backend.features;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "RU specific feature toggle.")
public record RuFeature(
    @Schema(description = CompanyCode.DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyCode companyCode,

    @Schema(description = "The identifier of the feature.",
        examples = {"WARNAPP", "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", "CHECKLIST_DEPARTURE_PROCESS"})
    String key,

    @Schema(description = "Toggle indicating whether the feature is enabled.",
        requiredMode = Schema.RequiredMode.REQUIRED)
    boolean enabled
) {

}
