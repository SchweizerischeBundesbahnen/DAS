package ch.sbb.backend.formation.api.v1.model;

import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;
import java.util.List;
import lombok.Builder;

@Builder
@Schema(name = "Formation")
public record FormationResponse(
    @Schema(description = "Relates to teltsi_OperationalTrainNumber (according to SFERA).", requiredMode = Schema.RequiredMode.REQUIRED)
    String operationalTrainNumber,

    @Schema(description = "Operational day.", requiredMode = Schema.RequiredMode.REQUIRED)
    LocalDate operationalDay,

    @Schema(description = "Relates to teltsi_CompanyCode (according to SFERA).", requiredMode = Schema.RequiredMode.REQUIRED)
    String company,

    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<FormationRunDto> formationRuns
) {

    public static FormationResponse from(List<TrainFormationRunEntity> trainFormationRunEntities) {
        if (trainFormationRunEntities == null || trainFormationRunEntities.isEmpty()) {
            throw new IllegalArgumentException("Train formation runs cannot be empty");
        }

        return FormationResponse.builder()
            .operationalTrainNumber(trainFormationRunEntities.getFirst().getOperationalTrainNumber())
            .operationalDay(trainFormationRunEntities.getFirst().getOperationalDay())
            .company(trainFormationRunEntities.getFirst().getCompany())
            .formationRuns(FormationRunDto.fromList(trainFormationRunEntities))
            .build();
    }

}
