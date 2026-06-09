package ch.sbb.das.backend.admin.application.ruindications.model;

import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.time.LocalDate;
import java.util.Set;

public record RuIndicationMatchesRequest(
    @Schema(description = CompanyCode.DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull
    CompanyCode company,
    @Schema(description = "Relates to `teltsi_OperationalTrainNumber` (according to SFERA).", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull
    @Positive
    Integer operationalTrainNumber,
    @Schema(description = "Relates to `teltsi_StartDate` (according to SFERA).", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull
    LocalDate startDate,
    @Schema(description = "List of TAF/TAP location references the train journey passed.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotEmpty
    Set<TafTapLocationReference> tafTapLocationReferences
) {

}
