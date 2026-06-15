package ch.sbb.das.backend.admin.application.settings.model.response;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "RU specific feature toggle.")
public record RuFeature(
    @Schema(description = "Relates to teltsi_CompanyCode (according to SFERA).", requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyCode companyCodeRics,

    @Schema(description = "The identifier of the feature.",
        examples = {"WARNAPP", "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", "CHECKLIST_DEPARTURE_PROCESS"})
    String key,

    @Schema(description = "Toggle indicating whether the feature is enabled.",
        requiredMode = Schema.RequiredMode.REQUIRED)
    boolean enabled
) {

    public RuFeature(ch.sbb.das.backend.admin.domain.settings.model.RuFeature ruFeature) {
        this(ruFeature.company().code(), ruFeature.key().name(), ruFeature.enabled());
    }

}
