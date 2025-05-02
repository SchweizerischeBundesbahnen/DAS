package ch.sbb.backend.admin.application.settings.model.response;

import ch.sbb.backend.admin.domain.settings.model.RuFeature;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(name = "RuFeature", description = "RU specific feature toggle.")
public record RuFeatureDto(
    @Schema(description = "Relates to teltsi_CompanyCode (according to SFERA).", requiredMode = Schema.RequiredMode.REQUIRED)
    String companyCodeRics,

    @Schema(description = "The identifier of the feature.",
        examples = {"WARNAPP", "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", "CHECKLIST_DEPARTURE_PROCESS"})
    String key,

    @Schema(description = "Toggle indicating whether the feature is enabled.",
        requiredMode = Schema.RequiredMode.REQUIRED)
    boolean enabled
) {

    public RuFeatureDto(RuFeature ruFeature) {
        this(ruFeature.company().companyCodeRics(), ruFeature.key().name(), ruFeature.enabled());
    }

}
