package ch.sbb.backend.formation.api.v1.model;

import static ch.sbb.backend.formation.api.v1.FormationController.COMPANY_DESCRIPTION;
import static ch.sbb.backend.formation.api.v1.FormationController.OPERATIONAL_DAY_DESCRIPTION;
import static ch.sbb.backend.formation.api.v1.FormationController.OPERATIONAL_TRAIN_NUMBER_DESCRIPTION;

import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;
import java.util.List;
import lombok.Builder;
import org.springframework.util.CollectionUtils;

@Builder
public record Formation(

    @Schema(description = OPERATIONAL_TRAIN_NUMBER_DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    String operationalTrainNumber,

    @Schema(description = OPERATIONAL_DAY_DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    LocalDate operationalDay,

    @Schema(description = COMPANY_DESCRIPTION, requiredMode = Schema.RequiredMode.REQUIRED)
    String company,

    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED), minItems = 1)
    List<FormationRun> formationRuns
) {

    public static Formation from(List<TrainFormationRunEntity> trainFormationRunEntities) {
        if (CollectionUtils.isEmpty(trainFormationRunEntities)) {
            throw new IllegalArgumentException("Train formation runs cannot be empty");
        }

        return Formation.builder()
            .operationalTrainNumber(trainFormationRunEntities.getFirst().getOperationalTrainNumber())
            .operationalDay(trainFormationRunEntities.getFirst().getOperationalDay())
            .company(trainFormationRunEntities.getFirst().getCompany())
            .formationRuns(FormationRun.fromList(trainFormationRunEntities))
            .build();
    }

}
