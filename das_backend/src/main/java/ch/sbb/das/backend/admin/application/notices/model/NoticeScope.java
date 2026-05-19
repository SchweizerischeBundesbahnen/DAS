package ch.sbb.das.backend.admin.application.notices.model;

import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import java.util.Set;

@Schema(description = "Scope for a notice (companies, train filters and locations).")
public record NoticeScope(
    @Schema(description = "The RICS company codes for which this notice applies.", requiredMode = Schema.RequiredMode.REQUIRED, example = "[\"2185\"]")
    @NotEmpty
    Set<CompanyCode> companies,
    @Schema(description = "Optional list of operational train number filters.")
    List<@Valid NoticeTrainNumberFilterRequest> operationalTrainNumberFilters,
    @Schema(description = "List of TAF/TAP location references where this notice applies.", requiredMode = Schema.RequiredMode.REQUIRED, example = "[\"CH07000\"]")
    Set<TafTapLocationReference> tafTapLocationReferences
) {

}

