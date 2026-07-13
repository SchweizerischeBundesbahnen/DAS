package ch.sbb.das.backend.features;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDateTime;

@Schema(description = "RU specific feature toggle.")
public record RuFeature(
    @Schema(description = "The unique identifier for the RU feature entry.",
        requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
    Integer id,

    @Schema(description = CompanyCode.DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyCode companyCode,

    @Schema(description = "The identifier of the feature.",
        examples = {"WARNAPP", "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", "CHECKLIST_DEPARTURE_PROCESS"})
    String key,

    @Schema(description = "Toggle indicating whether the feature is enabled.",
        requiredMode = Schema.RequiredMode.REQUIRED)
    boolean enabled,

    @Schema(description = "The timestamp of the last edit to the RU feature.",
        requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
    LocalDateTime lastModifiedAt,

    @Schema(description = "The user who last edited the RU feature.",
        requiredMode = Schema.RequiredMode.REQUIRED, accessMode = Schema.AccessMode.READ_ONLY)
    String lastModifiedBy
) {

}
