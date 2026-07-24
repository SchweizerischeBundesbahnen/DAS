package ch.sbb.das.backend.cargo.api.v1.model;

import static ch.sbb.das.backend.cargo.api.v1.FormationController.OPERATIONAL_DAY_DESCRIPTION;
import static ch.sbb.das.backend.cargo.api.v1.FormationController.OPERATIONAL_TRAIN_NUMBER_DESCRIPTION;

import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;
import java.util.List;
import lombok.Builder;

@Builder
@Schema(description = "The formation represents a composition of implied wagons of a train journey (de: Zuglauf).")
public record Formation(

    @Schema(description = OPERATIONAL_TRAIN_NUMBER_DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    String operationalTrainNumber,

    @Schema(description = OPERATIONAL_DAY_DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    LocalDate operationalDay,

    @Schema(description = CompanyCode.DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    CompanyCode company,

    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED, description = "The order of items match the actual run order."), minItems = 1)
    List<FormationRun> formationRuns
) {

}
