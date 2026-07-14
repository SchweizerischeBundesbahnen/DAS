package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "A RU feature toggle with technical id and audit details for CRUD operations (Admin only)")
record InternalRuFeature(
    @Schema(description = "The technical identifier.", requiredMode = Schema.RequiredMode.REQUIRED)
    Integer id,

    @Schema(description = CompanyCode.DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyCode companyCode,

    @Schema(description = "The identifier of the feature.",
        examples = {"WARNAPP", "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", "CHECKLIST_DEPARTURE_PROCESS", "DISPLAY_PLANNED_TIME_DEVIATION"})
    String key,

    @Schema(description = "Toggle indicating whether the feature is enabled.",
        requiredMode = Schema.RequiredMode.REQUIRED)
    boolean enabled,

    @Schema(description = "The timestamp of the last edit to the RU feature.", requiredMode = Schema.RequiredMode.REQUIRED)
    LocalDateTime lastModifiedAt,

    @Schema(description = "The user who last edited the RU feature.", requiredMode = Schema.RequiredMode.REQUIRED)
    String lastModifiedBy
) {

}
