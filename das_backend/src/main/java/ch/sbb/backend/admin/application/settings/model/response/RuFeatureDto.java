package ch.sbb.backend.admin.application.settings.model.response;

import ch.sbb.backend.admin.domain.settings.model.RuFeature;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(name = "RuFeature", description = "RU specific feature toggle.")
public record RuFeatureDto(
    @Schema(description = "Relates to teltsi_CompanyCode resp. teltsi_Company according to SFERA.", requiredMode = Schema.RequiredMode.REQUIRED)
    String companyCodeRics,

    @Schema(description = "The identifier of the feature. This can be one of three values: 'WARN', 'KOA', or 'GESTES'.",
        requiredMode = Schema.RequiredMode.REQUIRED)
    String name,

    @Schema(description = "Toggle indicating whether the feature is enabled.",
        requiredMode = Schema.RequiredMode.REQUIRED)
    boolean enabled
) {

    public RuFeatureDto(RuFeature ruFeature) {
        this(ruFeature.company().companyCodeRics(), ruFeature.name().name(), ruFeature.enabled());
    }

}
